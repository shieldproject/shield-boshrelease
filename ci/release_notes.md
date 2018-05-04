# Improvements

- Upgrade to SHIELD v8.0.9, which has numerous improvements of its
  own.  Check the [SHIELD v8.0.9 Release Notes][809rc].

- Allow (insecure) use of full credentials in a SHIELD import
  errand.  This isn't a great idea, but if you need it, you've got
  it now.

# Bug Fixes

- The `store` job now creates the directory it is going to use for
  WebDAV object storage, locally.

- Fixed an uninitialized variable issue in references to
  `LD_LIBRARY_PATH`, in the shield-agent job.
