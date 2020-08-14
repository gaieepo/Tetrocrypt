CC=g++
CFLAGS=-O3 -Wall -fPIC -shared -std=c++17 -undefined dynamic_lookup
boosts=-I /opt/local/include -L /opt/local/lib -lboost_system-mt -lboost_filesystem-mt -lboost_thread-mt -lpthread
header_path=-I./lua51/include

PCFinder.so: PCFinder.cpp flag.cpp \
	core/bits.cpp core/field.cpp core/moves.cpp core/piece.cpp core/srs.cpp \
	finder/frames.cpp finder/perfect_clear.cpp finder/two_lines_pc.cpp
	$(CC) $(CFLAGS) $(header_path) $(boosts) -o $@ $^

clean:
	-rm *.so
	-rm *.o
	-rm -r *.dSYM
