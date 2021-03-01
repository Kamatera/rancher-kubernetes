# Persistent Storage

## Create an NFS server

This server will be used as the central storage server for the cluster.

Create a server using the following:

* image: `ubuntu_server_18.04_64-bit_optimized`
* cpu: 1 core
* ram: 2GB
* private lan: same as nodes private lan
* disk size: as much as needed for storage

SSH to the server and setup nfs:

```
apt-get update && apt-get install -y nfs-kernel-server &&\
mkdir -p /srv/default/nfs-client-provisioner &&\
chown -R nobody:nogroup /srv/default &&\
echo '/srv/default 172.16.0.0/23(rw,sync,no_subtree_check,no_root_squash,fsid=0)' > /etc/exports &&\
exportfs -a &&\
systemctl restart nfs-kernel-server
```

## Add NFS Storage Class

A storage class allows to dynamically provision storage for Kubernetes workloads.

Rancher cluster -> Launch kubectl

Set the nfs server internal IP in env var

```
NFS_SERVER_IP=1.2.3.4
```

Download and extract

```
curl -Lso nfs.zip https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/archive/v4.0.0-rc1.zip &&\
unzip nfs.zip &&\
cd nfs-subdir-external-provisioner-4.0.0-rc1/
```

Create storage namespace

```
NAMESPACE=storage &&\
kubectl create ns $NAMESPACE
```

Create RBAC objects

```
sed -i'' "s/namespace:.*/namespace: $NAMESPACE/g" ./deploy/rbac.yaml ./deploy/deployment.yaml &&\
kubectl create -f deploy/rbac.yaml
```

Deploy

```
sed -i'' "s/10.10.10.60/$NFS_SERVER_IP/g" ./deploy/deployment.yaml &&\
sed -i'' "s%/ifs/kubernetes%/nfs-client-provisioner%g" ./deploy/deployment.yaml &&\
kubectl create -f ./deploy/deployment.yaml &&\
kubectl create -f ./deploy/class.yaml
```

## Use the storage class from a workload

Edit or add a new nginx workload (See [Accessing Workloads Externally](Accessing%20Workloads%20Externally.md))

* Add a new persistent volume (claim)
  * Name: `nginx-test-nfs`
  * Use a storage class: `managed-nfs-storage`
  * Capacity: `9999` (it doesn't have any effect but is required)
* Mount point: `/usr/share/nginx/html`
* Save

You should now get a 403 Forbidden error when accessing nginx

SSH to the nfs server, you should have a directory like this:

```
/srv/default/nfs-client-provisioner/default-nginx-pvc-XXXXXXX
```

Create an index.html file inside this directory:

```
echo Hello World > /srv/default/nfs-client-provisioner/default-nginx-pvc-XXXXXXX/index.html
```

You should now see Hello World when accessing the Nginx workload
