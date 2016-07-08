# Bug Fixes

- Add a timeout of 20 seconds to the curl call that retrieves the
  public key from the SHIELD core, to avoid deadlock conditions
  that arise when the start script cannot access the core, either
  due to networking issues, naming problems, or firewall / ACLs.
