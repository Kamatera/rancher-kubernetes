# Debugging

## Debugging Workloads

Follow the Configuration and Secrets document to setup the nginx test workload with custom configuration.

Edit the configmap and create an nginx syntax error

Redeploy the nginx pod

Rancher should show error + CrashLoopBackOff - and will keep retrying to start it

* View deployment events - deployment startup progress
* View pod logs - syntax error from Nginx
* View pod events - container startup progress
* View pod status - Status indications and last update time

Execute shell on pods for debugging - if pod is stuck in restart loop - Change the entrypoint to pause startup and then you can exec shell on it.

Edit the nginx test workload -> show advanced options -> Command:
* Entrypoint: `sleep 86400`
* Save

Now, the workload is paused at startup and you can execute shell to debug it

## Debugging Cluster

Check workloads in system project - you can check logs and status

SSH to cluster nodes - Cluster -> Nodes -> Node -> Download Keys

Use the id_rsa key to ssh to the node

```
chmod 400 id_rsa
ssh -i id_rsa root@NODE_IP
```

Check kubelet logs - `docker logs kubelet`

## Restarting nodes

**In case of a single controlplane node, do not restart the controlplane node, as cluster will not be able to recover**

You can safely restart the underlying server from Kamatera console.

You can also delete the node from Rancher UI, and it will be recreated.

To ensure workloads are scheduled on other nodes, you can use the cordon and drain methods.

* Cordon - prevent future workloads from sheduling on the node
* Drain - remove all existing workloads from the node
