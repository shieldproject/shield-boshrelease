## Release Notes
* Fixes a bug with the Postgres restore plugin where the restore would fail if any given line in the dump file was too long.
* Fixes a bug where an initial run of `create backend` would fail if the user's home directory was on a different filesystem than `/tmp`.
* The backend name is now displayed in the CLI when executing a command, in addition to its IP.
* The help dialogues for the `backend` commands now give the flags required.
* The shield plugins will no longer display the endpoint argument (potentially along with credentials contained within) in the process name.
