# New Features

- **Authentication and Authorization!**
  SHIELD now supports options for authenticating requests to it!
  It supports HTTP Basic authentication, OAuth2 (currently the
  only supported provider is github), and API Keys. If no authentication
  configuration is provided, SHIELD will default to HTTP Basic Auth,
  using a default user/password.
- **SSL Required**
  SHIELD now runs behind an nginx instance doing SSL termination.
  If you do not specify a key, one will be auto-generated for you,
  making an easier transition. Additionally, non-encrypted requests
  will be redirected to https for you.

# Bug Fixes

- Remove console.log calls from frontend Web UI Javascript,
  for those poor souls who don't run with web debugging on
  everywhere...
- Fix an issue with the `creator` function that prevented
  creation of new things (targets, schedules, etc.) from the
  frontend Web UI.
- Support Chrome's insistence that `type="date"` input fields be
  formatted according to the HTML spec, and make the backup
  archive date range picker work.
