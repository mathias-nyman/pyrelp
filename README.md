PyRELP
===

A python wrapper of librelp.

Overview
===

This is a wrapper of the [librelp](http://www.librelp.com/) library. So far
only the client functionality is wrapped.

Pyrelp uses *ctypes* for accessing the *librelp* C functions directly. So
technically this is not a python module of pyrelp, but a wrapper.

The C sources of *librelp* are included in the source distribution package and
will be built by *setuptools* when installing with e.g. pip.

Only *python2* is supported, since dummy extension module is lacking *python3*
support for now.


Development & Testing
===

Run:
> make

