* `shield-daemon` job `shield-db` link is now optional (thanks @karampok)
* `shield-daemon` job has two new properties that can be overridden if you need to tweak these settings (thanks https://github.com/starkandwayne/shield-boshrelease/pull/90 from @karampok)

    ```
    workers:
      description: Max number of concurrent tasks in running state.
      default: 5
    max_timeout:
      description: Duration in hours after which a running task is timed out.
      default: 12
    ```

* shield-server blob now includes version number
