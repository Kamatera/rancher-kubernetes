# Create Single Server Rancher Server

Use the Kamatera web-ui or cloudcli to create a new Kamatera server:

* Must set a server password - this password will be used for the Rancher admin password
* Image: `service_rancher_rancher-2.6.2-ubuntuserver-20.04`
* Networks: WAN + private LAN
* Cpu: 2 cores
* Ram: 4096
* Disk size: 100GB

Example [cloudcli](https://github.com/cloudwm/cloudcli/blob/master/README.md) command:

```
cloudcli server create --name my-rancher-server --password my-secret-password --datacenter IL \
      --image service_rancher_rancher-2.6.2-ubuntuserver-20.04 --network name=wan --network name=private-network-name \
      --cpu 2B --ram 4096 --disk size=100 --wait
```

Access the server by converting the server IP to a cloud-xip domain (e.g. https://111-222-333-444.cloud-xip.io/).

Default username is `admin` and password is the same as the server password. Make sure you can login before
proceeding.

## Upgrade Rancher Version

Pay attention that Rancher may introduce breaking changes occasionally so don't just upgrade to any latest version.
Make sure to only use the version specified here and test before using other versions.

SSH into the server and run the following commands

Create Rancher configurations:

```
mkdir -p /etc/rancher
echo rancher/rancher:v2.6.6 > /etc/rancher/image
```

Set the Rancher server domain name (change the domain according to your server's domain):

```
echo 111-222-333-444.cloud-xip.io > /etc/rancher/domain
```

Create the script:

```
echo '#!/bin/bash
if ! docker pull "$(cat /etc/rancher/image)"; then exit 1; fi
docker rm -f rancher
docker run -d --name rancher --restart unless-stopped \
	-p 80:80 -p 443:443 \
	-v /etc/letsencrypt/live/$(cat /etc/rancher/domain)/fullchain.pem:/etc/rancher/ssl/cert.pem \
	-v /etc/letsencrypt/live/$(cat /etc/rancher/domain)/privkey.pem:/etc/rancher/ssl/key.pem \
	-v /etc/letsencrypt/live/$(cat /etc/rancher/domain)/chain.pem:/etc/rancher/ssl/cacerts.pem \
	--privileged -v "/var/lib/rancher:/var/lib/rancher" "$(cat /etc/rancher/image)"
' > /usr/local/bin/rancher_recreate
chmod +x /usr/local/bin/rancher_recreate
```

Run the script to upgrade Rancher (make sure you already successfully logged-in to Rancher before running this script):

```
rancher_recreate
```

Follow Rancher logs to check startup progress:

```
docker logs -f rancher
```

In case of problems you can re-run the script at any time to recreate the Rancher container
(storage is persistent, your data will be preserved):

```
rancher_recreate
```

## Upgrade the Kamatera Docker Machine driver

Rancher Web UI -> Cluster Management -> Drivers -> Node Drivers -> Kamatera -> Edit

Set Download URL: `https://github.com/Kamatera/docker-machine-driver-kamatera/releases/download/v1.1.4/docker-machine-driver-kamatera_v1.1.4_linux_amd64.tar.gz`

Save
