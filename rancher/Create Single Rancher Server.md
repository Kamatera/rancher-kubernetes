# Create Single Server Rancher Server

Use the Kamatera web-ui or cloudcli to create a new Kamatera server:

* Image: `service_rancher_rancher-2.3-ubuntuserver-18.04`
* Networks: WAN + private LAN
* Cpu: 2 cores
* Ram: 4096
* Disk size: 100GB

Example [cloudcli](https://github.com/cloudwm/cloudcli/blob/master/README.md) command:

```
cloudcli server create --name my-rancher-server --password my-secret-password --datacenter IL \
      --image service_rancher_rancher-2.3-ubuntuserver-18.04 --network name=wan --network name=private-network-name \
      --cpu 2B --ram 4096 --disk size=100 --wait
```

Access the server by converting the server IP to a cloud-xip domain (e.g. https://111-222-333-444.cloud-xip.io/).

Default username is `admin` and password is the same as the server password.

## Upgrade the Rancher version

SSH to the Rancher server and run the following:

```
docker rm -f rancher &&\
docker run -d --name rancher --restart unless-stopped --privileged -p 8000:80 \
    -v "/var/lib/rancher:/var/lib/rancher" "rancher/rancher:v2.4.12"
```

Follow Rancher logs to check startup progress:

```
docker logs -f rancher
```

## Upgrade the Kamatera Docker Machine driver

Rancher web UI -> Tools -> Drivers -> Node Driver -> Kamatera -> Edit

Set Download URL: `https://github.com/Kamatera/docker-machine-driver-kamatera/releases/download/v1.1.2/docker-machine-driver-kamatera_v1.1.2_linux_amd64.tar.gz`
