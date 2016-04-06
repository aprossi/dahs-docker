FROM debian:8.2
MAINTAINER apr
EXPOSE 8080


RUN apt-get install apache2
RUN apt-get install sed
RUN a2enmod cgi

# EDIT /etc/apache2/ports.conf
RUN sed -i '/Listen 80/d' /etc/apache2/ports.conf
RUN echo 'Listen 8080' >> /etc/apache2/ports.conf

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

# FOR TESTING
RUN echo '[general]' >>/etc/gavo.rc
RUN echo 'https://github.com/aprossi/gavo-docker' >>/etc/gavo.rc
RUN echo 'maintainerAddress: <<maintainer_email>>' >>/etc/gavo.rc
RUN echo '[web]' >>/etc/gavo.rc
RUN echo 'bindAddress:' >>/etc/gavo.rc
RUN echo 'serverPort: 8000' >>/etc/gavo.rc
RUN echo 'serverURL: 127.0.0.1' >>/etc/gavo.rc
RUN echo 'preloadRDs: rr/q' >>/etc/gavo.rc
RUN echo 'sitename: <<server_title>>' >>/etc/gavo.rc
RUN echo '[ivoa]' >>/etc/gavo.rc
RUN echo 'authority: <<authority-ivo-name>>' >>/etc/gavo.rc

# images
RUN mkdir /var/gavo/web/nv_static/img
RUN wget -P /var/gavo/web/nv_static/img http://dc.g-vo.org/static/img/logo_medium.png
RUN wget -P /var/gavo/web/nv_static/img http://dc.g-vo.org/static/img/logo_tiny.png
RUN wget -P /var/gavo/web/nv_static/img http://dc.g-vo.org/static/img/logo_large.png

# start Apache and DaHS
RUN apachectl start
RUN gavo serve start

# AWStat
RUN apt-get install awstats


