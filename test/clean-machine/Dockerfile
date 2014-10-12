FROM ubuntu:precise
VOLUME /rsyslog
RUN apt-get update
RUN apt-get install -y python-pip

# The dependencies of pyrelp
RUN apt-get install -y python-dev
RUN apt-get install -y libgnutls-dev

# Install pyrelp
ADD ./pyrelp.tar.gz /tmp/
RUN pip install /tmp/pyrelp*
