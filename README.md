# admin-image-ubuntu

an image based on ubuntu its for use as an admin machine to keep my MacBook as clean as possible. it includes normal network administration tools, as well as some advanced admin tools for Kubernetes in the cloud and on the local network. the entrypoint for the image is set to the zsh, so it is not necessary to specify a shell command in the container run command line.

---
**NOTE**:
make sure to understand the difference between local images (build locally with the below build command) and the automatically created (on all main commits), an image potentially stored on DockerHub, and an image stored in the GitHub container registry. especially, make sure to select the right "platform" when the released container image is a multi-platform image.

---

## using the local image repository

### for network administration

ping and other networking commands need full access to network devices, which is not granted by default.
special "capabilities" have to be specified to allow the commands in the container to access network devices.

#### basic version without interactive tty or container name

```bash
podman run --platform="<os>/<arch>" --cap-add net_raw --cap-add net_admin <other options> <container-name> <command>
```

#### example for actual practical use in network analysis

***NOTE:*** this example is used for the new ARM64-based mac/macOS!

run a bash inside the container with the necessary capabilities enabled, an assigned name, as well as with an interactive tty open. The container is also removed after exiting.

```bash
podman run --platform="linux/arm64" --hostname="adminhost" --cap-add net_raw --cap-add net_admin \
    --rm --name netadmincontainer \
    -ti localhost/adminubuntu:latest
```

Note:
If the container is not yet available locally (or not built at all yet), it has to be build. In that it is important to match the tags to not produce error messages when running the container!

```bash
podman build --platform="linux/arm64" -t localhost/adminubuntu:latest .
```

## using the GitHub container registry

first, one needs to login to the GitHub registry by

***CAUTION!*** the login code is still work in progress and doesn't work yet and the whole section on using the GitHub registry is still not fully tested (image pull results in an error that could potentially be due to platform mismatch).

for logging into the GitHub container registry (GHCR), it is necessary to create a personal access token on GitHub with the necessary permissions ("read:packages", "write:packages", "delete:packages"--any of those or all, depending on your specific needs)

```bash
export GHCR_TOKEN=<your-gh-token-with-permissions>
echo $GHCR_TOKEN | podman login ghcr.io -u intruder1912 --password-stdin
```

to pull the image from GitHub without building it locally before, use the following code (works only if the image has the "latest" tag; if not, one must use the specific sha digest to be found directly on GitHub):

```bash
podman run --platform="linux/arm64" --hostname="adminhost" --cap-add net_raw --cap-add net_admin \
    --rm --name netadmincontainer \
    -ti ghcr.io/intruder1912/admin-image-ubuntu:latest
```

variant without a propper tag (latest), so one has to use a digest:

```bash
podman run --platform="linux/arm64" --hostname="adminhost" --cap-add net_raw --cap-add net_admin \
    --rm --name netadmincontainer \
    -ti ghcr.io/intruder1912/admin-image-ubuntu@sha256:71e9fffd81236d72c3b6046399115bc57e7df262a71cd2d627315f5979c59a68
```
