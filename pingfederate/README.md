# Export

```console
curl --location --request GET 'https://admin.ping.darkedges.com/pf-admin-api/v1/bulk/export' --header 'X-XSRF-Header: PingFederate' --user "administrator:Passw0rd" -k > bulk-export/shared/data.json
docker run --rm -v $PWD/bulk-export/shared:/shared darkedges/ping-bulkexport-tools:latest /shared/pf-config.json /shared/data.json /shared/env_vars /shared/data.json.subst > bulk-export/shared/convert.log
cp bulk-export/shared/data.json.subst console/instance/bulk-config/
```
