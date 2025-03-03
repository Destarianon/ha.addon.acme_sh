# Home Assistant Add-on: ACME.sh Certs

A Home Assistant add-on that uses ACME.sh to generate certificates.

This addon uses LetsEncrypt by default.
Specify the `dns.provider` from the supported list at https://github.com/acmesh-official/acme.sh/wiki/dnsapi
Add environment variables to the `dns.env` list.  No need to add `export`.  NB: Do not use quotes in environment variables.
The server can be one listed at https://github.com/acmesh-official/acme.sh/wiki/Server (default: `letsencrypt`) or

## Troubleshooting
Enable the debug option to get verbose output
Certificates will be installed to `/ssl/`

## Config Example (not functional values)
```yaml
email: me@example.com
server: https://acme.example.com/acme/directory
server_rootca: |
  -----BEGIN CERTIFICATE-----
  WtUqsPZNre3XSCHk+8KBh5WUuOn....
  -----END CERTIFICATE-----
domains:
  - my.domain.tld
  - '*.my.domain.tld'
certfile: fullchain.pem
keyfile: privkey.pem
challenge: http
keylength: 2048
valid_to: "+5d"
```

## Automation 
Setup an automation to run 
```yaml
alias: Restart ACME.sh Addon
trigger:
  - platform: time
    at: "00:00"
action:
  - service: hassio.addon_restart
    data:
      addon: 5b07adba_acme_sh
initial_state: true
mode: single
description: Renew SSL Certificates
```