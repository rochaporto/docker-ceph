docker-ceph
===========

## Example Setup

### Create fake volumes on the host
```
dd if=/dev/zero of=/tmp/ceph0 bs=1024000 count=3000
mkfs.ext4 /tmp/ceph0
mkdir /tmp/ceph0d
sudo mount -o loop /tmp/ceph0 /tmp/ceph0d
```
```
dd if=/dev/zero of=/tmp/ceph1 bs=1024000 count=3000
mkfs.ext4 /tmp/ceph1
mkdir /tmp/ceph1d
sudo mount -o loop /tmp/ceph1 /tmp/ceph1d
```

### Build the docker image
```
sudo docker build -t ceph .
```

### Create and run a new container instance
```
sudo docker run -h cephbox -i -v /tmp/ceph0d:/var/lib/ceph/osd/ceph-0 -v /tmp/ceph1d:/var/lib/ceph/osd/ceph-1 -p 6789:6789 -t ceph /bin/bash
./bootstrap.sh
```

This will give you a shell inside the container.

### Validation
From the given shell inside the container, check the network information:
```
ifconfig
...
inet addr:172.17.0.15  Bcast:172.17.255.255  Mask:255.255.0.0
...
```
and the client.admin key you'll need to configure the client:
```
ceph auth list
...
client.admin
	key: AQDeKstSIC6GMBAAAmE0rOLITNzDXd8XcH+yaw==
...
```
Do not exit this shell (that would stop the container).

From another shell, configure your client:
```
sudo vim /etc/ceph/ceph.conf
[global]
mon_initial_members = cephbox
mon_host = 172.17.0.15
```
```
sudo vim /etc/ceph/keyring
[client.admin]
	key = AQDeKstSIC6GMBAAAmE0rOLITNzDXd8XcH+yaw==
```

Finally, check the health of the cluster, running the following from the host:
```
ceph health
HEALTH_OK
```

