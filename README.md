# Kamatera Rancher Kubernetes

This guide will show you how to setup a Kubernetes cluster and related infrastructure managed via Rancher using the following versions:

* Rancher v2.6.6
* Kubernetes v1.23

## High-Level Architecture

The architecture is very dynamic, components can be changed or removed depending on requirements:

![image](https://user-images.githubusercontent.com/1198854/183381723-9e3016cc-01ee-4da4-933f-0b68cae35392.png)

## Guide

### Create the Rancher server / cluster

We will use Rancher to create and manage the Kubernetes cluster/s. First step is to setup the Rancher server or cluster.

There are 2 options, both are reliable and valid for production deployments, depending on your requirements.

Continue the guide by clicking on one of the following options:

* [Single Rancher Server](rancher/Create%20Single%20Rancher%20Server.md) - Simple and cheap, requiring only a single server.
* [High Availability Rancher Cluster](rancher/Create%20High%20Availability%20Rancher%20Cluster.md) - Harder to create and manage, requires a minimum of 3 servers.

### Create a Kubernetes Cluster

Once you have a Rancher server or cluster, you can use it to create a Kubernetes cluster.

Following guide shows how to create a cluster using the Kamatera Rancher driver:

* [Create a Kubernetes Cluster](rancher/Create%20Kubernetes%20Cluster.md)

### Additional Infrastructure and Services

Once you have a Kubernetes cluster, some additional services are usually required, it's recommended to follow the following guides in order
as they depend on each other:

* [Accessing Workloads Externally - Load Balancing / Ingress](rancher/Accessing%20Workloads%20Externally.md)
* [Persistent Storage](rancher/Persistent%20Storage.md)
* [Monitoring and Logging](rancher/Monitoring%20and%20Logging.md)
* [Debugging](rancher/Debugging.md)
* [Cluster Autoscaler](rancher/Cluster%20Autoscaler.md)
