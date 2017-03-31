# Bug Fixes

- Fixed issue introduced in 6.6.1 inadvertently requiring `shield.agent.autoprovision`.
  It is now optional, as it used to be. One of `shield.agent.autoprovision` or
  `shield.agent.daemon_public_key` must still be specified.
