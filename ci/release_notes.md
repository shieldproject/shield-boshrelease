# Improvements

- Added the `scality` plugin. Previously this support was handled via the S3 plugin,
  but there were issues with multi-part uploads in scality, forcing the new plugin.
- Eliminated configuration leakage through process args during plugin execution.
