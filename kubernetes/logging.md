# Kubernetes Monitoring

## Install Loki-Stack

Helm chart: https://artifacthub.io/packages/helm/grafana/loki-stack

Create logging namespace

```
kubectl create ns logging
```

Add Grafana helm repo (this adds the repo locally only)

```
helm repo add grafana https://grafana.github.io/helm-charts &&\
helm repo update
```

Install Loki-stack

```
helm -n logging install loki grafana/loki-stack
```
