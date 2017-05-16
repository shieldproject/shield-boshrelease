# Upgrade to Cloud Config

This guide discussions the process for upgrading your SHIELD BOSH deployment (assumes v6.8.0 of shield-boshrelease). This guide assumes you are also transitioning from `bosh` to `bosh2` CLI.

## Assumption

This guide assumes you've deployed SHIELD using the `templates/make_manifest` from v6.8.0 of shield-boshrelease

```
git clone https://github.com/starkandwayne/shield-boshrelease.git
cd shield-boshrelease
git checkout v6.8.0
./templates/make_manifest warden
bosh deploy
```

This guide will assume that currently your BOSH director does not have a cloud-config registered.

### Autoprovisioning can be ignored

Autoprovisioning is a lovely feature of SHIELD - you can declare the stores/policies/targets/jobs that you want in your BOSH manifest. It is optional - once they are autoprovisioned they are stored in SHIELD's database. If you stop autoprovisioning then nothing bad happens - the configuration is retained in the database.

## Operations files

The new `manifests/shield.yml` provides a fully working deployment of SHIELD. You will only need to make a few adjustments to it to migrate your existing deployment to the new `manifests/shield.yml` manifest.

First, the new manifest assumes your deployment name is `shield`. In the [example above](#assumptions), the deployment name is `shield-warden`.

We modify `manifests/shield.yml` using `bosh2` operation patch files.

Create one to patch the deployment `name:` field, say `tmp/operations/deployment-name.yml`:

```
---
- type: replace
  path: /name
  value: shield-warden
```

Humans are flexible. They can learn new passwords. But all the existing SHIELD agents are not so flexible. So we need to keep any existing API keys.

Similarly, you may have shared a public SSH key with SHIELD agents, so we need to keep the matching private SSH key in the new manifest.

Create `tmp/operations/auth.yml` and copy in the `shield.daemon.auth.api_keys` contents into the `value:` section below.

```
---
- type: replace
  path: /instance_groups/name=shield/jobs/name=shield-daemon/properties?/auth/api_keys
  value:
    key1: yeah-sure-you-can-provision-stuff-whatevs
```

Next, add the following to the same `tmp/operations/auth.yml` file:

```
- type: replace
  path: /instance_groups/name=shield/jobs/name=shield-daemon/properties?/ssh_private_key
  value: |-
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEAsHqfPXFIXG4qmz7n+YgisVsGQ760wc0jq9SQt/5kIdxPNjCd
    ...
    xReUPzb3rowTtI/4VgeOprchlWUspDoIfIlu4monWnIlx1412aRqPQ==
    -----END RSA PRIVATE KEY-----
```

## Cloud Config

```
bosh2 update-cloud-config manifests/cloud-config/migration-bosh-lite-cloud-config.yml
```

## Latest release

At the time of writing, you will need to create & upload this release:

```
git checkout links-and-cloud-config
bosh2 create-release
bosh2 upload-release
```

## Deployment

If your BOSH includes Credhub:

```
export BOSH_DEPLOYMENT=shield-warden
bosh2 deploy manifests/shield.yml \
  -o manifests/operators/migration-warden.yml \
  -o tmp/operations/deployment-name.yml \
  -o tmp/operations/auth.yml \
  -v postgres-password=admin -v shield-daemon-password=admin
```

If not using Credhub, add `--vars-store tmp/creds.yml`:

```
export BOSH_DEPLOYMENT=shield-warden
bosh2 deploy manifests/shield.yml \
  -o manifests/operators/migration-warden.yml \
  -o tmp/operators/deployment-name.yml \
  -o tmp/operators/auth.yml \
  --vars-store tmp/creds.yml \
  -v postgres-password=admin -v shield-daemon-password=admin
```
