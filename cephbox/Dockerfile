# CEPH all in one
#
# VERSION 0.0.1

FROM ubuntu:precise
MAINTAINER Ricardo Rocha, ricardo@catalyst.net.nz

# Base repositories
RUN echo "deb http://nz.archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Workaround for /sbin/init overwrite by docker
# https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

# Base Packages
RUN apt-get install -y wget sudo net-tools vim openssh-server less iputils-ping

# Fake fuse (otherwise package install fails)
# https://gist.github.com/henrik-muehe/6155333
RUN apt-get install libfuse2
RUN cd /tmp ; apt-get download fuse
RUN cd /tmp ; dpkg-deb -x fuse_* .
RUN cd /tmp ; dpkg-deb -e fuse_*
RUN cd /tmp ; rm fuse_*.deb
RUN cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
RUN cd /tmp ; dpkg-deb -b . /fuse.deb
RUN cd /tmp ; dpkg -i /fuse.deb

# Ceph repositories
RUN /usr/bin/wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add -
RUN echo "deb http://ceph.com/debian-emperor/ precise main" > /etc/apt/sources.list.d/ceph.list
RUN apt-get update

# Ceph Packages
RUN apt-get install -y ceph

# Get ports exposed
EXPOSE 6789

ADD ./bootstrap.sh /bootstrap.sh
ADD ./mon.sh /mon.sh
ADD ./osd.sh /osd.sh
ADD ./ceph.conf.sh /ceph.conf.sh

CMD /bootstrap.sh

# Volumes
# dd if=/dev/zero of=/tmp/ceph0 bs=1024000 count=3000
# mkfs.ext4 /tmp/ceph0
# mkdir /tmp/ceph0d
# sudo mount -o loop /tmp/ceph0 /tmp/ceph0d
#
# Build
# sudo docker build -t ceph .
#
# Run
# sudo docker run -h cephbox -i -v /tmp/ceph0d:/var/lib/ceph/osd/ceph-0 -v /tmp/ceph1d:/var/lib/ceph/osd/ceph-1 -p 6789:6789 -t ceph /bin/bash
# ./bootstrap.sh
#
# NOTES:
# Need to update docker config
# vim /etc/init/docker.conf
# ...
# start...
# stop....
# limit nofile 65536 65536
