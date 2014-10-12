###--- One Makefile to rule them all ---###

pwd:= $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
test_prefix_path=dist/install

all: build test

librelp-config:
	cd librelp &&\
		libtoolize && aclocal && autoconf && autoheader && automake --add-missing && ./configure --enable-debug

librelp-build: librelp-config
	cd librelp && make

manifest-file:
	echo "include README.md" > MANIFEST.in
	find librelp -name "*.h" -exec echo "include {}" \; >> MANIFEST.in

build: librelp-config manifest-file
	rm -rf build dist pyrelp.egg-info
	python2 setup.py build
	python2 setup.py sdist

upload: build
	python2 setup.py sdist upload

reference-sender: librelp-build
	gcc -g -Ilibrelp/src -Llibrelp/src/.libs -lrelp -Wl,-rpath,librelp/src/.libs test/sender/send.c -o test/sender/send

reference-receiver: librelp-build
	gcc -g -Ilibrelp/src -Llibrelp/src/.libs -lrelp -Wl,-rpath,librelp/src/.libs test/receiver/receive.c -o test/receiver/receive

mock-receiver:
	docker build -t rsyslog-receiver test/receiver

test: reference-sender reference-receiver mock-receiver
	cd test && pybot --loglevel=DEBUG test.robot


.PHONY: librelp-config manifest-file build reference-sender mock-receiver test
