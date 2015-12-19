FROM debian:jessie
MAINTAINER Amann Malik <amannmalik@gmail.com>

RUN apt-get update

RUN apt-get install --no-install-recommends -y build-essential wget

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

RUN apt-get install --no-install-recommends -y libncurses-dev libz-dev libssl-dev libxml2-dev libsqlite3-dev uuid-dev uuid libjansson-dev

RUN wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-13-current.tar.gz \
    && tar -zxvf asterisk-13-current.tar.gz \
    && rm -f asterisk-13-current.tar.gz \
    && cd asterisk-13.* \
    && ./configure \
    && make menuselect.makeopts \
    && make install \
    && make config

WORKDIR /var/lib/asterisk/sounds

RUN wget http://downloads.asterisk.org/pub/telephony/sounds/asterisk-extra-sounds-en-wav-current.tar.gz \
    && tar -zxvf asterisk-extra-sounds-en-wav-current.tar.gz \
    && rm -f asterisk-extra-sounds-en-wav-current.tar.gz

EXPOSE 5060

ENTRYPOINT asterisk -cvvvvv
