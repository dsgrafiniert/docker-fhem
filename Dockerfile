FROM avastsoftware/alpine-perl-extended

MAINTAINER Dominik Schoen

ENV FHEM_VERSION 5.8
RUN echo "http://1ot.jp/alpine-iot/v3.5" >> /etc/apk/repositories
RUN wget -P /etc/apk/keys http://1ot.jp/alpine-iot/keys/takesako@namazu.org-587ad2bb.rsa.pub

RUN apk update
RUN apk add --update avrdude \
                     perl-device-serialport \
                     perl-io-socket-ssl \
                     perl-libwww \
                     perl-xml-simple \
                     perl-json \
                     perl-net-telnet \
                     python \
                     wget \
                     build-base \ 
                     autoconf \
                     re2c \
                     libtool


RUN mkdir -p /opt 
RUN cd /opt
RUN wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz 
RUN tar xzf libiconv-1.15.tar.gz 
RUN cd libiconv-1.15 && ls && ./configure --prefix=/usr/local && make && make install 
RUN rm -rf libiconv-1.15 && rm libiconv-1.15.tar.gz
        
# install perl modules for xmltv
RUN cpanm LWP::Simple
RUN cpanm MIME::Base64
RUN cpanm HTTP::Request
RUN cpanm HTML::TableExtract
RUN cpanm HTML::Parse
RUN cpanm Digest::MD5
RUN cpanm Date::Parse
RUN cpanm SOAP::Lite
RUN cpanm JSON::XS
RUN cpanm Imager::Color
RUN cpanm IO::Socket::Multicast
RUN cpanm RiveScript
RUN cpanm Net::MQTT::Simple
RUN cpanm Net::MQTT::Constants

RUN mkdir -p /opt/fhem && \
    addgroup fhem && \
    adduser -D -G fhem -h /opt/fhem -u 1000 fhem

RUN adduser fhem dialout

VOLUME /opt/fhem

ADD http://fhem.de/fhem-${FHEM_VERSION}.tar.gz /usr/local/lib/fhem.tar
RUN cd /opt && tar xf /usr/local/lib/fhem.tar
RUN echo 'attr global nofork 1\n' >> /opt/fhem-${FHEM_VERSION}/fhem.cfg

EXPOSE 8083 8084 8085 7072

COPY ./fhem.sh /usr/local/bin/fhem.sh
RUN chmod a+x /usr/local/bin/fhem.sh

RUN wget -O /usr/local/bin/speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py
RUN chmod +x /usr/local/bin/speedtest-cli

RUN wget -O /usr/local/lib/Text-Iconv-1.7.tar.gz http://search.cpan.org/CPAN/authors/id/M/MP/MPIOTR/Text-Iconv-1.7.tar.gz
RUN cd /usr/local/lib && tar zxf Text-Iconv-1.7.tar.gz && cd Text-Iconv-1.7 && perl Makefile.PL LIBS='-L/usr/local' && make && make install

RUN apk add --update openssh \
                     sshpass
RUN rm -rf /var/cache/apk/*
WORKDIR /opt/fhem

USER fhem

ENTRYPOINT ["/usr/local/bin/fhem.sh"]
