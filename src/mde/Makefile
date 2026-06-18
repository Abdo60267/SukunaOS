CC = gcc
CFLAGS = -Wall -Wextra -O2 -fPIC $(shell pkg-config --cflags wayland-server)
LDFLAGS = $(shell pkg-config --libs wayland-server)

SRCS = mde_core.c
OBJS = $(SRCS:.c=.o)
TARGET = mde-core

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)

install: $(TARGET)
	install -D -m 755 $(TARGET) /usr/local/bin/$(TARGET)

.PHONY: all clean install
