FROM debian:8
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

RUN rm /etc/apache2/sites-enabled/000-default.conf
RUN echo '<VirtualHost *:8080>' > /etc/apache2/sites-enabled/000-default.conf
RUN echo '' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '       ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '       <Directory "/usr/lib/cgi-bin">' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '               Options FollowSymLinks' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '               AddHandler cgi-script  .pl' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '               AllowOverride None' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '              Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '               Order allow,deny' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '               Allow from all' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '       </Directory>' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '       ErrorLog ${APACHE_LOG_DIR}/error.log' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '       CustomLog ${APACHE_LOG_DIR}/access.log combined' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '' >> /etc/apache2/sites-enabled/000-default.conf
RUN echo '</VirtualHost>' >> /etc/apache2/sites-enabled/000-default.conf

# # EDIT /etc/awstats/awstats.conf

RUN sed -i '/LogFile=/d' /etc/awstats/awstats.conf
RUN echo 'LogFile="/usr/share/awstats/tools/logresolvemerge.pl /var/log/apache2/access.log* |"' >> /etc/awstats/awstats.conf

RUN sed -i '/LogFormat=/d' /etc/awstats/awstats.conf
RUN echo 'LogFormat=1' >> /etc/awstats/awstats.conf

RUN sed -i '/SiteDomain=/d' /etc/awstats/awstats.conf
RUN echo 'SiteDomain="<<my_servername>>.<<my_domain>>"' >> /etc/awstats/awstats.conf

RUN sed -i '/HostAliases=/d' /etc/awstats/awstats.conf
RUN echo 'DNSLookup=2' >> /etc/awstats/awstats.conf

RUN sed -i '/DNSLookup=/d' /etc/awstats/awstats.conf
RUN echo 'LogFormat=1' >> /etc/awstats/awstats.conf

RUN sed -i '/AllowFullYearView=/d' /etc/awstats/awstats.conf
RUN echo 'AllowFullYearView=3' >> /etc/awstats/awstats.conf

RUN sed -i 'SkipHosts=/d' /etc/awstats/awstats.conf
RUN echo 'SkipHosts="145.238.187.13 145.238.187.29"' >> /etc/awstats/awstats.conf

# EDIT awstats.dachs.conf
RUN cp /etc/awstats/awstats.conf /etc/awstats/awstats.dachs.conf
RUN sed -i 'LogFile=/d' /etc/awstats/awstats.dachs.conf
RUN echo 'LogFile="/usr/share/awstats/tools/logresolvemerge.pl /var/gavo/logs/web.log* |"' >> /etc/awstats/awstats.conf
RUN sed -i 'LogFormat=/d' /etc/awstats/awstats.dachs.conf
RUN echo 'LogFormat="%other %other %other %host %other %other %time1 %methodurl %code %bytesd %refererquot %uaquot"' >> /etc/awstats/awstats.conf
RUN sed -i 'URLWithQuery=/d' /etc/awstats/awstats.dachs.conf
RUN echo 'URLWithQuery=1' >> /etc/awstats/awstats.conf

# EDIT /usr/local/bin/run_awstats

RUN echo '#!/bin/bash' >> /usr/local/bin/run_awstats
RUN echo '/usr/bin/perl /usr/lib/cgi-bin/awstats.pl -config=dachs -update' >> /usr/local/bin/run_awstats
RUN echo '/usr/bin/perl /usr/lib/cgi-bin/awstats.pl -config=apache -update' >> /usr/local/bin/run_awstats
RUN chmod 777 /usr/local/bin/run_awstats

# crontab entries TBA ...








