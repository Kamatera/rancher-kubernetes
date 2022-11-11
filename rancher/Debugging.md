# Debugging

## Cluster Debugging

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

--------------------
#### [Table Of Contents](../README.md) | [Next Page](Cluster Autoscaler.md) ⟶
