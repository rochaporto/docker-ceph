#!/bin/bash
#
# Bootstraps a CEPH monitor, and launches the services.
#

sh ./ceph.conf.sh `hostname -i`

sh ./mon.sh `hostname -i`

sh ./osd.sh 0
sh ./osd.sh 1
