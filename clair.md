
# Server Installation

* Check https://github.com/ziozzang/security/raw/master/run_clair.sh

```
# Update DB daily. pull it in the morning!
DATE=`date +%Y-%m-%d`
docker pull arminc/clair-db:${DATE}
docker run -d --name clair-db arminc/clair-db:${DATE}
docker run -p 6060:6060 --link clair-db:postgres -d --name clair-server arminc/clair-local-scan:v2.0.0

# or Just download Shell script.
wget https://github.com/ziozzang/security/raw/master/run_clair.sh && chmod +x run_clair.sh

```

# Testing

* using [reg](https://github.com/jessfraz/reg#vulnerability-reports)
```
./reg -d -r registry.access.redhat.com  vulns --clair http://127.0.0.1:6060 rhel7-atomic
```

# Source
https://github.com/coreos/clair

# Comments
* https://github.com/arminc/clair-local-scan/blob/master/.travis.yml
DB is automatically downloaded from original source. but It's too long to download. so, just fetch from docker hub. :)
travis automatically generate DB. :)
