## Improvements

- Upgrade to SHIELD v0.7.3

- Operators can now directly control the Postgres log level,
  via the new `databases.log_level` manifest property.

- If you omit both `shield.agent.autoprovision` and
  `shield.agent.daemon_public_key`, you now get a warning from the
  BOSH director / CLI during configuration binding, rather than a
  failed deploy, later on.
