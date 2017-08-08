#!/bin/bash
# Code by Jioh L. Jung <ziozzang@gmail.com>
#
# - to run Clair server with latest updated DB
#


if [[ `uname` == 'Linux' ]]; then
   if [ -f "/bin/busybox" ]; then
     CDATE=`date -I`
     YDATE=`date -D "%s" -d $(( $(/bin/date +%s ) - 86400 )) +%Y-%m-%d`
     YYDATE=`date -D "%s" -d $(( $(/bin/date +%s ) - 172800 )) +%Y-%m-%d`
   else
     CDATE=`date +%Y-%m-%d`
     YDATE=`date -d -1days +%Y-%m-%d`
     YYDATE=`date -d -1days +%Y-%m-%d`
   fi
else
   # For OSX
   CDATE=`date +%Y-%m-%d`
   YDATE=`date -j -v -1d  +%Y-%m-%d`
   YYDATE=`date -j -v -2d  +%Y-%m-%d`
fi
echo $CDATE
echo $YDATE
echo $YYDATE
DATE=${CDATE}


# Kill Containers
docker rm -f clair-server || true
docker rm -f clair-db || true

# Fetch Today's version
docker pull arminc/clair-db:${DATE}
if [ `docker images arminc/clair-db:${DATE} | grep "arminc/clair-db" | wc -l` -eq "0" ]; then
  # If failed, try yesterday.
  echo "FAILED"
  DATE=${YDATE}
  docker pull arminc/clair-db:${DATE}
  if [ `docker images arminc/clair-db:${DATE} | grep "arminc/clair-db" | wc -l` -eq "0" ]; then
    echo "$DATE FAILED"
    DATE=${YYDATE}
    docker pull arminc/clair-db:${DATE}
  fi
fi

docker run -d --name clair-db arminc/clair-db:${DATE}

while true; do
  # wait to open port on DB server
  if [ `docker logs clair-db 2>&1 | grep started | wc -l` -gt "0" ] ; then
    break
  fi
done

# Clear Old Clair DB images.
docker images | grep clair-db | grep -v "${DATE}" | awk '{print $3}' | xargs docker rmi {} || true

# Run Clair Server
docker run -p 6060:6060 --link clair-db:postgres -d --name clair-server arminc/clair-local-scan:v2.0.0
