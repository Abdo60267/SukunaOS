CC = gcc
CFLAGS = -Wall -Wextra -O2

all: cursectl

cursectl: cursectl.c
	$(CC) $(CFLAGS) -o cursectl cursectl.c

install: cursectl
	install -D -m 755 cursectl /usr/local/bin/cursectl

clean:
	rm -f cursectl

test: cursectl
	./cursectl status
	./cursectl policy add 1234 --sandbox --no-network
	./cursectl domain create test-domain

.PHONY: all install clean test
