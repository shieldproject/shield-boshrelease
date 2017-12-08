# Bug Fixes

- The nginx frontend now properly proxies normal HTTP and
  WebSocket requests through to the backend, avoiding a stall
  in the core scheduler brought on by dead broadcast receivers.

- Fixed an issue with some jobs that would overwrite PID files
  when trying to start jobs that were already running.

- Fixed an issue where the nginx proxy was up and ready before the
  shieldd process, leading to HTML and 502 Bad Gateway errors in
  the authorized_keys file during /v1/meta/pubkey provisioning.

# shield
Bumped https://github.com/starkandwayne/shield to v8.0.1
