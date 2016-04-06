FROM debian:8.2
MAINTAINER apr

RUN apt-get install apache2
RUN a2enmod cgi

# pico /etc/apache2/ports.conf
# Listen 8080

RUN service apache2 restart

RUN echo '# DaCHS repository' >> /etc/apt/sources.list 
RUN echo 'deb http://vo.ari.uni-heidelberg.de/debian stable main' >> /etc/apt/sources.list
RUN echo 'deb-src http://vo.ari.uni-heidelberg.de/debian stable main' >> /etc/apt/sources.list
RUN wget -qO - http://docs.g-vo.org/archive-key.asc | sudo apt-key add - 

RUN apt-get update
RUN apt-get upgrade

RUN apt-get install gavodachs-server
RUN apachectl stop

RUN cp /var/gavo/etc/trustedquery /var/gavo/etc/untrustedquery 

RUN echo '[general]'>>/etc/gavo.rc 

