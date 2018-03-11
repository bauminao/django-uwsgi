FROM ubuntu:16.04

MAINTAINER Patrick Baumgart <baumi@bauminao.de>

# Try to be as actual as possible and install what will be necessary
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
    apt-utils         \
    curl              \
  && pip install -U pip setuptools \
  && rm -rf /var/lib/apt/lists/*

# Nothing vulnerable needs to run as root, really.
RUN useradd --user-group --create-home --shell /bin/false docker  \
  && mkdir -p /home/docker/logs
USER docker 

# Create virtual environment
RUN cd /home/docker    \
&& virtualenv django

# Create app directory
WORKDIR /home/docker/django

# Install app dependencies
COPY src/requirements.txt ./

RUN cd /home/docker/django     \
  && . bin/activate            \
  && pip install -r requirements.txt 

RUN cd /home/docker/django \
  && . bin/activate        \
  && django-admin.py startproject webapp

# Bundle app source
COPY webapp /home/docker/django/webapp

COPY entrypoint.sh ./

EXPOSE 8080
CMD ["/home/docker/django/entrypoint.sh"]
#CMD [ "python", "webapp/manage.py", "runserver" ]

