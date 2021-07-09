
## Install docker

`https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04`

Saved image as Ubuntu20.04_docker on OpenStack

Add the user to the docker group

```
sudo usermod -a -G docker ofn77899
```

logout and back in to make the change effective.


## install NVIDIA runtime

```
starting the docker image will result in 
ERROR: for sirf  Cannot create container for service sirf: Unknown runtime specified nvidia
```

`https://github.com/NVIDIA/nvidia-docker/wiki/Frequently-Asked-Questions#why-do-i-get-the-error-unknown-runtime-specified-nvidia`

Go to `https://github.com/nvidia/nvidia-container-runtime#docker-engine-setup`

Install nvidia-container-runtime 
`https://nvidia.github.io/nvidia-container-runtime/`

```
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
sudo apt-get update
```

Use Systemd drop-in file

## move the docker directory

`https://docs.docker.com/config/daemon/systemd/#runtime-directory-and-storage-driver`

ou may want to control the disk space used for Docker images, containers, and volumes by moving it to a separate partition.

To accomplish this, set the following flags in the daemon.json file in `/etc/docker`
```
{
    "data-root": "/mnt/docker-data",
    "storage-driver": "overlay2"
}
```

`https://www.guguweb.com/2019/02/07/how-to-move-docker-data-directory-to-another-location-on-ubuntu/`


```
sudo service docker stop
sudo rsync -aP /var/lib/docker/ /path/to/your/docker
sudo rm -r /var/lib/docker
sudo service docker start
```

## Push to docker hub

`https://hub.docker.com/settings/security`

create an access token, then `docker login --username paskino` then put in the token. 
Then you can do `docker image push <image name>`.