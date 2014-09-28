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

reference-sender: librelp-build
	gcc -g -Ilibrelp/src -Llibrelp/src/.libs -lrelp -Wl,-rpath,librelp/src/.libs test/sender/send.c -o test/sender/send

mock-receiver:
	docker build -t rsyslog-receiver test/receiver

test-install: test-clean
	cd dist && tar xzvf pyrelp*tar.gz
	cd dist/pyrelp* && pip2 install . --user

test-clean:
	pip2 uninstall -y pyrelp || :

test-relp-clients: reference-sender mock-receiver
	cd test && PATH=~/.local/bin:$$PATH pybot --loglevel=DEBUG test.robot

test: test-install test-relp-clients test-clean


.PHONY: librelp-config manifest-file build reference-sender mock-receiver test-relp-clients test
