# Accessing Workloads Externally - Load Balancing / Ingress

The default created cluster should include an Nginx Ingress Controller, if not, edit the cluster and set Nginx Ingress to enabled.

The Nginx Ingress runs on all cluster worker nodes and serves Kubernetes ingress objects.

You can create DNS records which point to all cluster nodes thus achieving load balancing between the cluster nodes.

You can verify the ingress controller is running in the system project (ingress-nginx namespace), `nginx-ingress-controller` daemonset.

The controller listens on all worker nodes ports 80 and 443.

## Add an ingress

Ingress objects exposes your app externally via the ingress controller.

You should have a workload which serves HTTP, for the purpose of this guide we will create a simple nginx deployment

Go to explore cluster -> workload -> create -> deployment

* General
  * container image: `nginx`
* Labels & Annotations
  * Pod Labels:
    * add: Key: `app`, Value: `nginx`

Go to explore cluster -> service discovery -> services -> create -> cluster ip

* Service ports
  * Port Name: http
  * Listening port: 80
  * Target port: 80
* Selectors
  * Key: `app`, Value: `nginx`

Go to explore cluster -> service discovery -> ingresses -> create

* Rules:
  * Request Host: Any domain which points to the cluster node ips, for testing you can use nip.io service
    for example, if the ip is 1.2.3.4, you can use domain my-test.1.2.3.4.nip.io
  * path prefix: `/`
  * target service: choose the service and port you created earlier

You should see the ingress domain in the ingress list

When accessing the domain you should see the Welcome to nginx page

It should also be possible to access it using https (although with an insecure certificate)

## Adding your own TLS Certificates

You can upload your own TLS certificate and use it in the ingress.

cluster explorer -> storage -> secrets -> create -> TLS Certificate

Once you added the certificate secret, you can edit the Ingress to use it:

* Certificates
  * Add Certificate
    * Select the certificate secret you added and enter the related host name it serves

## Automatically generate Let's Encrypt TLS certificates

The ingress controller can automatically generate Let's Encrypt TLS certificates for you.

### Install and configure cert-manager

cert-manage component handles the automated registration and renewal of Let's Encrypt certificates.

Install [cert-manager](https://cert-manager.io/):

Open the kubectl shell (cluster explorer -> cluster name -> kubectl shell) and run the following:

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
```

Verify all cert-manager pods have 1/1 ready containers in running status:

```
kubectl get pods --namespace cert-manager
```

Create a ClusterIssuer object - cluster explorer -> cluster -> import yaml

* Namespace: default
* Paste the following yaml, changing the email to your own email address:

```
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
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the accounts private key.
      name: cluster-issuer-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
```

### Use cert-manager certificates in ingress rules

To use Let's Encrypt certificates you will have to register your own domain and setup DNS to the worker nodes.
(nip.io or other dynamic ip type solutions will most likely not work with Let's Encrypt).

Cluster explorer -> service discovery -> ingresses -> edit:

* Rules
  * Request Host: set to your custom domain which points to the cluster worker nodes IPs
* Certificates
  * Add Certificate:
    * Secret Name: enter a unique name, the secret will be created by cert-manager in the same namespace as the ingress
    * Host: enter your custom domain
* Labels & Annotations
  * Add annotation:
    * Key: `cert-manager.io/cluster-issuer`, value: `letsencrypt`

Let's Encrypt certificate registration shouldn't take more then 1 minute, usually much less. During registration
you will see a temporary pod and ingress object which handles it. When done you shoud be able to access the domain
via https.

If there are problems, check the cert-manager workload logs (in cert-manager namespace).

## Protecting Ingress Using Http Auth

This allows for simple password protection to ingress objects.

First, you need to generate htpasswd hashed password/s, on Ubuntu you can use the following snippet.
The username doesn't matter, we will define it elsewhere, you will be prompted for the passsword:

```
sudo apt install -y apache2-utils
htpasswd -c /dev/stdout USERNAME
```

The output will look something like this:

```
USERNAME:$apr1$XqQZ...
```

Copy just the hashed password (everything after the colon) and create a secret containing it - 

Cluster explorer -> storage -> secrets -> create -> Opaque

* Key: the username you want to use
* Value: the hashed password

Create the secret in the same namespace as the ingress object and input username / password combinations.

Edit the ingress object and add the following annotations on it:

* key: `nginx.ingress.kubernetes.io/auth-type` value: `basic`
* key: `nginx.ingress.kubernetes.io/auth-secret` value: the secret name you created
* key: `nginx.ingress.kubernetes.io/auth-secret-type` value: `auth-map`

When accessing the domain you should now be presented with a http auth popup.
