FROM avastsoftware/alpine-perl-extended

MAINTAINER Dominik Schoen

ENV FHEM_VERSION 5.8

RUN apk add --update perl-device-serialport \
                     perl-io-socket-ssl \
                     perl-libwww \
                     perl-xml-simple \
                     perl-json \
                     perl-net-telnet \
        && rm -rf /var/cache/apk/*
        
# install perl modules for xmltv
RUN cpanm LWP::Simple
RUN cpanm MIME::Base64
RUN cpanm HTTP::Request
RUN cpnam LWP::UserAgent
RUN cpanm HTML::Parse
RUN cpanm Digest::MD5
RUN cpanm Date::Parse
RUN cpanm SOAP::Lite
RUN cpanm JSON::XS
RUN cpanm Imager::Color

RUN mkdir -p /opt/fhem && \
    addgroup fhem && \
    adduser -D -G fhem -h /opt/fhem -u 1000 fhem

VOLUME /opt/fhem

ADD http://fhem.de/fhem-${FHEM_VERSION}.tar.gz /usr/local/lib/fhem.tar
RUN cd /opt && tar xvf /usr/local/lib/fhem.tar
RUN echo 'attr global nofork 1\n' >> /opt/fhem-5.7/fhem.cfg

EXPOSE 8083 8084 8085 7072

COPY ./fhem.sh /usr/local/bin/fhem.sh
RUN chmod a+x /usr/local/bin/fhem.sh

WORKDIR /opt/fhem

USER fhem

ENTRYPOINT ["/usr/local/bin/fhem.sh"]
