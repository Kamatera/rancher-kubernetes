# Persistent Storage

There are many options for providing persistent storage to your Kubernetes cluster. We will cover
a simple option of create a single NFS server, which will provide all storage needs for your cluster.

## Create an NFS server

Because NFS protocol is not secured, you have to connect to it via a private network. Make sure all
your worker nodes which will access the NFS server have access to the private network by setting the
`privateNetworkName` field in the worker node template (as described in [Create a Kubernetes Cluster](#create-a-kubernetes-cluster)).

Use Kamatera console to create a new NFS service with the following configuration:

* datacenter: same as worker nodes datacenter
* image: `nfsserver-ubuntuserver-20.04`
* cpu: 1 core
* ram: 2GB
* disk size: single disk, as much storage size as needed
* network interfaces:
  * public network - must have a public network so that the server will have access to the internal and external IP for SSH
  * private network - the same network as the worker nodes private network

## Add NFS Storage Class

A storage class allows to dynamically provision storage for Kubernetes workloads. 
The [NFS Subdir External Provisioner](https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/blob/master/charts/nfs-subdir-external-provisioner/README.md) 
project handles provisioning of storage to an NFS server.

Cluster explorer -> kubectl shell

Run the following in the kubectl shell to install the provisioner, replace NFS_SERVER_INTERNAL_IP 
with the internal IP of the NFS server:

```
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/ &&\
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=NFS_SERVER_INTERNAL_IP --set nfs.path=/storage
```

You can check deployment progress by checking the `	nfs-subdir-external-provisioner` deployment workload. 

You can now see the storage class in cluster explorer -> storage -> storage classes.

You should see an `nfs-client` storage class, you should set it as the default storage class.

## Use the storage class from a workload

Edit the nginx workload we created in [Accessing Workloads Externally](Accessing%20Workloads%20Externally.md)

* Storage
  * Add volume - create persistent volume claim
    * use a storage class, storage class: `nfs-client`
    * access mode: choose any access mode you want
    * capacity: input required capacity (it is not actually allocated in the NFS server, so it doesn't matter what value you use)
    * mount point: `/usr/share/nginx/html`

When you access the nginx workload via HTTP you should now get a 403 Forbidden error
because the storage does not contain any files for ngins to serve.

SSH to the nfs server

All the provisioned paths will be under `/storage` directory, check the provisioned directory:

```
ls /storage/
```

You should see a directory like `default-test-pvc-858c2c43-1987-4619-9542-efdbb9658d71`

Change to that directory

```
cd /storage/default-test-pvc-858c2c43-1987-4619-9542-efdbb9658d71
```

Create an index.html file:

```
echo Hello World > index.html
```

You should now see Hello World when accessing the Nginx workload

--------------------
#### [Table Of Contents](../README.md) | [Next Page](Monitoring%20and%20Logging.md) ⟶
