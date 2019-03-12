# Dell OpenManage containers

This is a repository that allows you to build containers for running the
OpenManage toolset using containers.  The different processes share their
state across an IPC using UNIX sockets, therefore, you'll need something
that allows things to sit in the same namespace.  We use Podman for this
internally.

## Why `run.sh`?

If you're a Dell employee reading this, *please* give us an option to run
the Dell services in foreground instead of letting them automatically fork
and run in the background.

If you're not, then the above should probably tell you enough.  The small
workaround that we do is check that the PID is still active while and sleep,
this is in order to make the container *actually* exit if the process dies.

In an ideal world, we run the process directly and everything works magically,
but, not today.

## Usage

```bash
# Build the containers
$ buildah bud -t vexxhost/openmanage:19.02.00 --build-arg VERSION=19.02.00 .

# Create a Pod for OpenManage
$ podman pod create -n openmanage

# Load IPMI module
$ modprobe ipmi_si

# Create containers for base services to provide functional CLI
$ mkdir -p /var/tmp/openmanage/.ipc
$ podman run --pod openmanage --privileged -d --name dsm_om_shrsvcd --device /dev/ipmi0 \
            --volume /var/tmp/openmanage/.ipc:/opt/dell/srvadmin/var/lib/openmanage/.ipc 
            vexxhost/openmanage:19.02.00 dsm_om_shrsvcd
$ podman run --pod openmanage --privileged -d --name dsm_sa_eventmgrd --device /dev/ipmi0 \
            --volume /var/tmp/openmanage/.ipc:/opt/dell/srvadmin/var/lib/openmanage/.ipc
            vexxhost/openmanage:19.02.00 dsm_sa_eventmgrd
$ podman run --pod openmanage --privileged -d --name dsm_sa_datamgrd --device /dev/ipmi0 \
            --volume /var/tmp/openmanage/.ipc:/opt/dell/srvadmin/var/lib/openmanage/.ipc
            vexxhost/openmanage:19.02.00 dsm_sa_datamgrd
$ podman run --pod openmanage --privileged -d --name dsm_sa_snmpd --device /dev/ipmi0 \
            --volume /var/tmp/openmanage/.ipc:/opt/dell/srvadmin/var/lib/openmanage/.ipc
            vexxhost/openmanage:19.02.00 dsm_sa_snmpd

# Run check_openmanage within a container
$ podman exec -it dsm_om_shrsvcd /usr/local/bin/check_openmanage
```