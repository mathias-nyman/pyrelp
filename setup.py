from setuptools import setup, Extension
import sysconfig
import sys
import os

def distutils_dir_name(dname):
    f = "{dirname}.{platform}-{version[0]}.{version[1]}"
    return f.format(dirname=dname,
                    platform=sysconfig.get_platform(),
                    version=sys.version_info)

def readme():
    with open('README.md') as f:
        return f.read()

# UglyHack: because default python extension linker uses --as-needed flag,
# which misses gnutls linking
os.environ['CFLAGS'] = '-Wl,--no-as-needed'

# The original librelp library
librelp_sources = ['librelp/src/'+f for f in os.listdir('librelp/src') if f.endswith('.c')]
librelp = ('librelp', {'sources': librelp_sources,
                       'include_dirs' : ['librelp'], # config.h is here
                       'extra_compile_args' : ['-w']}) # librelp has compliation warnings

# Dummy extension in order to build a shared object containing librelp
relp_ext = Extension('relp',
                     sources = ['pyrelp/relpmodule.c'],
                     include_dirs = ['librelp/src'],
                     libraries = ['gnutls', 'rt'],
                     extra_objects = ['build/' + distutils_dir_name('temp') + '/librelp/src/relp.o'])

setup(name='pyrelp',
      version='0.6',
      description='A python wrapper of librelp',
      long_description=readme(),
      url='https://github.com/mathias-nyman/pyrelp',
      author='Mathias Nyman',
      author_email=None,
      license='GPLv3',
      packages=['pyrelp'],
      package_dir={'pyrelp' : 'pyrelp'},
      scripts=['bin/pyrelp'],
      libraries=[librelp],
      ext_modules = [relp_ext],
      include_package_data=True,
      zip_safe=False)

