# Kubernetes Monitoring

## Install kube-prometheus

Helm chart: https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack

Create monitoring namespace

```
kubectl create ns monitoring
```

Add prometheus-community helm repo (this adds the repo locally only)

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Install

```
helm -n monitoring install kube-prometheus prometheus-community/kube-prometheus-stack
```

