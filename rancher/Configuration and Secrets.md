# Configuration and Secrets

## Add a static configuration file

For this example, we will add an nginx configuration snippet

Cluster -> Resources -> Config -> Add Config Map

* Name: `nginx-test`
* Namespace: `default`
* Key: `default.conf`
* Value: Paste the following:
```
server {
    listen       80;
    server_name  localhost;
    location / {
        add_header Content-Type text/plain;
        return 200 'Hello Rancher!';
    }
}
```
* Save

Create a new workload in default namespace using image `nginx`

Add Volume -> Use a ConfigMap, select the nginx-test configmap and mount on `/etc/nginx/conf.d`

## Add a secret environment variable

**By default secrets are not encrypted, some additional steps need to be taken for encryption, see https://rancher.com/docs/rke/latest/en/config-options/secrets-encryption/**

Cluster -> Resources -> Config -> Add Secret

* Name: `nginx-test`
* Key: `MY_SECRET`
* Value: `secret`
* Save

Edit the nginx workload, Environment Variables -> Add from source
* Type: Secret
* Source: `nginx-test`
* Key: `all`
* Save

Execute shell on the workload and run `echo $MY_SECRET`
