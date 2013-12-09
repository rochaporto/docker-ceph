# CEPH all in one
#
# VERSION 0.0.1

FROM ubuntu:precise
MAINTAINER Ricardo Rocha, ricardo@catalyst.net.nz

# Base repositories
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list

# Workaround for /sbin/init overwrite by docker
# https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

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

# Base Packages
RUN apt-get update && apt-get install -y wget sudo net-tools vim openssh-server less

# Ceph repositories
RUN /usr/bin/wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | sudo apt-key add -
RUN echo "deb http://ceph.com/debian-emperor/ precise main" > /etc/apt/sources.list.d/ceph.list
RUN apt-get update

# Ceph Packages
RUN apt-get install -y ceph

# Get ports exposed
EXPOSE 6789

# Put in the basic config
RUN echo "[global]\nauth cluster required = cephx\nauth service required = cephx\nauth client required = cephx\n\n[osd]\nosd journal size = 1000\n\n[mon.a]\nhost = cephbox\nmon addr = 172.17.0.186\n\n[osd.0]\nhost = ceph.example.com" > /etc/ceph/ceph.conf

#
# Below are the steps required to bootstrap the monitor
# For a new box this cannot go in the image as i can't get lxc to take a fixed IP
#

# Manually create a monmap (as we have no monitor yet)
monmaptool --create --clobber --fsid `uuidgen` --add a 172.17.0.186:6789 /etc/ceph/monmap

# Add keyrings for both the mon. (which is the one all mons should have) and a client.admin
ceph-authtool --create-keyring /var/lib/ceph/mon/keyring --gen-key -n mon.
ceph-authtool /var/lib/ceph/mon/keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *'

# Setup the dir and keyring for our 'a' mon
mkdir /var/lib/ceph/mon/ceph-a
cp /var/lib/ceph/mon/keyring /var/lib/ceph/mon/ceph-a

# Initialize the fs for our new 'a' mon
ceph-mon -i a --mkfs --monmap /etc/ceph/monmap -k /var/lib/ceph/mon/ceph-a/keyring

# Launch the monitor
ceph-mon -i a --mon-data /var/lib/ceph/mon/ceph-a

# NOTES:
# Need to update docker config
# vim /etc/init/docker.conf
# ...
# start...
# stop....
# limit nofile 65536 65536
