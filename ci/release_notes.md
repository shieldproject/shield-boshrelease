# Improvements

- New `ulimit.fds` property allows operators to set a higher file
  descriptor limit for the shield-agent process.

# Bug Fixes

- The vault.keys file is now properly migrated to vault.crypt.
  If upgrading from SHIELD 8.0.8, your vault data should now be
  retained.

- Only replace the `(generated-token)` value in the import
  manifest when the user has asked us to generate a token.

# shield
Bumped shield to v8.0.11
