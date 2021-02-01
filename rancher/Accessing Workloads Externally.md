# Accessing Workloads Externally

The default created cluster should include an Nginx Ingress, if not, edit the cluster and set Nginx Ingress to enabled.

You can verify the ingress controller is running in the system project (ingress-nginx namespace), `nginx-ingress-controller` daemonset.

The controller listens on all worker nodes ports 80 and 443.

## Add an ingress

Ingress objects exposes your app externally via the ingress controller.

You should have a workload which serves HTTP, for testing you can add a simple deployment using `nginx` image.

Go to the project resources -> workloads -> load balancing -> add ingress

* Rules: automatically generate a xip.io hostname
* path: keep empty to serve any path, target: choose the target workload (`nginx`), port: the workload port (`80`)
* Save

You should see the ingress domain in the ingress list

When accessing the domain you should see the Welcome to nginx page

It should also be possible to access it using https (although with an insecure certificate)

## Using custom domain names

When adding an ingress you can choose to use your own domain name

You will then need to point your DNS to any or all of the worker nodes external IPs 

## Adding your own SSL Certificates

Project resourecs -> secrets -> certificates -> add certificate
* Available to a single namespace: the namespace where the ingress rule and workload were created
* save the private key and certificate

Edit the ingress and choose to use this certificate

## Automatically generate Let's Encrypt certificates

### Install and configure cert-manager

Install [cert-manager](https://cert-manager.io/):

* Rancher -> cluster -> Launch kubectl

```
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml
```

Verify cert-manager is running:

```
kubectl get pods --namespace cert-manager
```

Create a ClusterIssuer using the following command:

* change user@example.com to your email
* change the server value to `https://acme-v02.api.letsencrypt.org/directory` 

```
echo '
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt
spec:
  acme:
    # You must replace this email address with your own.
    # Lets Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: user@example.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the accounts private key.
      name: cluster-issuer-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
' | kubectl apply -f -
```

### Use cert-manager certificates in ingress rules

Edit the ingress to use your own domain (xip.io domains are usually rate-limited and not available using Let's Encrypt)

Edit the ingress as YAML and add the following values

* Change `(HOSTNAME)` to the relevant hostname
* Change `(INGRESS_NAME)` to the name of the ingress

```
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt

spec:
  tls:
    - hosts:
      - (HOSTNAME)
      secretName: (INGRESS_NAME)-cert
```

Save

In the project workloads and load balancer you should see temporary objects which handle the registration and will be deleted afterwards

Once certificate registration is done you should be able to access the ingress from the domain using https

If there are problems, check the cert-manager workload logs (in cert-manager namespace)

## Protecting Ingress Using Http Auth

This allows for simple password protection to ingress objects

From your local PC, generate the auth token (replace USERNAME with the desired user name)

```
sudo apt-get install apache2-utils

htpasswd -c /dev/stdout USERNAME
```

Copy the last output line

Open Rancher cluster -> Launch kubectl

* Set `NAMESPACE_NAME` to the namespace where the ingress object exists (or `default` if you didn't specify a namesapce)
* Set `INGRESS_NAME` to the name of the ingress object
* Set `AUTH_TOKEN` to the line you copied from htpasswd

```
kubectl -n NAMESPACE_NAME create secret generic INGRESS_NAME-auth '--from-literal=auth=AUTH_TOKEN'
```

Edit the ingress object and add the following annotations (replace INGRESS_NAME with the ingress name)

```
nginx.ingress.kubernetes.io/auth-type: basic
nginx.ingress.kubernetes.io/auth-secret: INGRESS_NAME-auth
```

Save

When accessing the domain you should be presented with an http auth popup

