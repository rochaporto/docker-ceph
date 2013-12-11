#!/bin/bash
#
# Configures and launches a new MON.
#

# monitor setup
monmaptool --create --clobber --fsid `uuidgen` --add a $1:6789 /etc/ceph/monmap
ceph-authtool --create-keyring /var/lib/ceph/mon/keyring --gen-key -n mon.
ceph-authtool /var/lib/ceph/mon/keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *'
mkdir /var/lib/ceph/mon/ceph-a
cp /var/lib/ceph/mon/keyring /var/lib/ceph/mon/ceph-a
ceph-mon -i a --mkfs --monmap /etc/ceph/monmap -k /var/lib/ceph/mon/ceph-a/keyring
ceph-mon -i a --monmap /etc/ceph/monmap -k /var/lib/ceph/mon/ceph-a/keyring

# client setup (handy)
cp /var/lib/ceph/mon/keyring /etc/ceph

# for this test we want to 
ceph osd getcrushmap -o /tmp/crushc
crushtool -d /tmp/crushc -o /tmp/crushd
sed -i 's/step chooseleaf firstn 0 type host/step chooseleaf firstn 0 type osd/' /tmp/crushd
crushtool -c /tmp/crushd -o /tmp/crushc
ceph osd setcrushmap -i /tmp/crushc
