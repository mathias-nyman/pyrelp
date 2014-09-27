from setuptools import setup

def readme():
    with open('README.md') as f:
        return f.read()

setup(name='pyrelp',
      version='0.1',
      description='A python wrapper of librelp',
      long_description=readme(),
      url='https://github.com/mathias-nyman/pyrelp',
      author='Mathias Nyman',
      author_email=None,
      license='GPLv3',
      packages=['pyrelp'],
      scripts=['bin/pyrelp'],
      include_package_data=True,
      zip_safe=False)

