FROM golang:1.4

# Copied straight from the golang:1.4-cross Dockerfile, but reducing the number of platforms
RUN cd /usr/src/go/src \
    && set -ex \
    && for GOOS in darwin linux; do \
        GOOS=$GOOS ./make.bash --no-clean 2>&1; \
    done

RUN apt-get update && apt-get install -y \
                                cpio \
                                file \
                                gcc \
                                g++ \
                                libssl-dev \
                                libxml2-dev \
                                make \
                                rpm \
                                rsyslog \
                                ruby \
                                ruby-dev

RUN gem install fpm --no-rdoc --no-ri

RUN cd /tmp && wget https://github.com/google/protobuf/releases/download/v2.6.1/protobuf-2.6.1.tar.gz && tar -zxvf protobuf-2.6.1.tar.gz > /dev/null && cd protobuf-2.6.1 && ./configure --prefix=/usr > /dev/null && make > /dev/null && make install > /dev/null && rm -rf /tmp/protobuf-2.6.1 protobuf-2.6.1.tar.gz

# Avoid using ssh to get the repos
#RUN git config --global url."https://github.com/".insteadOf "git@github.com:"

WORKDIR /tmp
# Get dependencies for building hologram
RUN go get github.com/jteeuwen/go-bindata/...
RUN git clone https://github.com/pote/gpm.git && cd gpm && ./configure && make install && rm -rf /tmp/gpm
RUN wget http://xar.googlecode.com/files/xar-1.5.2.tar.gz && tar xf xar-1.5.2.tar.gz && cd xar-1.5.2 && ./configure && make && make install && rm -rf /tmp/xar-1.5.2
RUN git clone https://github.com/hogliux/bomutils.git > /dev/null && cd bomutils && make > /dev/null && make install  > /dev/null && rm -rf /tmp/bomutils

ENV HOLOGRAM_DIR /go/src/github.com/AdRoll/hologram
ENV BUILD_SCRIPTS ${HOLOGRAM_DIR}/buildscripts
ENV PATH ${BUILD_SCRIPTS}:$PATH
ENV BIN_DIR /go/bin
WORKDIR /go/src/github.com/AdRoll/hologram

VOLUME ["/go/src/github.com/AdRoll/hologram"]

ENTRYPOINT ["start.sh"]
