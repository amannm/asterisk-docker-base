FROM debian:jessie
MAINTAINER Amann Malik <amannmalik@gmail.com>

RUN apt-get update

RUN apt-get install --no-install-recommends -y build-essential bc libssl-dev wget

WORKDIR /lib/modules

RUN mkdir -p $(uname -r) \
    && cd $(uname -r) \
    && wget --no-check-certificate https://www.kernel.org/pub/linux/kernel/v4.x/linux-$(uname -r | sed 's/\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/').tar.gz \
    && tar -zxvf linux-*.tar.gz \
    && rm -f linux-*.tar.gz \
    && mv linux-* build \
    && cd build \
    && zcat /proc/config.gz > .config \
    && make modules_prepare

WORKDIR /tmp

RUN wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz \
    && tar -zxvf dahdi-linux-complete-current.tar.gz \
    && rm -f dahdi-linux-complete-current.tar.gz \
    && cd dahdi-linux-complete-* \
    && make \
    && make install \
    && make config \
    && service dahdi start

RUN apt-get install --no-install-recommends -y \
    libncurses-dev libz-dev libxml2-dev libsqlite3-dev uuid-dev uuid libjansson-dev \
    libsnmp-dev libiksemel-dev libical-dev libspandsp-dev libsrtp-dev

RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz \
    && tar -zxvf asterisk-13-current.tar.gz \
    && rm -f asterisk-13-current.tar.gz \
    && cd asterisk-13.* \
    && ./configure \
    && make menuselect.makeopts \
    && menuselect/menuselect \
        --enable CORE-SOUNDS-EN-WAV \
        --enable CORE-SOUNDS-EN-G722 \
        --enable CORE-SOUNDS-EN-ULAW \
        --enable CORE-SOUNDS-EN-GSM \
        --enable MOH-OPSOUND-WAV \
        --enable MOH-OPSOUND-G722 \
        --enable MOH-OPSOUND-ULAW \
        --enable MOH-OPSOUND-GSM \
        --enable EXTRA-SOUNDS-EN-WAV \
        --enable EXTRA-SOUNDS-EN-G722 \
        --enable EXTRA-SOUNDS-EN-ULAW \
        --enable EXTRA-SOUNDS-EN-GSM \
        menuselect.makeopts \
    && make install \
    && make config

WORKDIR /var/lib/asterisk/sounds

RUN wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz \
    && tar xfz asterisk-extra-sounds-en-wav-current.tar.gz \
    && rm -f asterisk-extra-sounds-en-wav-current.tar.gz

RUN wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-g722-current.tar.gz \
    && tar xfz asterisk-extra-sounds-en-g722-current.tar.gz \
    && rm -f asterisk-extra-sounds-en-g722-current.tar.gz

RUN wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-ulaw-current.tar.gz \
    && tar xfz asterisk-extra-sounds-en-ulaw-current.tar.gz \
    && rm -f asterisk-extra-sounds-en-ulaw-current.tar.gz

RUN wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-gsm-current.tar.gz \
    && tar xfz asterisk-extra-sounds-en-gsm-current.tar.gz \
    && rm -f asterisk-extra-sounds-en-gsm-current.tar.gz

ADD asterisk /etc/asterisk

EXPOSE 5060

ENTRYPOINT asterisk -cvvvvv
