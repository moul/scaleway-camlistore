# Copyright 2015 The Camlistore Authors.
FROM armbuild/scw-distrib-ubuntu:trusty
MAINTAINER Mathieu Lonjaret <mathieu.lonjaret@gmail.com> (@lejatorn)

# Prepare rootfs for image-builder
RUN /usr/local/sbin/builder-enter

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get -y upgrade

# Install mysql and deps
RUN apt-get -y install mysql-server-core-5.5 mysql-server-5.5

# Patch rootfs
# ADD ./patches/etc/ /etc/
ADD ./patches/usr/local/ /usr/local/ # for run-mysqld

# Install go deps
RUN apt-get -y --no-install-recommends install curl gcc
RUN apt-get -y --no-install-recommends install ca-certificates libc6-dev

# Get Go stable release. need 1.4 first to bootstrap the 1.5 build.
WORKDIR /tmp
RUN curl -o go1.4.2.src.tar.gz https://storage.googleapis.com/golang/go1.4.2.src.tar.gz
RUN echo '460caac03379f746c473814a65223397e9c9a2f6 go1.4.2.src.tar.gz' | sha1sum -c
RUN tar -C /usr/local -xzf go1.4.2.src.tar.gz
RUN mv /usr/local/go /usr/local/go1.4.2
WORKDIR /usr/local/go1.4.2/src
ENV GOARCH arm
ENV GOOS linux
RUN ./make.bash

WORKDIR /tmp
RUN curl -o go1.5.1.src.tar.gz https://storage.googleapis.com/golang/go1.5.1.src.tar.gz
RUN echo '0df564746d105f4180c2b576a1553ebca9d9a124 go1.5.1.src.tar.gz' | sha1sum -c
RUN tar -C /usr/local -xzf go1.5.1.src.tar.gz
ENV GOROOT_BOOTSTRAP /usr/local/go1.4.2
WORKDIR /usr/local/go/src
RUN ./make.bash

# Clean rootfs from image-builder
RUN /usr/local/sbin/builder-leave
