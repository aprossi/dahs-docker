# gavo-docker

This is an attempt to make a working (for teaching/training purposes) installation of GAVO/DAHS on docker, based on the tutorial on https://voparis-confluence.obspm.fr/pages/viewpage.action?pageId=560675

The image is based on Debian 8.2.

# build

with the [Dockerfile](Dockerfile) available on current working directory:

```
docker build -t gavodocker:latest .
```

or directly from here

```
docker build -t gavodocker:latest https://raw.githubusercontent.com/aprossi/gavo-docker/master/Dockerfile
```

# Run

```
docker run --rm -i -t \
-v ~/files-for-docker:~ \
-e DISPLAY=XXX.XXX.XXX.XXX:0 \
gavodocker:latest
```

where ```XXX.XXX.XXX.XXX``` is the IP of the **host**

e.g. on a mac laptop en0 = ethernet en1 = wi-fi (I guess):


e.g. in bash (in the host docker shell):

```
IPHOST="$(ifconfig en1 | grep "inet " | cut -d ' ' -f 2)"
```


```
docker run --rm -i -t \
-v ~/files-for-docker:~ \
-e DISPLAY=$IPHOST:0 \
gavodocker:latest /bin/bash
```


