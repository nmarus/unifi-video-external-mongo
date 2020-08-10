#!/usr/bin/env bash

# set -e

SYS_PROPS_PATH=/var/lib/unifi-video/system.properties
UNIFI_VIDEO_EXEC=/usr/sbin/unifi-video

# set database connection
sed -i 's/^\(app.db.host=\).*/\1'"${UBUV_DB_HOST}"'/' ${SYS_PROPS_PATH}
sed -i 's/^\(app.db.port=\).*/\1'"${UBUV_DB_PORT}"'/' ${SYS_PROPS_PATH}
sed -i 's/^\(db.name=\).*/\1'"${UBUV_DB_NAME}"'/' ${SYS_PROPS_PATH}

# set external ip address / hostname
if [ ! -z ${UBUV_EX_HOST+x} ]; then
  sed -i -E 's/^[#]?(system_ip=).*/\1'"${UBUV_EX_HOST}"'/' ${SYS_PROPS_PATH}
fi

# show system.properties
echo "--- system.properties ---"
cat ${SYS_PROPS_PATH}
echo "-------------------------"

# ${UNIFI_VIDEO_EXEC} --nodetach --verbose --debug start
${UNIFI_VIDEO_EXEC} --nodetach start
