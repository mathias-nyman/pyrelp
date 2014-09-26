FROM ubuntu:saucy
EXPOSE 20514
VOLUME /rsyslog
RUN echo "deb http://ppa.launchpad.net/adiscon/v8-devel/ubuntu saucy main " >> /etc/apt/sources.list
RUN apt-get update
RUN apt-get -y --force-yes install rsyslog
RUN apt-get -y --force-yes install rsyslog-relp
RUN rm -rf /etc/rsyslog*
ADD ./rsyslog.conf /etc/rsyslog.conf
CMD rsyslogd -dn

