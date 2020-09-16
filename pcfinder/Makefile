CC=g++
CFLAGS=-O3 -Wall -fPIC -shared -std=c++17 -undefined dynamic_lookup
LDFLAGS=-I /opt/local/include -L /opt/local/lib -I./lua51/include
LDLIBS=-lboost_system-mt -lboost_filesystem-mt -lboost_thread-mt -lpthread

PCFinder.so: PCFinder.cpp flag.cpp \
	core/bits.cpp core/field.cpp core/moves.cpp core/piece.cpp core/srs.cpp \
	finder/frames.cpp finder/perfect_clear.cpp finder/two_lines_pc.cpp
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

clean:
	-rm *.so
	-rm *.o
	-rm -r *.dSYM
