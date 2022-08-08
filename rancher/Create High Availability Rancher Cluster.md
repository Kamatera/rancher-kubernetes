# Create High Availability Rancher Cluster

Following are recommended Rancher documentations to install a Rancher 2.6 High-Availablity cluster.

This is a complex task, you should refer to the [Rancher 2.6 documentation](https://rancher.com/docs/rancher/v2.6/en/) for other installation
methods and considerations before deciding how to proceed.

* [Set up Infrastructure for a High Availability K3s Kubernetes Cluster](https://rancher.com/docs/rancher/v2.6/en/installation/resources/k8s-tutorials/ha-with-external-db/)
* [Install Rancher on a Kubernetes Cluster](https://rancher.com/docs/rancher/v2.6/en/installation/install-rancher-on-k8s/)

## Add the Kamatera Docker Machine driver

Rancher Web UI -> Cluster Management -> Drivers -> Node Drivers -> Add

Set Download URL: `https://github.com/Kamatera/docker-machine-driver-kamatera/releases/download/v1.1.4/docker-machine-driver-kamatera_v1.1.4_linux_amd64.tar.gz`

--------------------
#### [Table Of Contents](../README.md) | [Next Page](Create%20Kubernetes%20Cluster.md) ⟶
