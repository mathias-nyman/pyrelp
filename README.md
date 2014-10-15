[![Build Status](https://travis-ci.org/mathias-nyman/pyrelp.svg?branch=master)](https://travis-ci.org/mathias-nyman/pyrelp)

PyRELP
===

A python wrapper of librelp.


Overview
===

This is a wrapper of the [librelp](http://www.librelp.com/) library.

Pyrelp uses *ctypes* for accessing the *librelp* C functions directly. So
technically this is not a python module of pyrelp, but a wrapper.

The C sources of *librelp* are included in the source distribution package and
will be built by *setuptools* when installing with e.g. pip.

Only *python2* is supported, since dummy extension module is lacking *python3*
support for now.


Client
---

Send a message to a RELP server:

    > pyrelp <ip> <port> <msg>



Server
---

There is no default server implementation. Use the `Server` class to implement
one.

Example RELP Server:

```python
from pyrelp import pyrelp

def rcv(host, ip, msg):
    print(msg)

s = pyrelp.Server(20514, rcv)
s.run()
```


Development & Testing
===

Run:

    > make


Dependencies
---

autotools
libtool
docker
robotframework

