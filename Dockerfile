FROM  alpine:3.17

RUN   apk update && apk add --no-cache python3 py3-dockerpty py3-dateutil collectd collectd-python

COPY dockerplugin.py dockerplugin.db /usr/share/collectd/docker-collectd-plugin/

COPY docker-entrypoint.sh /
RUN  chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
