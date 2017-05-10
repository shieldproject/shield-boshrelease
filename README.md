S.H.I.E.L.D. Backup Solution
============================

Questions? Pop in our [slack channel](https://cloudfoundry.slack.com/messages/shield/)!

[SHIELD][shield] provides an easy-to-use backup solution for BOSH
deployed services, for operations and appliction delivery teams.

This repository packages SHIELD in a BOSH release for deploying
backups to your BOSHified environment.

It provides both the core backup system (complete with a Web UI),
as well as a lightweight agent for facilitating locally-initiated
backup / restore operations.

Getting Started on BOSH-lite
----------------------------

To deploy SHIELD to any BOSH with a standard cloud-config:

```
git clone https://github.com/starkandwayne/shield-boshrelease
cd shield-boshrelease
bosh deploy manifests/shield.yml
```

The IP of the `shield` instance can be found with `bosh instances` (`10.244.0.7` in example below):

```
$ bosh instances
Instance                                     Process State  AZ  IPs
shield/65424ae5-80b9-42b9-a223-2f732d6085c4  running        z1  10.244.0.7
```

Alternately, to expose SHIELD via a public https endpoint, you can use https://ngrok.com

```
bosh deploy manifests/shield.yml \
  -o manifests/operators/ngrok.yml \
  -v ngrok-authtoken=${NGROK_TOKEN:?required} \
  -v ngrok-subdomain=${BOSH_DEPLOYMENT}
open https://${BOSH_DEPLOYMENT}.ngrok.com
```

Open the https URL in your browsers - for example `https://10.244.0.7` or `https://${BOSH_DEPLOYMENT}.ngrok.com` - and you'll need to login with basic auth credentials.

The username is `admin`, and the randomly generated password (stored in credhub) is can be found with:

```
./bin/shield-password
```

It should look something like this:

![Web Interface Screenshot][screen1]

Or, if you prefer, you can install the [SHIELD CLI][cli-dl] and
access your SHIELD core directly:

    shield create backend my-shield http://10.244.2.2
    shield backends


Getting Started on vSphere
--------------------------

If you want to deploy SHIELD and some agents on your vSphere,
you can use [Genesis][genesis] and the [shield-deployment][tpl]
template, which has site templates for vSphere:

    cd ~/ops
    genesis new deployment --template shield-deployment shield
    genesis new site --template vsphere my-site
    genesis new environment my-site my-env
    cd my-site/my-env

From here, you'll want to make sure your name is correct in
`name.yml`:

    ---
    name: my-shield

and that your BOSH director's UUID is set in `director.yml`:

    ---
    director_uuid: YOUR-DIRECTOR-UUID

From there, with your BOSH director targeted, you can deploy it:

    make deploy


Setting up Agents
-----------------

Some data systems can only be backed up from a local process;
Redis works this way, since it dumps the backup to local disk.
For those systems, you must set up a SHIELD agent, and then
configure SHIELD to initiate the backup via that agent.

It's easy.

Just add the release to the deployment manifest, add the
`shield-agent` template to the job(s) in question, and set up the
`autoprovision` property to the URL of the SHIELD
endpoint (so that it can pull down a host key for validating
backup/restore operation requests).

    ---
    releases:
      - name:    shield
        version: latest

    jobs:
      - name: first-job
        templates:
          - release: shield
            name:    shield-agent

    properties:
      shield:
        agent:
          autoprovision: https://my-shield-endpoint       # <--- change this


Parts of a SHIELD Deployment
----------------------------

SHIELD provides the following job templates:

### shield-daemon

This is the SHIELD core daemon.  It provides the metadata services
(defining targets, stores, schedules, retention policies and jobs),
and runs jobs on schedule.  It also provides the API for the
command-line utility to use, as well as the Web UI for easier
administration of a SHIELD installation.

Every SHIELD deployment requires an instance of this job.

### nginx

SHIELD uses nginx to provide SSL/TLS termination.  The nginx job
handles the certificates and keys, and proxies to the
`shield-daemon` port for application requests.

### postgres

SHIELD stores its data in a backend PostgreSQL database.  This job
provides the machinery to run that database, including schema
management.

Every SHIELD deployment requires an instance of this job.

### shield-agent

The SHIELD agent is a small daemon that runs on target data system
deployments (i.e. your Redis deployment, or your the database
component of some other deployment), and fields requests for
backup and restore operations.

Note: if your target data system can be easily and quickly backed
up via network-accessible interfaces, you don't technically need
this job.

### agent-pgtools

Provides additional utilities for the `postgres` plugin to use, in
conjunction with `shield-agent`, for use when loading the agent on
PostgreSQL database VMs.

### agent-mysql

Provides additional utilities for the `mysql` plugin to use, in
conjunction with `shield-agent`, for use when loading the agent on
MySQL database VMs.

Available Plugins
-----------------

SHIELD ships with the following plugins baked right in:

### postgres

A _target plugin_ for backing up one or more (or all!) PostgreSQL
databases on a cluster.

[Documentation available here][plugin-postgres-docs]

### mysql

A _target plugin_ for backing up one or more (or all!) MySQL
databases on a node.

[Documentation available here][plugin-mysql-docs]

### fs

A _target plugin_ for backing up a directory on-disk, as a
tarball, complete with ownership and permissions metadata.

A _store plugin_ for storing archive blobs to disk.

[Documentation available here][plugin-fs-docs]

### s3

A _store plugin_ for storing archive blobs in an S3 bucket.

[Documentation available here][plugin-s3-docs]

### xtrabackup

A _target plugin_ for backing up one or more (or all!) MySQL
databases on a node.

[Documentation available here][plugin-xtrabackup-docs]



[shield]:  https://github.com/starkandwayne/shield
[screen1]: https://raw.githubusercontent.com/starkandwayne/shield-boshrelease/master/doc/webui.png
[tpl]:     https://github.com/starkandwayne/shield-deployment
[genesis]: https://github.com/starkandwayne/genesis
[cli-dl]:  https://github.com/starkandwayne/shield

[plugin-postgres-docs]: https://godoc.org/github.com/starkandwayne/shield/plugin/postgres
[plugin-mysql-docs]:    https://godoc.org/github.com/starkandwayne/shield/plugin/mysql
[plugin-fs-docs]:       https://godoc.org/github.com/starkandwayne/shield/plugin/fs
[plugin-s3-docs]:       https://godoc.org/github.com/starkandwayne/shield/plugin/s3
[plugin-xtrabackup-docs]:       https://godoc.org/github.com/starkandwayne/shield/plugin/xtrabackup
