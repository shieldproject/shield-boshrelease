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
