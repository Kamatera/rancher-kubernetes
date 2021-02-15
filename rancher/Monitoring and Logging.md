# Monitoring

## Rancher installed monitoring

Enable monitoring at the cluster global level

Rancher Web-UI -> Cluster -> Tools -> Monitoring

It's recommended to enable persistent storage for both Prometheus and Grafana, choose the appropriate storage class and volume size.

Check progress of monitoring stack deployment in the system project `cattle-prometheus` namespace

Metrics are visible throughout the Rancher web-UI, Grafana can be accessed directly (admin username/password: `admin` / `admin`)

## Rancher installed logging

Rancher logging requires logging infrastructure to be set-up (outside of scope of this guide)

Enable logging at the cluster global level

Rancher Web-UI -> Cluster -> Tools -> Logging

Choose one of the logging providers and configure it
