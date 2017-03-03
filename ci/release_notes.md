# Bug Fixes

- `shield-agent` now fails out if it has no authorized keys.  For
  autoprovision'd setups, this is most useful, as it means the
  agent effectively waits for the daemon to be available before it
  reports success back to monit.  Fixes #68

# shield
Bumped https://github.com/starkandwayne/shield to v0.10.1
