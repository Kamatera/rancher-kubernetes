#!/usr/bin/env bash

helm upgrade -n monitoring -f kubernetes/files/monitoring-storage-values.yaml kube-prometheus prometheus-community/kube-prometheus-stack --version 13.13.0
