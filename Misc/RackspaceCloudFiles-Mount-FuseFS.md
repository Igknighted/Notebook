# CloudFiles Mounting
```
yum install development-tools -y
yum install -y libxml2-devel libcurl-devel fuse-devel fuse-libs openssl-libs openssl-devel
cd /usr/src/
wget github.com/redbo/cloudfuse/tarball/master
tar -xvf master
cd redbo-cloudfuse-*
./configure
make
make install

cat ~/.cloudfuse
username=
api_key=
auth_url=https://auth.api.rackspacecloud.com/v1.0
use_snet=true
cache_timeout=600
```
