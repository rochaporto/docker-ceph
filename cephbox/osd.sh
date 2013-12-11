#!/bin/bash
#
# Configures and launches a new OSD.
#

ceph osd create
ceph-osd -i $1 --mkfs --mkkey
ceph auth add osd.$1 osd 'allow *' mon 'allow rwx' -i /var/lib/ceph/osd/ceph-$1/keyring
ceph osd crush add $1 1 root=default host=cephbox
ceph-osd -i $1 -k /var/lib/ceph/osd/ceph-$1/keyring
