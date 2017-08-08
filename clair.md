
# Server Installation

```
# Update DB daily. pull it in the morning!
DATE=`date +%Y-%m-%d`
docker pull arminc/clair-db:${DATE}
docker run -d --name clair-db arminc/clair-db:${DATE}
docker run -p 6060:6060 --link clair-db:postgres -d --name clair-server arminc/clair-local-scan:v2.0.0

```

# Testing

* using [reg](https://github.com/jessfraz/reg#vulnerability-reports)
```
./reg  -d vulns --clair http://127.0.0.1:6060 sandbox/base
```

# Source
https://github.com/coreos/clair
