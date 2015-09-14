FROM debian:jessie
MAINTAINER Amann Malik <amannmalik@gmail.com>

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential wget \
    libncurses-dev libz-dev libssl-dev libxml2-dev libsqlite3-dev uuid-dev uuid \
    libsnmp-dev libiksemel-dev libical-dev libspandsp-dev libsrtp-dev

WORKDIR /tmp

RUN wget --no-check-certificate https://www.kernel.org/pub/linux/kernel/v4.x/linux-$(uname -r | sed 's/\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/').tar.gz \
    && tar -zxvf linux-$(uname -r | sed 's/\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/').tar.gz \
    && wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz \
    && tar -zxvf dahdi-linux-complete-current.tar.gz

RUN mkdir -p /lib/modules/$(uname -r)/build \
    && mv linux-$(uname -r | sed 's/\([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/')/* /lib/modules/$(uname -r)/build \
    && cd /lib/modules/$(uname -r)/build \
    && zcat /proc/config.gz > /lib/modules/$(uname -r)/build/.config \
    && make modules_prepare \
    && cd /tmp/dahdi-linux-complete-* \
    && make && make install && make config \
    && service dahdi start

RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz \
    && tar -zxvf asterisk-13-current.tar.gz

RUN apt-get install --no-install-recommends -y libjansson-dev

RUN cd asterisk-13.* \
    && ./configure && make menuselect.makeopts \
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

RUN rm -rf /tmp/*

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

EXPOSE 5060

ENTRYPOINT asterisk -cvvvvv
