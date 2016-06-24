# Improvements

- Revamped SSH key support for agent/daemon communication.
  The SSH key is now required to be input, rather than having
  a key tied to stemcells + upgrades. Made property names more
  relevant for ssh key related properties.

# Job Property Renames/Removals

- The `shield.daemon.host_key` property is no longer used. It has
  been replaced by `shield.daemon.ssh_private_key`, with no default
  value. This *must* be specified in your manifest
- The `shield.agent.authorized_keys` property is no longer used. It
  has been replaced by `shield.agent.daemon_public_key`. The new value
  is a scalar of the public key corresponding to `shield.daemon.ssh_private_key`,
  whereas the old property was an array. The agent will continue to use this
  in conjunction with any key found via the `shield.agent.autoprovision`
  detection.
- The `shield.agent.authorize_generated_daemon_key` has been removed. It is no longer
  necessary, since the daemon key is no longer generated behind the scenes.
