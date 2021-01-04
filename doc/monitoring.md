## monitoring implementation

__bosh releases used__
- scripting bosh release : https://bosh.io/releases/github.com/orange-cloudfoundry/generic-scripting-release?all=1
- cron bosh release : https://bosh.io/releases/github.com/cloudfoundry-community/cron-boshrelease?all=1
- shield bosh release : https://bosh.io/releases/github.com/starkandwayne/shield-boshrelease?all=1
- prometheus bosh release : https://bosh.io/releases/github.com/starkandwayne/shield-boshrelease?all=1

__solution outlines__
- each hour a cron job generates a static file (prometheus format) by using the shield v8 CLI on the shield VM
- embedded nginx configuration on the shield VM is overriden in order to serve this static file
- shield prometheus exporter is used in order to target the static file served by nginx and to scrape metrics
- custom rules are added on alert manager in order to trigger alerts on failed and paused jobs 

__details on static file generation__
the generation is achieved by using the cron bosh release. Each hour a metrics file (prometheus format) named /tmp/metrics is generated 
by a bash script which calls ShieldV8 CLI.
```
# HELP shield_job_paused Shield Job pause status (1 for paused, 0 for unpaused).
# TYPE shield_job_paused gauge
shield_job_paused{backend_name="(none)",environment="fe-int",job_name="mariabackup-192.168.116.221"} 0
# HELP shield_job_status Shield Job status (0 for unknow, 1 for pending, 2 for running, 3 for canceled, 4 for failed, 5 for done).
# TYPE shield_job_status gauge
shield_job_status{backend_name="(none)",environment="fe-int",job_name="postgresbackup-192.168.116.222"} 5
```
__details on embedded nginx configuration override__
in order to override nginx configuration, it is necessary to have an interception point before nginx server starts. The scripting bosh release
allows to inject custom bash script during bosh lifecycle deployment events (pre-start, post-start, post-stop, post-deploy, pre-stop). The choosen hook
is pre-start in this case.
```
...
    server {
      listen       9090;
      server_name  metrics;
      location / {
          root   /tmp;
          index  metrics;
          add_header Content-Type text/plain;
          autoindex on;
      }
    }
...
```
__details on shield prometheus exporter usage__
the shield prometheus exporter is added to the prometheus deployment
```yaml
- type: replace
  path: /instance_groups/name=prometheus2/jobs/name=prometheus2/properties/prometheus/scrape_configs/-
  value:
    job_name: shield_exporter
    scrape_interval: 2m
    scrape_timeout: 2m
    static_configs:
      - targets:
          - 192.168.99.26:9090 #static ip for master-depls/shieldv8
    relabel_configs:
      - source_labels:
          - job
        regex: "(.*)"
        target_label: bosh_deployment
        replacement: shared shieldv8

```
__details on custom rules__
custom rules are added to the prometheus deployment
```yaml
- type: replace
  path: /instance_groups/name=prometheus2/jobs/name=prometheus2/properties/prometheus/custom_rules?/-
  value:
    name: shield
    rules:
      - alert: ShieldJobPaused
        expr: shield_job_paused == 1
        labels:
          service: shield
          severity: critical
        annotations:
          description: The Shield Job `{{$labels.job_name}}` at `{{$labels.environment}}/{{$labels.backend_name}}` has been in a `paused` state
          summary: Shield Job `{{$labels.job_name}}` at `{{$labels.environment}}/{{$labels.backend_name}}` paused
      - alert: ShieldJobFailed
        expr: shield_job_status == 4 and shield_job_paused == 0
        labels:
          service: shield
          severity: critical
        annotations:
          description: The Shield Job `{{$labels.job_name}}` at `{{$labels.environment}}/{{$labels.backend_name}}` has been in a `failing` state
          summary: Shield Job `{{$labels.job_name}}` at `{{$labels.environment}}/{{$labels.backend_name}}` failed
```
