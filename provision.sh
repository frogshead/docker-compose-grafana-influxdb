#!/usr/bin/env bash

set -o errexit
set -o nounset

source influx2.env

# Source InfluxDB v3 env if it exists
if [ -f influx3.env ]; then
    source influx3.env
else
    INFLUXDB3_AUTH_TOKEN="REPLACE_WITH_TOKEN"
fi

echo "==> Prepare Configurations"
sed -e 's/%%INFLUXDB_INIT_ORG%%/'${DOCKER_INFLUXDB_INIT_ORG}'/g' \
    -e 's/%%INFLUXDB_INIT_BUCKET%%/'${DOCKER_INFLUXDB_INIT_BUCKET}'/g' \
    -e 's/%%INFLUXDB_INIT_ADMIN_TOKEN%%/'${DOCKER_INFLUXDB_INIT_ADMIN_TOKEN}'/g' \
    -e 's/%%INFLUXDB3_AUTH_TOKEN%%/'${INFLUXDB3_AUTH_TOKEN}'/g' \
    grafana/etc/provisioning/datasources/datasource.yaml.template \
  > grafana/etc/provisioning/datasources/datasource.yaml

echo "==> Docker Image Pull"
docker compose pull

echo "==> Bring Up Services"
docker compose up -d
