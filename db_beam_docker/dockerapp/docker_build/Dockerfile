FROM ubuntu:16.04

RUN apt-get -y update

RUN  apt-get install -y  \
  gcc \
  make \
  git  \
  wget \
  build-essential \
  devscripts \
  fakeroot \
  debhelper \
  libsystemd-dev \
  curl


RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
RUN dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update -y
RUN apt-get install erlang -y



