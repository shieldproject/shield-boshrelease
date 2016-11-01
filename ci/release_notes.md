## Improvements

- Upgraded to SHIELD 0.7.2, which includes many fixes.
  You may want to check those [Release Notes][shield-0.7.0] (0.7.1
  and 0.7.2 were minor bumps for pipeline reasons)

- New `shield.agent.ip` property, for when you just can't rely on
  IP address auto-detection (i.e. when deploying via `bosh-init`),
  and you still want to auto-provision stuff.

- You can now use the autoprovisioning features of the
  `shield-agent` job to provision out your Schedules and Retention
  Policies.  Automatically.  Life is good.

- You can now disable SSL/TLS on the SHIELD Web UI / API.
  This isn't recommended, but you can do it.

- Job spec file property definitions are more accurately
  described.  If you like to read raw spec files to figure out how
  to use BOSH releases, you're welcome.

## Deprecated Things

- Singular auto-provisioning properties (`shield.job`,
  `shield.target`, `shield.store`, `shield.schedule` and
  `shield.retention` are no longer supported.  Use the map-based
  plural variants instead.

- Auto-provisioning on the `shield-daemon` job is now deprecated.
  All object types can be provisioned by the `shield-agent` job.
  Unless you are running a SHIELD without an agent, you won't
  notice a thing.

[shield-0.7.0]: https://github.com/starkandwayne/shield/releases/tag/v0.7.0
