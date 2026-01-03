# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker Compose setup for a monitoring stack with Grafana (visualization), InfluxDB 2.x and 3.x (time-series databases), and Loki (log aggregation). This is a demonstration/development setup - review all env files before production use.

## Commands

### Start the stack
```bash
./provision.sh
```
This script:
1. Generates `grafana/etc/provisioning/datasources/datasource.yaml` from template using values in `influx2.env` and `influx3.env`
2. Pulls Docker images
3. Starts all services

### Clean up everything
```bash
./cleanup.sh
```
Interactive script that stops containers and optionally removes volumes.

### Manual Docker commands
```bash
docker compose up -d      # Start services
docker compose down       # Stop services
docker compose logs -f    # View logs
```

## Architecture

### Services (defined in docker-compose.yaml)
- **influxdb** (port 8086): InfluxDB 2.7.4-alpine - time-series database (Flux query language)
- **influxdb3** (port 8181): InfluxDB 3 Core - time-series database (SQL query language)
- **grafana** (port 3000): Grafana 11.4.0 - dashboards and visualization
- **loki** (port 3100): Grafana Loki 3.3.2 - log aggregation
- **mosquitto** (port 1883, 9001): Eclipse Mosquitto 2 - MQTT broker
- **telegraf**: Telegraf 1.33 - metrics collection (MQTT → InfluxDB v3)

### Configuration Files
- `influx2.env` - InfluxDB 2.x initialization (org, bucket, admin credentials, token)
- `influx3.env` - InfluxDB 3 auth token (generated after first run)
- `grafana.env` - Grafana plugins configuration
- `.env` - Docker Compose project name
- `grafana/etc/grafana.ini` - Full Grafana configuration
- `grafana/etc/provisioning/datasources/datasource.yaml.template` - Datasource templates
- `loki/etc/local-config.yaml` - Loki configuration (TSDB storage, v13 schema)
- `mosquitto/config/mosquitto.conf` - MQTT broker configuration
- `telegraf/telegraf.conf` - Telegraf MQTT consumer → InfluxDB v3 output

### Data Persistence
Docker volumes: `influxdb-lib`, `influxdb3-data`, `grafana-lib`, `grafana-log`, `loki-data`, `mosquitto-data`, `mosquitto-log`

## Access Points
- Grafana UI: http://localhost:3000 (default: admin/admin)
- InfluxDB 2.x UI: http://localhost:8086
- InfluxDB 3 API: http://localhost:8181
- Loki API: http://localhost:3100 (health: /ready, metrics: /metrics)

## InfluxDB 3 Setup

After first start, create an admin token:
```bash
docker exec influxdb3 influxdb3 create token --admin
```

Save the token to `influx3.env`:
```
INFLUXDB3_AUTH_TOKEN=<your-token>
```

Create a database:
```bash
docker exec -e INFLUXDB3_AUTH_TOKEN=<token> influxdb3 influxdb3 create database <name>
```
