FROM ubuntu:14.04
MAINTAINER Yolanda Robla <info@ysoft.biz>
RUN apt-get update && apt-get install -y git supervisor wget python curl
RUN apt-get install -y python-dev python-pip mysql-client libmysqlclient-dev

# clone the repository
RUN git clone https://github.com/yrobla/scalator.git /home/scalator/
RUN cd /home/scalator && pip install -r /home/scalator/requirements.txt

# add scripts
ADD scripts/scalator /usr/local/bin/
ADD scripts/scalatord /usr/local/bin/
ADD scripts/entrypoint.sh /usr/local/bin/

# create folders
RUN mkdir /etc/scalator
RUN mkdir /etc/scalator/templates
RUN mkdir /var/log/scalator

# add config file
ADD config/scalator.yaml /etc/scalator/scalator.yaml
ADD config/logging.conf /etc/scalator/logging.conf
ADD config/rabbit_config /etc/scalator/templates/rabbit_config

# replace content of template and start running
WORKDIR /home/scalator/
ENV PYTHONPATH $PYTHONPATH:/home/scalator/
CMD /usr/local/bin/entrypoint.sh && /usr/local/bin/scalatord -d
