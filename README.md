# admin-image-ubuntu

an image based on ubuntu for use as an admin machine to keep my MacBook as clean as possible. it includes normal network administration tools, as well as some advanced admin tools for Kubernetes in the cloud and on the local network. the entrypoint for the image is set to the command ```zsh```, so it is not possible/necessary to specify a shell command in the container run command line. strings added to the container run command at the end will be interpreted as command arguments for the entrypoint defined in the containder file (Dockerfile). if another command should be specified as a runtime argument, the ```--entrypoint``` flag is needed as an override.

**NOTE**:
make sure to understand the difference between local images (build locally with the below build command) and the automatically created (on all main commits), an image potentially stored on DockerHub, and an image stored in the GitHub container registry. especially, make sure to select the right "platform" when the released container image is a multi-platform image.

## intended use

this is a personal admin toolbox, not a hardened or minimal image. it is meant to be run interactively, on machines and networks you are authorised to administer. keep in mind:

- the default user ```intruder``` (UID 1001) has passwordless ```sudo```. do not reuse this pattern for services or production workloads.
- the image ships network and security tools (```nmap```, ```tcpdump```, ```tshark```, ```arp-scan```, ```socat```, ...). only point them at systems you own or have permission to test.
- no credentials are baked into the image. pass cloud/cluster credentials at runtime (mounted config or environment) and never commit them.
- the image is published to the GitHub container registry and signed, see "using the GitHub container registry" for how to pull it and how to verify the signature. you can also build it yourself from the ```Dockerfile```.

## using the local image repository

### for network administration

ping and other networking commands need full access to network devices, which is not granted by default.
special "capabilities" have to be specified to allow the commands in the container to access network devices.

#### basic version without interactive tty or container name

```bash
podman run --platform="<os>/<arch>" --cap-add net_raw --cap-add net_admin <other options> <container-name> <command>
```

#### example for actual practical use in network analysis

***NOTE:***
this example is used for the new ARM64-based mac/macOS!

run a shell (currently configured is a ```zsh```) inside the container with the necessary capabilities enabled, an assigned name, as well as with an interactive tty open. The container is also removed after exiting.

```bash
podman run --platform="linux/arm64" --hostname="adminhost" --network host --cap-add net_raw --cap-add net_admin --cap-add audit_write \
    --rm --name netadmincontainer \
    -ti localhost/adminubuntu:latest
```

***IMPORTANT!***
to use the container for network administration, it needs to have special "capabilities" added and run on the same network as the host (ARP). that is the reason for the ```--cap-add``` and ```--network``` options, respectively. for a full list of capabilities (i.e., in the Linux kernel!), refer to <https://man7.org/linux/man-pages/man7/capabilities.7.html>. for more information on container networking, please head to the Docker documentation pages. specifically relevant for the use above would be <https://docs.docker.com/engine/network/#drivers>. in general, for advanced administrational tasks it might even be necessary to start the container as ```root```.

**CAVE:** when running a container as ```root```, socket communication to the podman daemon might not be possible without any further precautions. when running in a different user context than the podman desktop process, there seem to be restrictions in place (somehow expected).

**NOTE:**
if the container is not yet available locally (or not built at all yet), it has to be build. In that it is important to match the tags to not produce error messages when running the container!

command to build the container locally:

```bash
podman build --platform="linux/arm64" -t localhost/adminubuntu:latest .
```

## macOS networking caveats

on macOS, ```podman``` runs containers inside a Linux VM (```podman machine```) whose network is fronted by ```gvproxy```, a userspace TCP/IP gateway. two consequences matter for the diagnostic tools shipped in this image:

1. **```ping``` is unreliable.** ```gvproxy``` translates ICMP via macOS's ```SOCK_DGRAM``` ICMP sockets and can return apparent echo replies for hosts that do not exist or are not routable. a successful ```ping``` from inside the container is **NOT** proof of reachability on macOS. ```--cap-add net_raw``` is correctly applied but has no effect on this userspace translation layer.
2. **```--network host``` shares the VM's namespace, not your Mac's LAN.** layer-2 tools (```arp-scan```, raw ```tcpdump``` on a physical NIC, ARP-based neighbour discovery) cannot see your real LAN from inside the container.

on native Linux hosts both limitations disappear — ```podman``` uses the host's network stack directly.

### reliable alternatives (already installed in this image)

| goal | use instead of ```ping <host>``` |
|------|----------------------------------|
| host alive / TCP port reachable | ```nc -vz -w 3 <host> <port>``` |
| TCP "ping" without ICMP | ```nmap -sn -PS22,80,443 <host>``` |
| force a probe regardless of host-discovery | ```nmap -Pn -p 22,80,443 <host>``` |
| DNS resolution | ```dig +short <host>``` |
| latency / TCP traceroute | ```mtr -n -c 5 -T -P 443 <host>``` |
| generic traceroute | ```tracepath <host>``` or ```mtr -rwzbc 1 <host>``` |
| confirm a service speaks | ```nc -vz <host> <port>``` then ```socat - TCP:<host>:<port>``` |

```mtr``` in TCP mode (```-T```) and ```nmap -PS``` bypass ICMP entirely, so they are not fooled by ```gvproxy```'s ICMP behaviour.

### ICMP sanity check

the image ships a small probe at ```/usr/local/bin/icmp-sanity-check```. it pings several RFC 5737 TEST-NET-1 addresses (which must never answer); any "success" indicates you are in the ```gvproxy``` false-positive scenario.

run it inside the container:

```bash
icmp-sanity-check
```

exit codes:

- ```0``` — pings to TEST-NET addresses failed as expected. ICMP appears trustworthy (typical on Linux hosts).
- ```1``` — at least one TEST-NET address answered. you are almost certainly on macOS/podman + ```gvproxy```; do **NOT** trust ```ping``` results. use the alternatives in the table above.
- ```2``` — ```CAP_NET_RAW``` is missing. re-run the container with ```--cap-add net_raw```.
- ```3``` — unexpected ```ping``` runtime error unrelated to capabilities. check the error output for details.

### running ICMP from the VM directly (escape hatch)

if you need real ICMP from macOS, bypass the container and run from the ```podman``` VM itself:

```bash
podman machine ssh -- ping -c 3 <host>
```

this still goes through the VM's stack but avoids the container-side ```gvproxy``` ICMP translation quirks for some test scenarios.

## using the GitHub container registry

the image is published to the GitHub container registry as a multi-platform image (```linux/amd64``` and ```linux/arm64```) and can be pulled without logging in:

```bash
podman run --platform="linux/arm64" --hostname="adminhost" --cap-add net_raw --cap-add net_admin \
    --rm --name netadmincontainer \
    -ti ghcr.io/intruder1912/admin-image-ubuntu:latest
```

```latest``` (also tagged ```main```) follows the main branch; only the most recent builds are kept in the registry. to pin a specific build use its digest, which is shown on the package page:

```bash
podman run --platform="linux/arm64" --hostname="adminhost" --cap-add net_raw --cap-add net_admin \
    --rm --name netadmincontainer \
    -ti ghcr.io/intruder1912/admin-image-ubuntu@sha256:<digest>
```

### verify the image

every image pushed from the main branch is signed with [cosign](https://github.com/sigstore/cosign) (keyless, using the GitHub Actions identity of this repository's ```docker-publish``` workflow) and the signature is recorded in the public sigstore transparency log. to check that an image was built by this repository's workflow:

```bash
cosign verify \
    --certificate-identity-regexp '^https://github.com/intruder1912/admin-image-ubuntu/.github/workflows/docker-publish.yml@.*' \
    --certificate-oidc-issuer https://token.actions.githubusercontent.com \
    ghcr.io/intruder1912/admin-image-ubuntu:latest
```

a successful run prints the verified signature claims; any other result means the image should not be trusted. cosign prefers digests over tags, so verify the exact digest you run (```...admin-image-ubuntu@sha256:<digest>```).

pushing to or deleting from the registry needs a personal access token with the matching package scopes ("write:packages", "delete:packages"); in practice only this repository's workflows do that.

## license and security

released under the [MIT License](LICENSE). to report a vulnerability, follow [SECURITY.md](SECURITY.md).
