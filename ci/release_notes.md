# Fixes

- The `shield-agent` job can now be deployed via `bosh create-env`,
  since it no longer uses the `-%>` ERB template delimiter.

- The `shield-agent` job now expects `agent.key` to be the SSH
  authorized key (`ssh-rsa AAA...`) format, instead of the private
  key.  This is a change from previous 8.x versions, but the
  warnings in the template rendering should guide you well.
