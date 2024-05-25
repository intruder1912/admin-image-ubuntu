# admin-image-ubuntu

an image based on ubuntu its for use as an admin machine to keep my MacBook as clean as possible

## usage

### for network administration

ping and other networking commands need full access to network devices, which is not granted by default.
special "capabilities" have to be specified to allow the commands in the container to access network devices.

#### basic version without interactive tty or container name

```bash
podman run --cap-add net_raw --cap-add net_admin <other options> <container-name>
```

#### example for actual practical use in network analysis

run a bash inside the container with the necessary capabilities enabled, an assigned name, as well as with an interactive tty open. The container is also removed after exiting.

```bash
podman run --cap-add net_raw --cap-add net_admin \
    --rm --name netadmincontainer \
    -ti localhost/adminubuntu:latest bash
```

Note:
If the container is not yet available locally (or not built at all yet), it has to be build. In that it is important to match the tags to not produce error messages when running the container!

```bash
podman build -t localhost/adminubuntu:latest .
```