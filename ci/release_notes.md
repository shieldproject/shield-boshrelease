* `shield-agent` job has new properties enabling backup and restore behind a proxy
 
     ```		
    env.http_proxy:		
       description: The URL of an upstream HTTP proxy for proxying all unencrypted web communications.		
    env.https_proxy:		
       description: The URL of an upstream HTTP proxy for proxying all encrypted web communications.		
    env.no_proxy:		
       description: A list of domains, partial domains (i.e. ".example.com"), and IP addresses that should not be routed through env.http_proxy and env.https_proxy.
     ```