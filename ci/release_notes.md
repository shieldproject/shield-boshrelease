# Software Updates

- Bumped shield to v8.0.16.  This necessitated a small change in
  the `web_root` directive; which shouldn't affect operation, but
  does cause the BOSH release to pass newer, more stringent
  parameter validation in `shieldd`.
