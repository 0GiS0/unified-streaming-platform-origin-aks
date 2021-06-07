#!/bin/sh
set -e

# set env vars to defaults if not already set
if [ -z "$LOG_LEVEL" ]
  then
  export LOG_LEVEL=warn
fi

if [ -z "$LOG_FORMAT" ]
  then
  export LOG_FORMAT="%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\" %D"
fi

if [ -z "$REMOTE_PATH" ]
  then
  export REMOTE_PATH=remote
fi

if [ $USP_LICENSE_KEY ]
  then
  export UspLicenseKey=$USP_LICENSE_KEY
fi

# validate required variables are set
if [ -z "$UspLicenseKey" ]
  then
  echo >&2 "Error: UspLicenseKey environment variable is required but not set."
  exit 1
fi

# update configuration based on env vars
# log levels
/bin/sed "s@{{LOG_LEVEL}}@${LOG_LEVEL}@g; s@{{LOG_FORMAT}}@'${LOG_FORMAT}'@g;" /etc/apache2/sites-enabled/unified-origin.conf.in > /etc/apache2/sites-enabled/unified-origin.conf

# USP license
echo $UspLicenseKey > /etc/usp-license.key

rm -f /run/apache2/apache2.pid

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
  set -- apachectl "$@"
fi

exec "$@"