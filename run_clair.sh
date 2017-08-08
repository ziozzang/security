#!/bin/bash
# Code by Jioh L. Jung <ziozzang@gmail.com>
#
# - to run Clair server with latest updated DB
#

if [[ $platform == 'linux' ]]; then
   CDATE=`date +%Y-%m-%d`
   YDATE=`date -d -1days +%Y-%m-%d`
else
   # For OSX
   CDATE=`date +%Y-%m-%d`
   YDATE=`date -j -v -1d  +%Y-%m-%d`
fi
DATE=${CDATE}

# Kill Containers
docker rm -f clair-server || true
docker rm -f clair-db || true

# Fetch Today's version
docker run -d --name clair-db arminc/clair-db:${DATE}
if [ $? -ne "0" ]; then
  # If failed, try yesterday.
  DATE=${YDATE}
  docker run -d --name clair-db arminc/clair-db:${DATE}
fi

while true; do
  # wait to open port on DB server
  if [ `docker logs clair-db 2>&1 | grep started | wc -l` -gt "0" ] ; then
    break
  fi
done

# Clear Old Clair DB images.
docker images | grep clair-db | grep -v "${DATE}" | awk '{print $3}' | xargs docker rmi {}

# Run Clair Server
docker run -p 6060:6060 --link clair-db:postgres -d --name clair-server arminc/clair-local-scan:v2.0.0
