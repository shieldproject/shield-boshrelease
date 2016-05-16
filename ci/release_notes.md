## Core Enhancements

- Properly handle secure redirection from insecure endpoints.  If
  you target a SHIELD over a non-HTTPS endpoint, the CLI will wait
  to see if it gets redirected to an HTTPS endpoint before sending
  any credentials.  Fixes shield/#151.
- Authentication now produces more helpful debugging and
  diagnostic information, to assist site operators in
  troubleshooting their auth setup.
- Users can now be granted access to SHIELD based on UAA
  credentials and their role assignments / memberships.

## Bug Fixes

- Fix a bug in the timespec scheduling logic for weekly jobs that
  would cause 60 separate tasks (one per second) to fire off when
  the weekly backup was to be run.
- Rename `nginx.ssl_cert` property to `nginx.ssl_crt`, so that
  custom certificates will work with SHIELD.
- Fix an off-by-one bug in the Web UI that was causing dates in
  May to display as dates in April (for example).

## S3 Plugin Enhancements

- The `s3_host` configuration option is now optional, and defaults
  to using Amazon's `s3.amazonaws.com` endpoint.
- The `prefix` configuration option is now optional, allowing
  backups to be placed directly in the root 
- The `skip_ssl_validation` configuration option now defaults to
  false (i.e., actually verify certs received from S3)
- The `socks5_proxy` configuration option now displays in
  validation output.

## Postgres Plugin Enhancements

- Now supports backing up a single database on a cluster, via the
  `pg_database` configuration option.
