# Cluster Autoscaler

The cluster autoscaler is a component that automatically adjusts the size of the cluster based 
on the current workload. It is an advanced feature that requires complex configuration and
testing, so it is not recommended for beginners. Many clusters can work fine without it, relying
on manual scaling via the Rancher UI.

[Cluster Autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/README.md) 
is a standard Kubernetes component which includes support for many cloud providers, including
Kamatera. The following guide will show you how to setup the cluster autoscaler for your cluster.

## Installation

First, we will create a secret containing the autoscaler configuration. This secret will be
used by the autoscaler to connect to Kamatera and manage the cluster autoscaling.

There are many options for the autoscaler configuration, the following is a minimal example
with simple defaults, you should refer to the 
[Cluster Autoscaler Kamatera Configuration](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/kamatera/README.md#configuration)
for more details.

Create a secret via the Rancher web UI -> Explore Cluster -> Cluster Name -> Storage -> Secrets -> Create

* Secret Type: Opaque
* Namespace: `kube-system`
* Name: `cluster-autoscaler-kamatera`
* Data Key: `cloud-config`, for Value paste the following basic configuration and see the comments for values to modify:

```
[global]
; set your Kamatera API token which will be used to connect to manage Kamatera nodes
kamatera-api-client-id=1a222bbb3ccc44d5555e6ff77g88hh9i
kamatera-api-secret=9ii88h7g6f55555ee4444444dd33eee2
; set a unique cluster name, this is used to identify the cluster by the autoscaler
; in case there are multiple autoscalers running on the same Kamatera account
cluster-name=aaabbb

; the autoscaler manages nodes within node groups defined here
; these node groups are defined by the autoscaler and are not related to Rancher node pools
[nodegroup "ng1"]
; a prefix for the node group name, the autoscaler will add a unique suffix to this prefix
name-prefix=ng1
; the minimum number of nodes in the node group, can also be set to 0 to allow the autoscaler to scale down to 0 nodes
min-size=1
; the maximum number of nodes in the node group
max-size=5
; Kamatera node configuration, this should match the node configuration used by Rancher
datacenter=IL
image=ubuntu_server_20.04_64-bit_optimized
; the public network, you should not change this
network = "name=wan,ip=auto"
; the private network, you should change the name to match your private network name as 
; defined in the other Rancher node templates
network = "name=lan-12345-abcde,ip=auto"
; the node resources can be different from the Rancher node pool resources, depending on your scaling requirements
cpu=4B
ram=8192
disk=size=100
; the autoscaler will run this script to connect the node to the cluster
; see below for details regarding how to generate this script
script-base64=
```

To generate the value for the `script-base64` attribute, follow these instructions:

* Create a local file named `script.sh` with the following contents:
```
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export HOME=/root/
apt-get update && apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository   "deb [arch=amd64] https://download.docker.com/linux/ubuntu   $(lsb_release -cs)   stable"
apt-get update
apt install -y docker-ce
```
* Access the following URL on your Rancher server:
  * `https://YOUR.RANCHER.DOMAIN/v3/clusterregistrationtokens`
* Under the `data` attribute you will have several items, if you have a single cluster in your
  Rancher server, then it will be the first one. If you have several cluster, find the one with the 
  `clusterId` attribute that matches your cluster ID.
* Copy the `nodeCommand` attribute value, it should start with `sudo docker run -d --privileged ...`
* Append this `nodeCommand` value to the end of the `script.sh` file
* Run the following command to generate the base64 encoded script:
```
cat script.sh | base64 -w0
```
* Copy the output and paste it as the value of the `script-base64` attribute in the autoscaler
  configuration secret
* Delete the `script.sh` file

Once you have the secret with all values, you can install the cluster autoscaler running the following command
from the Rancher web UI -> Cluster -> Kubectl Shell:

```
kubectl apply -f https://raw.githubusercontent.com/Kamatera/rancher-kubernetes/v0.0.2/rancher/cluster-autoscaler.yaml
``` 

Verify that the cluster autoscaler pod is running:

```
kubectl get -n kube-system pods -l app=cluster-autoscaler
```

Check the cluster autoscaler pod logs for errors:

```
kubectl logs -n kube-system -l app=cluster-autoscaler
```

## Testing the autoscaler

To test the autoscaler, you can create a deployment with a resource limit that is higher than
the node resources. The autoscaler will detect that the node is not able to run the pod and will
create a new node to run the pod. When the resource usage of the pod is reduced, the autoscaler
will detect that the node is not needed and will delete it.

You can check the logs of the `cluster-autoscaler` pod in `kube-system` namespace to debug any problems
or get visibility into the autoscaler decisions.

--------------------
#### [Table Of Contents](../README.md)
