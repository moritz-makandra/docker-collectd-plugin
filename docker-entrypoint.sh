#!/bin/ash
#shellcheck shell=dash

set -e

COLLECTD_CONFIG=${1:-/etc/collectd/collectd.conf}
COLLECTD_DIR=$(dirname "$COLLECTD_CONFIG")

if [ ! -d "$COLLECTD_DIR" ]; then
	mkdir -p "$COLLECTD_DIR"
fi

#cd $(dirname $0)

cat > "$COLLECTD_CONFIG" << EOF

Hostname    "${HOSTNAME:-$HOSTNAME}"
FQDNLookup   false

Interval     ${INTERVAL:-10}

Timeout         2
ReadThreads     5


TypesDB "/usr/share/collectd/docker-collectd-plugin/dockerplugin.db"

LoadPlugin python
LoadPlugin write_graphite

<Plugin python>
  ModulePath "/usr/share/collectd/docker-collectd-plugin"
  Import "dockerplugin"
  <Module dockerplugin>
    BaseURL "unix://var/run/docker.sock"
    Timeout 3
  </Module>
</Plugin>

<Plugin write_graphite>
  <Node "example">
    Host "${GRAPHITE_HOST:-locahost}"
    Port "${GRAPHITE_PORT:-2003}"
    Prefix "${GRAPHITE_PREFIX:-collectd}."
    Protocol "tcp"
    ReconnectInterval 0
    LogSendErrors true
    Postfix ""
    StoreRates true
    AlwaysAppendDS false
    EscapeCharacter "_"
    SeparateInstances false
    PreserveSeparator false
    DropDuplicateFields false
    ReverseHost false
  </Node>
</Plugin>

EOF

exec collectd -f -C "$COLLECTD_CONFIG"
