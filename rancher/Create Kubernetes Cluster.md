# Create a Kubernetes Cluster

## Add node templates

Rancher web-ui -> profile image -> node templates

* For single server deployment you should already have node templates with the minimal requirements
* Add or edit node templates depending on your requirements
    * controlplane:
        * minimum: 2 CPU, 2GB RAM, 30GB disk size, image: ubuntu_server_18.04_64-bit_optimized
        * recommended: 4 CPU, 4GB RAM, 100GB disk size, image: ubuntu_server_18.04_64-bit_optimized
    * worker:
        * minimum: 2 CPU, 4GB, 50GB disk size, image: ubuntu_server_18.04_64-bit_optimized
        * recommended: 4 CPU, 8GB, 200GB disk size, image: ubuntu_server_18.04_64-bit_optimized

## Create cluster

Rancher web-ui -> global > clusters > add cluster

* type: Kamatera
* cluster name: choose a unique name
* controlplane node pool:
    * name prefix: `(CLUSTER_NAME)-controlplane-`
    * count:
        * 1 node - cheaper but less options for recovery in case of problems, no high-availability
        * 3 nodes - high availability, recovery in case of problems
    * check etcd and controlplane checkboxes
* worker node pool:
    * name prefix: `(CLUSTER_NAME)-worker-`
    * count: depends on expected usage
    * check only the worker checkbox
* keep all default options
* create

## Check cluster creation progress

Click on the created cluster name (on the cluster switcher top left corner in the UI).

Click on nodes to see the nodes and progress of creation.

You may see some errors but they usually go away in a few minutes once cluster stablizes.

Rancher has a retry mechanism, so even if there are errors, it will retry until it works.

If cluster is not stabilizing, check the rancher logs by SSH to the Rancher server and running `docker logs -f rancher`
