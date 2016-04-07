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
docker run --rm -i -t -p 8000:8000 gavodocker:latest /usr/bin/gavo serve start
``` 


