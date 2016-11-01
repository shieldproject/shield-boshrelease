## Improvements

- Upgraded to SHIELD 0.7.2, which includes many fixes.
  You may want to check those [Release Notes][shield-0.7.0] (0.7.1
  and 0.7.2 were minor bumps for pipeline reasons)

- New `shield.agent.ip` property, for when you just can't rely on
  IP address auto-detection (i.e. when deploying via `bosh-init`),
  and you still want to auto-provision stuff.

- You can now disable SSL/TLS on the SHIELD Web UI / API.
  This isn't recommended, but you can do it.

[shield-0.7.0]: https://github.com/starkandwayne/shield/releases/tag/v0.7.0
