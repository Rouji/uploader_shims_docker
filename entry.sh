#!/bin/sh
if [ -z "$UPSTREAM_URL" ]; then
    echo "\$UPSTREAM_URL not set"
    exit 1
fi

[ -z "$FORM_FIELD" ]     && FORM_FIELD="file"
[ -z "$NC_TIMEOUT" ]     && NC_TIMEOUT=5
[ -z "$SSH_TIMEOUT" ]    && SSH_TIMEOUT=5


NC2P="nc2p -l 0.0.0.0 -p 9999 -f ${FORM_FIELD} -n nc2p -t ${SSH_TIMEOUT} ${UPSTREAM_URL}"
SSH2P="ssh2p -l 0.0.0.0 -p 22 -f ${FORM_FIELD} -n ssh2p -t ${NC_TIMEOUT} -r /rsa/id_rsa ${UPSTREAM_URL}"
SUP="/etc/supervisord.conf"
sed -i "s|###NC2P_GOES_HERE###|${NC2P}|" $SUP
sed -i "s|###SSH2P_GOES_HERE###|${SSH2P}|" $SUP

mkdir -p /rsa

[ -f "/rsa/id_rsa" ] || ssh-keygen -t rsa -f /rsa/id_rsa

exec /usr/bin/supervisord -c /etc/supervisord.conf
