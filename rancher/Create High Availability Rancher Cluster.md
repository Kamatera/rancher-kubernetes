# Create High Availability Rancher Cluster

This will install Rancher 2.4 on a K3S cluster:

* [Set up Infrastructure for a High Availability K3s Kubernetes Cluster](https://rancher.com/docs/rancher/v2.x/en/installation/resources/k8s-tutorials/infrastructure-tutorials/infra-for-ha-with-external-db/)
* [Setting up a High-availability K3s Kubernetes Cluster for Rancher](https://rancher.com/docs/rancher/v2.x/en/installation/resources/k8s-tutorials/ha-with-external-db/)
* [Install Rancher on a Kubernetes Cluster](https://rancher.com/docs/rancher/v2.x/en/installation/install-rancher-on-k8s/)
    * **Use the stable Helm repo with Rancher version 2.4.X**

## Add the Kamatera Docker Machine driver

Rancher web UI -> Tools -> Node Driver -> Add

Set Driver URL: `https://github.com/Kamatera/docker-machine-driver-kamatera/releases/download/v1.1.2/docker-machine-driver-kamatera_v1.1.2_linux_amd64.tar.gz`
