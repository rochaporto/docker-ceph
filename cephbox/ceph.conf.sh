#!/bin/bash
#
# Configures /etc/ceph.conf from a template.
#

echo "
[global]
auth cluster required = cephx
auth service required = cephx
auth client required = cephx

[mon.a]
host = cephbox
mon addr = $1

[osd]
osd journal size = 128 
journal dio = false

[osd.0]
osd host = cephbox
" > /etc/ceph/ceph.conf

