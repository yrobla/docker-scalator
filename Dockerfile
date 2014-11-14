FROM ubuntu:14.04
MAINTAINER Yolanda Robla <info@ysoft.biz>
RUN apt-get update && apt-get install -y git supervisor wget python curl
RUN apt-get install -y python-dev

# clone the repository
RUN git clone https://github.com/yrobla/scalator.git /home/
RUN python2.7 /home/scalator/setup.py install

