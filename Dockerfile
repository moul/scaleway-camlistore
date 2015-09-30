# Copyright 2015 The Camlistore Authors.
# We're using vivid, because it has systemd, which makes it easy to servicify Camlistore.
FROM scaleway/ubuntu:vivid
MAINTAINER Mathieu Lonjaret <mathieu.lonjaret@gmail.com> (@lejatorn)

# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y upgrade

# Install go deps
RUN apt-get -y --no-install-recommends install curl gcc
RUN apt-get -y --no-install-recommends install ca-certificates libc6-dev

# Get Go stable release. need 1.4 first to bootstrap the 1.5 build.
WORKDIR /tmp
RUN curl -O https://storage.googleapis.com/golang/go1.4.2.src.tar.gz
RUN echo '460caac03379f746c473814a65223397e9c9a2f6 go1.4.2.src.tar.gz' | sha1sum -c
RUN tar -C /usr/local -xzf go1.4.2.src.tar.gz
RUN mv /usr/local/go /usr/local/go1.4.2
WORKDIR /usr/local/go1.4.2/src
ENV GOARCH arm
ENV GOOS linux
RUN ./make.bash

WORKDIR /tmp
RUN curl -O https://storage.googleapis.com/golang/go1.5.1.src.tar.gz
RUN echo '0df564746d105f4180c2b576a1553ebca9d9a124 go1.5.1.src.tar.gz' | sha1sum -c
RUN tar -C /usr/local -xzf go1.5.1.src.tar.gz
ENV GOROOT_BOOTSTRAP /usr/local/go1.4.2
WORKDIR /usr/local/go/src
RUN ./make.bash

# Install mysql and deps
RUN apt-get -y --no-install-recommends install mysql-server-core-5.6 mysql-server-5.6
ADD ./patches/lib/systemd/system/camli-mysql.service /lib/systemd/system/camli-mysql.service
ADD ./patches/usr/local/bin/run-mysqld /usr/local/bin/run-mysqld

# Build and install Camlistore
RUN apt-get -y --no-install-recommends install git
WORKDIR /tmp/src
RUN git clone https://camlistore.googlesource.com/camlistore camlistore.org
WORKDIR /tmp/src/camlistore.org
RUN git reset --hard 6dfe405666b7aac69df559b5414b265928a11dbd
ENV PATH $PATH:/usr/local/go/bin
RUN go run make.go
RUN cp -a ./bin/* /usr/local/bin/
ADD ./patches/lib/systemd/system/camlistored.service /lib/systemd/system/camlistored.service
ADD ./patches/etc/update-motd.d/70-camlistore /etc/update-motd.d/70-camlistore

# Add camli user, set up fuse for cammount
RUN adduser --disabled-password --gecos "" camli
RUN apt-get -y --no-install-recommends install fuse
RUN usermod -G fuse camli
# Note: it seems like adding fuse to /etc/modules is useless. It does not have any influence
# on whether the fuse module is inserted on boot. So instead I'm fixing that in camlistore-configure.

ADD ./patches/usr/local/src/camlistore-configure.go /usr/local/src/camlistore-configure.go
ENV GOPATH /tmp/
RUN go build -o /usr/local/bin/camlistore-configure /usr/local/src/camlistore-configure.go

# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave
