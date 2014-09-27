pwd:= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: librelp build test

librelp:
	cd librelp &&\
		libtoolize && aclocal && autoconf && autoheader && automake --add-missing && ./configure --enable-debug && make

build: librelp
	python setup.py build

reference-sender:
	gcc -g -Ilibrelp/src -Llibrelp/src/.libs -lrelp -Wl,-rpath,librelp/src/.libs test/sender/send.c -o test/sender/send

test-receiver:
	docker build -t rsyslog-receiver test/receiver

test: reference-sender test-receiver
	cd test && pybot --loglevel=DEBUG test.robot


.PHONY: librelp reference-sender test-receiver test
