# Core Enhancements

- SHIELD now works with MySQL and MariaDB databases. Use the configuration
  option `database_type` to set the database driver to `mysql`.

# Bug Fixes

- Add a timeout of 20 seconds to the curl call that retrieves the
  public key from the SHIELD core, to avoid deadlock conditions
  that arise when the start script cannot access the core, either
  due to networking issues, naming problems, or firewall / ACLs.
- Fixes a bug where `shield list jobs --paused/--unpaused` is reversed.
