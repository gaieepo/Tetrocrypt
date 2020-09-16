CC=g++
CFLAGS=-O3 -Wall -fPIC -shared -std=c++17 -undefined dynamic_lookup
LDFLAGS=-I./lua51/include

GaiAI.so: GaiAI.o Bot.o lastnodes.o tetris_ai.o genmove.o tetris_gem.o gamepool.o stuff.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

GaiAI.o: GaiAI.cpp
	$(CC) $(CFLAGS) -c $^

Bot.o: Bot.cpp
	$(CC) $(CFLAGS) -c $^

lastnodes.o: lastnodes.cpp
	$(CC) $(CFLAGS) -c $^

tetris_ai.o: tetris_ai.cpp
	$(CC) $(CFLAGS) -c $^

genmove.o: genmove.cpp
	$(CC) $(CFLAGS) -c $^

tetris_gem.o: tetris_gem.cpp
	$(CC) $(CFLAGS) -c $^

gamepool.o: gamepool.cpp
	$(CC) $(CFLAGS) -c $^

stuff.o: stuff.cpp
	$(CC) $(CFLAGS) -c $^

clean:
	-rm  *.so
	-rm  *.o
	-rm -r *.dSYM
