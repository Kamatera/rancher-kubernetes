# Monitoring and Logging

The monitoring and logging solutions described here run on the cluster, so you have to make sure you have
enough resources to accommodate their workloads. If you used the recommended configurations in the create
cluster section, you should be fine.

## Monitoring

To install monitoring using the NFS storage we create previously, follow this guide. You can also refer
to the [Rancher documentation](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting/).

Cluster explorer -> Cluster tools (bottom left)

Click on "install" for the Monitoring app and set the following values:

* Prometheus
  * Check "Persistent Storage for Prometheus"
    * Storage class name: `nfs-client`
* Grafana
  * Grafana Storage: Enable with PVC template
    * Size: `50Gi` (it doesn't matter what size you choose)
    * Storage class name: `nfs-client`
    * Access mode: `ReadWriteOnce`
* Click on "Edit YAML"
  * Set the following under `grafana:`
```
...
grafana:
  initChownData:
    enabled: false
...
```
  * Scroll down to `prometheus:`
    * Scroll down to `  prometheusSpec:`
      * Scroll down to `    storageSpec:`
        * Remove the `selector:` key and all values under it starting with `match`

You can check the created workloads in `cattle-monitoring-system` namespace, pay attention to pending workloads
which might not have enough resources, in that case you will need to increate the amount of resources in your
cluster.

In case of problems you can view and update the app in cluster explorer -> apps -> installed apps.

See the [Rancher documentation](https://rancher.com/docs/rancher/v2.6/en/monitoring-alerting/) for more information
and usage instructions.

### Logging

To install logging using the NFS storage we create previously, follow this guide. You can also refer
to the [Rancher documentation](https://rancher.com/docs/rancher/v2.6/en/logging/).

The logging architecture will involve 2 services:

* Rancher logging app - handles the aggregation of logs from all cluster workloads
* Grafana Loki - handles the storage of logs and supports searching and displaying them via Grafana

#### Install Rancher Logging

Cluster explorer -> Cluster tools (bottom left)

Click on "install" for the Logging app and accept all the default values.

You can check the created workloads in `cattle-logging-system` namespace, pay attention to pending workloads
which might not have enough resources, in that case you will need to increate the amount of resources in your
cluster.

In case of problems you can view and update the app in cluster explorer -> apps -> installed apps.

#### Install Grafana Loki

Cluster explorer -> apps -> Repositories -> Create

* Name: `grafana`
* Target: http URL
* Index URL: `https://grafana.github.io/helm-charts`

Cluster explorer -> apps -> search for `loki` and click on the `loki` chart

Click on install (guide was written for Loki chart version 2.13.3 but it should work with newer versions as well)

* namespace: `cattle-logging-system`
* Name: `loki`
* Edit the YAML:
  * Set `persistence.enabled` to `true`

#### Connect Rancher Logging to Grafana Loki

Cluster explorer -> logging -> ClusterOutputs -> create

* Name: `loki`
* Output: `loki`
* Target URL: `http://loki.cattle-logging-system.svc.cluster.local:3100`

Cluster explorer -> logging -> ClusterFlows -> create

* Name: `cluster-to-loki`
* Outputs: `loki`

Make a few requests to the nginx test app or any other request that will generate logs.

To view the logs (it might take a few minutes until logs are available) - 

Cluster explorer -> Monitoring -> Grafana

* Click on sign-in button (bottom left)
* login with user `admin` password `prom-operator`
* Click on configuration (left sidebar) -> data sources -> add datasource
  * Type: Loki
  * URL: `http://loki.cattle-logging-system.svc.cluster.local:3100`
* Click on explore (left sidebar)
  * Choose loki data source (top left)
  * Click on the log browser link and follow the instructions
