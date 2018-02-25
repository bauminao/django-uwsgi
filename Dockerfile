# Copyright 2013 Thatcher Peskens
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04

MAINTAINER Dockerfiles

# Install required packages and remove the apt packages cache when done.

RUN apt-get update      \
  && apt-get upgrade -y \ 
  && apt-get install -y \
      git               \
      python            \
      python-dev        \
      python-setuptools \
      python-pip        \
      python-virtualenv \
      supervisor        \
      sqlite3           \
  && pip install -U pip setuptools \
  && rm -rf /var/lib/apt/lists/*

RUN useradd --user-group --create-home --shell /bin/false docker  \
  && mkdir -p /home/docker/logs

USER docker 

# Create virtual environment
RUN cd /home/docker    \
  && virtualenv django

# install uwsgi now because it takes a little while
RUN cd /home/docker/django \
  && . bin/activate        \
  && pip install uwsgi

## setup all the configfiles
COPY supervisor-app.conf /etc/supervisor/conf.d/
COPY uwsgi.ini requirements.txt /home/docker/django/

RUN cd /home/docker/django     \
  && . bin/activate            \
  && pip install -r requirements.txt 

## install django, normally you would remove this step because your project would already
## be installed in the code/app/ directory

RUN cd /home/docker/django \
  && . bin/activate        \
  && django-admin.py startproject app01

## add (the rest of) our code
COPY app01/* /home/docker/django/app01/


EXPOSE 8000
EXPOSE 8001

USER root
CMD ["supervisord", "-n"]
#CMD ["/bin/bash"]

#  && pip install Django   \
#  && django-admin.py startproject mysite \
