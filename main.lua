-- Debug
Inspect = require 'libraries/inspect/inspect'

-- Libraries
fn = require 'libraries/Moses/moses'
Stateful = require 'libraries/stateful/stateful'
Input = require 'libraries/boipushy/Input'
Timer = require 'modules/TimerEx'
class = require 'libraries/middleclass/middleclass'

require 'globals'
require 'utils'
require 'entity'
require 'game'

require 'field'
require 'piece'
require 'preview'
require 'stat'
require 'hold'

function love.load()
  -- Main Env

  -- Global Input Handler
  input = Input()

  game = Game:new()
end

function love.update(dt)
  -- Timer.update(dt) -- global timer
  game:update(dt)
end

function love.draw()
  game:draw()
end

-- function love.keypressed(key, scancode, isrepeat)
--   game:keypressed(key, scancode, isrepeat)
--   -- love.keyboard.setKeyRepeat(false)
-- end

function love.run()
  -- Random Seed (optional)
  -- math.randomseed(default_seed or os.time())
  -- if love.math then love.math.setRandomSeed(default_seed or os.time()) end

  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

  -- We don't want the first frame's dt to include time taken by love.load.
  if love.timer then love.timer.step() end

  local dt = 0
  -- local fixed_dt = 1/60
  -- local accumulator = 0

  -- Main loop time.
  return function()
    -- Process events.
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == 'quit' then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end

    -- Update dt, as we'll be passing it to update
    if love.timer then dt = love.timer.step() end

    -- Call update and draw
    -- accumulator = accumulator + dt
    -- while accumulator >= fixed_dt do
    --     if love.update then love.update(fixed_dt) end
    --     accumulator = accumulator - fixed_dt
    -- end
    if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())
      if love.draw then love.draw() end
      love.graphics.present()
    end

    if love.timer then love.timer.sleep(0.001) end
  end
end
