#ifndef FINDER_THREAD_POOLS_HPP
#define FINDER_THREAD_POOLS_HPP

#include <vector>
#include <thread>
#include <queue>
#include <atomic>
#include <stdexcept>

#define BOOST_THREAD_PROVIDES_FUTURE
#define BOOST_THREAD_PROVIDES_VARIADIC_THREAD
#define BOOST_THREAD_PROVIDES_SIGNATURE_PACKAGED_TASK
#include <boost/thread/future.hpp>
#include <boost/thread.hpp>

namespace finder {
    class TaskStatus {
    public:
        void resume() {
            isAborted_ = false;
        }

        void abort() {
            isAborted_ = true;
        }

        void terminate() {
            isTerminated_ = true;
        }

        [[nodiscard]] bool terminated() const {
            return isTerminated_;
        }

        [[nodiscard]] bool aborted() const {
            return isAborted_;
        }

        [[nodiscard]] bool working() const {
            return !notWorking();
        }

        [[nodiscard]] bool notWorking() const {
            return isAborted_ || isTerminated_;
        }

    private:
        std::atomic<bool> isTerminated_ = false;
        std::atomic<bool> isAborted_ = false;
    };

    using Runnable = std::function<void(const TaskStatus &)>;

    template<typename T>
    using Callable = std::function<T(const TaskStatus &)>;

    class Tasks {
    public:
        void push(const Runnable &runnable) {
            {
                boost::lock(mutexForQueue_, mutexForAbort_);
				boost::lock_guard<boost::mutex> lk1(mutexForQueue_, boost::adopt_lock);
				boost::lock_guard<boost::mutex> lk2(mutexForAbort_, boost::adopt_lock);

                if (status_.notWorking()) {
                    throw std::runtime_error("Not working");
                }

                queue_.push(runnable);
                counter += 1;
            }

            conditionForQueue_.notify_one();
            conditionForSleep_.notify_one();
        }

        void execute() {
            while (true) {
                Runnable runnable;

                {
					boost::unique_lock<boost::mutex> guard(mutexForQueue_);
                    conditionForQueue_.wait(guard, [this] { return status_.notWorking() || !queue_.empty(); });

                    if (queue_.empty()) {
                        if (status_.notWorking()) {
                            if (status_.terminated()) {
                                // All tasks completed, so finish pool
                                return;
                            }

                            // All tasks completed, so go to sleep
                            conditionForAbort_.notify_all();
                            conditionForSleep_.wait(guard, [this] {
                                return status_.working() || status_.terminated();
                            });
                        }

                        // Working but not found task or after sleeping
                        continue;
                    }

                    // Execute task

                    runnable = queue_.front();
                    queue_.pop();
                }

                runnable(status_);

                {
                    boost::lock_guard<boost::mutex> guard(mutexForAbort_);
                    counter -= 1;
                }
            }
        }

        void abort() {
            {
                boost::lock_guard<boost::mutex> guard(mutexForQueue_);
                status_.abort();
            }

            conditionForQueue_.notify_all();
            conditionForSleep_.notify_all();

            // sleep until completed all tasks
            {
                boost::unique_lock<boost::mutex> guard(mutexForAbort_);
                conditionForAbort_.wait(guard, [this] {
                    return counter == 0;
                });
            }

            {
                boost::lock_guard<boost::mutex> guard(mutexForQueue_);
                status_.resume();
            }

            conditionForQueue_.notify_all();
            conditionForSleep_.notify_all();
        }

        void shutdown() {
            {
                boost::lock_guard<boost::mutex> guard(mutexForQueue_);
                status_.abort();
            }

            conditionForQueue_.notify_all();
            conditionForSleep_.notify_all();

            // sleep until completed all tasks
            {
                boost::unique_lock<boost::mutex> guard(mutexForAbort_);
                conditionForAbort_.wait(guard, [this] {
                    return counter == 0;
                });
            }

            {
                boost::lock_guard<boost::mutex> guard(mutexForQueue_);
                status_.terminate();
            }

            conditionForQueue_.notify_all();
            conditionForSleep_.notify_all();
            conditionForAbort_.notify_all();
        }

        void shutdownNow() {
            {
                boost::lock_guard<boost::mutex> guard(mutexForQueue_);
                status_.terminate();

                counter -= queue_.size();

                std::queue<Runnable> empty{};
                std::swap(queue_, empty);
            }

            conditionForQueue_.notify_all();
            conditionForSleep_.notify_all();
            conditionForAbort_.notify_all();
        }

        bool terminated() const {
            return status_.terminated();
        }

    private:
		boost::mutex mutexForQueue_;
		boost::mutex mutexForAbort_;

        TaskStatus status_{};

        int counter = 0;
        std::queue<Runnable> queue_{};

		boost::condition_variable conditionForQueue_{};
		boost::condition_variable conditionForSleep_{};
		boost::condition_variable conditionForAbort_{};
    };

    /**
     * This class is NOT thread-safe.
     */
    class ThreadPool {
    public:
        explicit ThreadPool(int n) : tasks_(std::make_unique<Tasks>()) {
            start(n);
        }

        ~ThreadPool() {
            if (tasks_->terminated()) {
                return;
            }

            tasks_->shutdownNow();
            for (auto &thread : threads_) {
                if (thread.joinable()) {
                    thread.join();
                }
            }
            threads_.clear();
        }

        // Execute the task
        void execute(const Runnable &runnable) {
            if (tasks_->terminated()) {
                throw std::runtime_error("Thread pool is terminated");
            }

            tasks_->push(runnable);
        }

        // Execute the task returning result.
        template<typename R>
        boost::future<R> execute(const Callable<R> &callable) {
            if (tasks_->terminated()) {
                throw std::runtime_error("Thread pool is terminated");
            }

            auto task = std::make_shared<boost::packaged_task<R(const TaskStatus &)>>(callable);
            tasks_->push([task](const TaskStatus& status) {
                (*task)(status);
            });
            return std::move(task->get_future());
        }

        // Change current status to "aborted" and wait all tasks is completed.
        // The task is notified of the "aborted" status via TaskStatus, but attempts to complete all processing.
        // How long the task ends depends on the task implementation.
        void abort() {
            if (tasks_->terminated()) {
                return;
            }

            tasks_->abort();
        }

        // After abort tasks and wait they are completed, change current status to "Terminated".
        // Thread pool cannot be operated after shutdown.
        void shutdown() {
            if (tasks_->terminated()) {
                return;
            }

            tasks_->shutdown();
            for (auto &thread : threads_) {
                if (thread.joinable()) {
                    thread.join();
                }
            }
            threads_.clear();
        }

        // Change the number of threads.
        // Running tasks are aborted and wait for changes to complete.
        void changeThreadCount(int n) {
            shutdown();
            tasks_ = std::make_unique<Tasks>();
            start(n);
        }

    private:
        void start(int n) {
            assert(0 < n);
            threads_.clear();
            for (int count = 0; count < n; ++count) {
                threads_.emplace_back(std::thread([this]() {
                    tasks_->execute();
                }));
            }
        }

        std::vector<std::thread> threads_{};
        std::unique_ptr<Tasks> tasks_;
    };
}

#endif //FINDER_THREAD_POOLS_HPP