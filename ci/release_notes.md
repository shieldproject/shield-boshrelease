This release packages SHIELD v8.
SHIELD v8 is a dramatic overhaul of the SHIELD Data Protection
System, and this BOSH release version is a severe departure from
the previous methods of deploying SHIELD.


Upgrading from v6.x / v7.x
--------------------------

This section details deployment manifest changes that operators
will need to apply in order to migate from v6 / v7 of SHIELD to
this (v8) release.

### Changes to the `shield-daemon` job (now `core`)

The `shield-daemon` job is now just `core`.

The `name` property is gone.  In its place are the following
properties for identifying your SHIELD:

  - `core.env` - The name of the environment, like "sandbox" or
      "production", or "a testing shield instance", or "fred".
  - `core.color` - A CSS color name, or hexadecimal RGB color to
      use for the environment name in the new web UI.  `yellow`
      and `green` look nice.
  - `core.motd` - A (possible multi-line) message that will be
      displayed to users logging into SHIELD.  Useful for whatever
      messages of the day are generally useful for (compliance,
      advertising maintenance windows, etc.)

`workers` has been renamed to `core.workers`, but otherwise retains
its semantic meaning.

`max_timeout` has been renamed to `core.task-timeout`, but
otherwise retains its semantic meaning.

`ssl.key`, `ssl.crt`, and `ssl.timeout` have been renamed to
`tls.key`, `tls.certificate`, and `tls.reuse-after`, respectively.
The default value of `tls.reuse-after` was dropped from 12 (hours)
to 2 (hours).

The `ssh_private_key` has been renamed to `agent.key`, because
it's not used for SSH in the same sense as most SSH (RSA) keys.
Its value should stay the same for a smooth upgrade.

The `database.*` properties have been removed; SHIELD v8 has its
own internal data store that does not need to be configured by the
operator.  See the **Database Migration** subsection, later, for
details on migrating your data into this new data store.

The `auth.oauth.*` properties have been removed;  SHIELD v8
supports multiple (possibly OAuth2-based) authentication
providers.  These are configured under the new top-level
`authentication` key.

The `auth.username` and `auth.password` properties have been
removed;  SHIELD v8 no longer supports simple HTTP Basic
Authentication.  Instead, it features a robust user authentication
system backed by an internal local user database.  Two new
properties, `failsafe.username` and `failsafe.password` kind of
take over for these deprecated properties.  They specify a
username and (cleartext) password that SHIELD will insert into the
local user database if it boots up and finds that no users exist
yet.  This "failsafe" is intended to provide a secure way of
bootstrapping a SHIELD environment, without being stuck with a
user whose password is in a BOSH manifest somewhere.
Administrators are free to delete the failsafe user once they have
set up other accounts.

The `auth.api_keys` property has been removed; SHIELD v8 does not
support API Keys in the same fashion as its predecessors.
Instead, user accounts are free to issue _Auth Tokens_ that behave
a stand-ins for their issuer (not unlike Github Personal Access
Tokens).

`nginx.worker_processes` has been shortened to `nginx.workers`.

`nginx.worker_connections` has been shortened to
`nginx.connections`.

`nginx.keepalive_timeout` has been shortened to `nginx.keepalive`.

The `log_level` property has been renamed to `log-level`.

### Changes to the `shield-agent` job

This job is still called `shield-agent`, since it needs to be
unique across a wide variety of other deployments.

`name` is a new property for specifying the name this agent will
use when registering with the SHIELD Core.

`autoprovision` has been removed.  Its usage was always
problematic, and with the introduction of proper BOSH links, we
only need to specify where and how to talk to the SHIELD Core in
the event that our Core lives on another BOSH director (which is
rare).

`shield-url` is a new property that kind of takes the place of
`autoprovision`, by allowing operators to identify where their
SHIELD Core lives, as a full URL (i.e.
"https://shield.example.com")

`require-shield-core` is a new property that lets operators ignore
an error condition whereby an agent is unable to communicate with
the SHIELD Core.  In theory, that is a show-stopping problem, but
in practice, we found that it held up too many deployments for
legitimate reasons, ranging from simple network connectivity
issues and firewalling to more mundane problems like "we haven't
deployed SHIELD itself yet."

The `daemon_public_key` property has been removed.  In its place
is the new `agent.key` property.  The most important difference
between these two properties is that `daemon_public_key` was the
authorized_keys-formatted public key, and `agent.key` is the
**private key** that the SHIELD Core also specifies as
`agent.key`.  Internally, the BOSH release will extract the
correctly formatted public fingerprint from the private key.

Note that if the `shield` link is in use, you don't need to
explicitly set `agent.key` -- the agent startup scripts will just
retrieve the public key from the SHIELD Core automagically.  This
allows SHIELD site operators to rotate that key with minimal fuss.

The `recovery.*` properties have been removed, since SHIELD v8's
new encryption feature makes it difficult to restore backups
outside of the watchful eye of a running SHIELD Core.

For SHIELD Agents that need to operate behind HTTP proxies, three
new `env.*` properties were added.  `env.http_proxy` and
`env.https_proxy` allow you to specify the full URL for an
upstream proxy that will handle (respectively) cleartext HTTP
requests and TLS-encrypted HTTPS requests.  The `env.no_proxy`
property is a list of FQDNs, domain fragments, and IP addresses
that will be flattened and joined by commas to fashion an
exclusion list to put in the `$no_proxy` environment variable.

The new `env.path`, `env.libs`, and `env.auto` properties control
how the SHIELD agent process will set up its environment, for the
benefit of executed plugins.

`env.path` is a list of auxiliary paths to bin/ and sbin/
directories that you want to manually inject into the `$PATH` of
the running shield-agent / plugins.

`env.libs` is a list of auxiliary paths to lib/ directories that
you want / need in your `$LD_LIBRARY_PATH` for dynamic shared
object runtime loading.

`env.auto` is a boolean; if set, the shield-agent job will go
looking for installed BOSH packages named `shield-addon-*`, add
any bin/ and sbin/ directories to `$PATH`, and add any lib/
directories to `$LD_LIBRARY_PATH`.  This allows you to augment an
agent with additional command-line tools it might need, like
specific versions of `psql`, or `xtrabackup`.  `env.auto` is on by
default.

The auto-provisioning properties `stores`, `targets`,
`retention-policies`, and `jobs` have all been removed, in favor
of the new `buckler import`-based `import` errand.

The `log_level` property has been renamed to `log-level`.

### Removed Jobs

The `agent-mysql` and `xtrabackup` jobs have been removed.  If you
need to augment a SHIELD agent with MySQL / MariaDB tools, you can
try the nee [SHIELD MySQL Addon][mysql-addon], which contains all
of these packages.

The `agent-pgtools` job has been removed.  If you need to augment
a SHIELD agent with PostgreSQL tools, you can try the new [SHIELD
PostgreSQL Addon][postgres-addon].

The `mongo-tools3.2` and `mongo-tools3.4` jobs have been removed.
They too have moved into a separate BOSH release, the [SHIELD
MongoDB Addon][mongodb-addon].

The `postgres` and `mariadb` jobs have been removed.  SHIELD v8
now leverages a standalone, dedicated database that is baked into
the new `core` job.  See the subsection **Database Migration**,
below, for details on migrating your SHIELD data.

### The New Import Errand

Previous versions of the SHIELD BOSH release used a post-start
script and `shield-agent` properties to facilitate a form of
configuration auto-provisioning.

In v8, this has all been replaced by the new `import` errand,
which drives the much more powerful and flexible `buckler import`
command-line tool.

The `import` errand takes a single property, `import`, which is a
full recipe of things to import into SHIELD, as understood by the
`buckler` tool's `import` sub-command.

Here's an example that sets up a bunch of stuff:

```yaml
- name: import
  lifecycle: errand
  instances: 1
  azs: [z1]
  vm_type:         default
  stemcell:        default
  networks: {name: default}
  jobs:
    - name:    import
      release: shield
      properties:
        import:
          core:  https://shield.example.com
          token: ... # an auth token, from `buckler create-auth-token`

          global:
            storage:
              - name: S3 Cloud Storage
                summary: |
                  Public S3 cloud storage for all SHIELD tenants to use
                agent:  127.0.0.1:5444
                plugin: s3
                config:
                  access_key_id:     AKI12
                  secret_access_key: secret

            policies:
              - name: Long-Term Storage
                days: 90

          users:
            - name:     James Hunt
              username: jhunt
              password: sekrit
              sysrole:  admin
              tenants:
                - name: Stark & Wayne
                  role: admin

          tenants:
            - name: CF Community
              members:
                - user: jhunt@local
                  role: admin
              storage:
                - name: Scality
                  agent:  10.32.45.10:5444
                  plugin: scality
                  config:
                    s3_host: 10.32.45.1
                    s3_port: 8200
                    bucket:  my-bucket

              policies:
                - name: Short-Term
                  days: 7
                - name: Long-Term
                  days: 90

              systems:
                - name:   BOSH
                  agent:  10.4.0.1:5444
                  plugin: postgres
                  config: {}
                  jobs:
                    - name:    Daily
                      when:    daily 4am
                      policy:  Short-Term
                      storage: Scality
                      paused:  true

                    - name:    Monthly
                      when:    every month on the 1st at 3am
                      policy:  Long-Term
                      storage: Scality
```


### New Encryption Vault

SHIELD v8 encrypts all backup archives, and it uses a unique,
randomly generated initialization vector and encryption key for
each new archive.  These secrets are required for restoration, and
they have to be stored somewhere safe, so we store then in an
encrypted vault.

For the most part, the care and feeding of this vault is entirely
handled for you.  However, the deployment needs to configure an
X.509 Certificate Authority, and issue an X.509 Certificate for
the IP SAN 127.0.0.1.


### Database Migration

SHIELD v8 introduces several new features, including a new
built-in data store.  Chances are if you are upgrading from a
previous version of SHIELD (either v6 or v7), you are going to
want to migrate all that data.  To do so safely and effectively,
you just need to specify the `migrate-from.type` and
`migrate-from.dsn` properties in your SHIELD deployment manifest.

For example, if you had a v6 SHIELD BOSH deployment manifest with
`shield-daemon` properties that looked like this:

```yaml
# old school
properties:
  database:
    type:     postgres
    host:     10.5.6.7
    port:     5524
    username: dba
    password: sekrit
    database: shield1
```

Then your `migrate-from.type` should be "postgres", and
`migrate-from.dsn` should roll up all that connectivity
information in a PostgreSQL data source name, like this:

```yaml
# new school
properties:
  migrate-from:
    type: postgres
    dsn: postgres://dba:sekrit@10.5.6.7:5524/shield1?sslmode=disable
```

Likewise, if you used to use MySQL for SHIELD, and had this in
your manifest:

```yaml
# old school
properties:
  type:     mysql
  host:     172.15.3.4
  port:     3316
  username: scyld
  password: sekrit
  database: shielddb
```

You would want to specify this to engage data migration:

```yaml
# new school
properties:
  type: mysql
  dsn:  scyld:sekrit@tcp(172.15.3.4:3316)/shielddb
```

Refer to the [lib/pq documentation][pq-dsn] and the
[go-sql-driver/mysql documentation][my-dsn] for more details.

Note that database migration is a once-only affair.  If the
internal database file exists, the release will skip migration
altogether.  This takes some of the urgency out of needing to
"clean up" your deployment manifest to remove the `migrate-from.*`
properties.



[mysql-addon]:    https://github.com/shieldproject/shield-mysql-addon-boshrelease
[postgres-addon]: https://github.com/shieldproject/shield-postgres-addon-boshrelease
[mongodb-addon]:  https://github.com/shieldproject/shield-mongodb-addon-boshrelease

[pq-dsn]:         https://godoc.org/github.com/lib/pq
[my-dsn]:         https://github.com/go-sql-driver/mysql#dsn-data-source-name
