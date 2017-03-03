---
title: "Build development environment with Docker"
date: "2016-04-10T18:58:04Z"
type: "article"
categories: ["Development"]
tags: ["linux", "docker", "environment"]
---

Building reliable and comfortable development environment is not an easy task. Running multiple versions of the same
software might be a hard process. This post illustrates how to build an awesome development environment with Docker.

Docker is an open-source platform that automates development of applications inside software containers.

What advantages might bring using the external tool to manage software on development machine?

  + running multiple versions - usually only a single version (very often it's not the latest version) of application can be found in package manager (example: there's no Oracle MySQL package in ArchLinux packages repository)
  + saving time spent on compiling an application from sources - managing multiple versions of the same software would be time consuming
  + avoiding dependency hell - few versions of the application can be used without introducing any dependency compatibility issue
  + reliability - official Docker images are more reliable than third party repositories.

### Using Docker to install multiple versions of MySQL

MySQL has been used as an example in this post, but the process is almost the same for any kind of software. Details about the
official Docker images for MySQL can be found at [Docker Hub](https://hub.docker.com/_/mysql/) page.

The following dependencies will be required to achieve the goal:

  + [Docker](http://docker.io)
  + [systemd](https://www.freedesktop.org/wiki/Software/systemd/) or equivalent
  + (optional) a build tool ([GNU Make](https://www.gnu.org/software/make/) would match the requirements perfectly) - this
  example uses simple shell scripts.

The first step is to create a directory where the configuration files will be stored - a home directory will be a good choice:
`mkdir -p ~/.docker/mysql/{5.6,5.7}` (the location of the ). As can be see, two MySQL versions will be used for the sake
of example: `5.6` & `5.7`.

Every container requires a Dockerfile so creating those is the second step: `touch ~/.docker/mysql/{5.6,5.7}/Dockerfile`.
Dockerfiles can be opened using any text editor: emacs, vim, gedit and so on.

*~/.docker/mysql/5.6/Dockerfile*
```
FROM mysql:5.6

ENV MYSQL_ALLOW_EMPTY_PASSWORD true

VOLUME /var/lib/mysql/5.6

EXPOSE 3306

CMD ["mysqld"]
```

*~/.docker/mysql/5.7/Dockerfile*
```
FROM mysql:5.7

ENV MYSQL_ALLOW_EMPTY_PASSWORD true

VOLUME /var/lib/mysql/5.7

EXPOSE 3307

CMD ["mysqld"]
```

Some explaination of the Dockerfiles content:

  + `FROM` specifies the image name & image tag used in the following format: `name:tag`
  + `ENV` sets a environment variable - in this example empty root user password is allowed
  + `VOLUME` sets the location of mounted volume as database files should be stored on the host machine
  + `EXPOSE` determines the number of exposed port that will be available from the container host
  + `CMD` sets the default entry point up

As multiple versions of MySQL are used, the volume path and exposed port number both need to be customized. This statement
does not apply when using single instance.

After Dockerfiles are ready an automation technique will be required to build & run the containers. This example uses
simple shell scripts, but any build tool can be used: `touch ~/.docker/mysql/{5.6,5.7}/build.sh`.

*~/.docker/mysql/5.6/build.sh*
```
#!/bin/bash

docker stop mysql-5.6
docker rm mysql-5.6

docker build -t mysql-5.6 .

docker run -d \
	-p 3306:3306 \
	-v /srv/mysql:/var/lib/mysql \
	--name mysql-5.6 \
	mysql-5.6

docker start mysql-5.6
```

*~/.docker/mysql/5.7/build.sh*
```
#!/bin/bash

docker stop mysql-5.7
docker rm mysql-5.7

docker build -t mysql-5.7 .

docker run -d \
	-p 3306:3306 \
	-v /srv/mysql:/var/lib/mysql \
	--name mysql-5.7 \
	mysql-5.7

docker start mysql-5.7
```

Some details about the build scripts:

  + `docker stop` command stops any running container named `mysql-5.6` or `mysql-5.7`
  + `docker rm` removes any existing container with the specified name
  + `docker build` builds a new image with the specified tag - in this example `mysql-5.6` or `mysql-5.7`
  + `docker run` runs a container using previously created image
  + `docker start` starts a newly created container

At this stage MySQL Docker containers are fully functional, accessible from the host machine and storing MySQL user
home directory on the host. There's one issue with the containers - they do not start on the system boot. To start them
an init system or a cron job might be used. In ths post a [systemd](https://en.wikipedia.org/wiki/Systemd) will be used.

*/etc/systemd/system/mysql-5.6.service*
```
[Unit]
Description=MySQL 5.6 Docker container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a mysql-5.6
ExecStop=/usr/bin/docker stop -t 2 mysql-5.6

[Install]
WantedBy=multi-user.target
```

*/etc/systemd/system/mysql-5.7.service*
```
[Unit]
Description=MySQL 5.7 Docker container
Requires=docker.service
After=docker.service

[Service]
Restart=always
ExecStart=/usr/bin/docker start -a mysql-5.7
ExecStop=/usr/bin/docker stop -t 2 mysql-5.7

[Install]
WantedBy=multi-user.target
```

The newly created service units depends on Docker service, so the services will be started always after the `docker` service
has been started. To start on system boot services need to be enabled:
```
sudo systemctl enable mysql-5.6.service
sudo systemctl enable mysql-5.7.service
```

After the services are enabled both MySQL containers should be started after system boot.

This method can be used as a replacement for the default system packages. Personally, I use it on all my development
machines to install software that is not available in the system package repositories as well as to run multiple
versions of the same server (PostgreSQL, MySQL, MongoDB, etc) for all non-dockerized applications I work on.