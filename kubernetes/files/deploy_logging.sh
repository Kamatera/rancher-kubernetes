#!/usr/bin/env bash

helm upgrade -n logging -f kubernetes/files/logging-storage-values.yaml loki grafana/loki-stack --version 2.3.1