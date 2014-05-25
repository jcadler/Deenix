CC=gcc
CFLAGS=-g -c
DC=gdc
DFLAGS=-nophoboslib -g -c

all: dummy.o slab.o main.o object.o
	ld -lc $^

clean:
	rm *.o

dummy.o: dummy.c
	 $(CC) $(CFLAGS) $< -o $@

slab.o: slab.d
	$(DC) $(DFLAGS) $< -o $@

main.o: main.c
	$(CC) $(CFLAGS) $< -o $@

object.o: object.d
	  $(DC) $(DFLAGS) $< -o $@
