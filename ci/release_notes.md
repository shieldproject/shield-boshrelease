# Improvements

- The `core` job now installs the SQLite3 command-line utility,
  `sqlite3`, via the "sqlite3" package.

- A new `envrc` file is now bundled in the `core` job, so that you
  can source it in a `bosh ssh` session.  It updates `$PATH`, and
  defines to helpful environment variables:

  - `$SHIELD_DATADIR` - The path to the SHIELD core data directory
    (where the database and vault files are kept)

  - `$SHIELD_DB` - The full path to the SHIELD database.
    This lets operators run `sqlite3 $SHIELD_DB` to get into the
    database, without mucking about with paths.

# shield
Bumped shield to v8.0.14
