obj-m += king_of_curses.o

KDIR ?= /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$(PWD) modules

clean:
	$(MAKE) -C $(KDIR) M=$(PWD) clean

install:
	$(MAKE) -C $(KDIR) M=$(PWD) modules_install
	depmod -a

test:
	insmod king_of_curses.ko enabled=1
	dmesg | tail -20
	rmmod king_of_curses

.PHONY: all clean install test
