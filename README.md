# docker-scripts
The docker scripts are based on the [Oracle docker-images](https://github.com/oracle/docker-images/) repository but modified so that resulting image is small enough to be used with Travis CI.

To use the scripts you need to download the archive of the desired DB version from the Oracle website.

To build an image go to the folder of desired DB version and execute
```
docker build --no-cache --force-rm --squash -t ut-img12c-r2-se2 .
```
ut-img12c-r2-se2 - is the image name. 

**Don't forget the dot(!) at the end of the command**

When the image is ready all you need is to publish it to your _private_ repository:
```
docker tag ut-img12c-r2-se2 utplsqlv3/oracledb:12c-r2-se2
docker login
docker push utplsqlv3/oracledb:12c-r2-se2
```

Now you can pull the image in your builds.

The password for SYS/SYSTEM accounts is "oracle"
PDB datafiles are stored at "/opt/oracle/oradata/pdbs" which is published as a volume you can define on docker start.


The **small** image folders contain a bare-minimum oracle database instance needed to run utPLSQL. Those databases are not fully functional and some features of ORacle database may simply not work properly.

Do not use any of those images for your production environments!

In case of any issues you have two choices:
 - switch to regular image
 - change the image build configuration yourself
 
The image scrips are provided as they are, no support or reliability is offered. Use at your own risk.

For small images you have an option to choose between PDB (Multi-tenant database) or non-PDB - (Single-tenant) database.

Edit the `Dockerfile` before build and set the flag: `CREATE_PDB="false"` or `CREATE_PDB="true"`

# Useful commands cheat-sheet

### Building images

```bash
docker build --no-cache --force-rm --squash -t utplsqlv3/oracledb:12c-r1-se2       -f Dockerfile          ./12.1.0.2       > dockerBuild.log
docker build --no-cache --force-rm --squash -t utplsqlv3/oracledb:12c-r2-se2       -f Dockerfile          ./12.2.0.1       > dockerBuild.log
docker build --no-cache --force-rm --squash -t utplsqlv3/oracledb:18c-se2          -f Dockerfile          ./18.3           > dockerBuild.log
docker build --no-cache --force-rm --squash -t utplsqlv3/oracledb:12c-r1-se2-small -f Dockerfile_continue ./12.1.0.2-small > dockerBuild.log
docker build --no-cache --force-rm --squash -t utplsqlv3/oracledb:12c-r2-se2-small -f Dockerfile_continue ./12.2.0.1-small > dockerBuild.log
docker build --no-cache --force-rm --squash -t utplsqlv3/oracledb:18c-se2-small    -f Dockerfile_continue ./18.3-small     > dockerBuild.log
docker build --no-cache --force-rm --squash -t utplsqlv3/oracledb:19c-se2-small    -f Dockerfile_continue ./19.3-small     > dockerBuild.log
```

### Pushing images to hub
```bash
docker login
docker push utplsqlv3/oracledb:12c-r1-se2
docker push utplsqlv3/oracledb:12c-r2-se2
docker push utplsqlv3/oracledb:18c-se2
docker push utplsqlv3/oracledb:12c-r1-se2-small
docker push utplsqlv3/oracledb:12c-r2-se2-small
docker push utplsqlv3/oracledb:18c-se2-small
docker push utplsqlv3/oracledb:19c-se2-small
```

### Pulling images from hub

This is optional as images would get pull on `docker run` if they are not available locally
```bash
docker login
docker pull utplsqlv3/oracledb:12c-r1-se2
docker pull utplsqlv3/oracledb:12c-r2-se2
docker pull utplsqlv3/oracledb:18c-se2
docker pull utplsqlv3/oracledb:12c-r1-se2-small
docker pull utplsqlv3/oracledb:12c-r2-se2-small
docker pull utplsqlv3/oracledb:18c-se2-small
docker pull utplsqlv3/oracledb:19c-se2-small
```

### Listing images
```bash
docker image ls --all      
```
    
### Removing a local image
```bash
docker image rm  utplsqlv3/oracledb:12c-r1-se2
```
    
### Running container from images

```bash
docker run -d --name 12c-r1-se2       -p 1531:1521 --expose=1521 utplsqlv3/oracledb:12c-r1-se2
docker run -d --name 12c-r2-se2       -p 1541:1521 --expose=1521 utplsqlv3/oracledb:12c-r2-se2
docker run -d --name 18c-se2          -p 1551:1521 --expose=1521 utplsqlv3/oracledb:18c-se2
docker run -d --name 12c-r1-se2-small -p 1531:1521 --expose=1521 utplsqlv3/oracledb:12c-r1-se2-small
docker run -d --name 12c-r2-se2-small -p 1541:1521 --expose=1521 utplsqlv3/oracledb:12c-r2-se2-small
docker run -d --name 18c-se2-small    -p 1551:1521 --expose=1521 utplsqlv3/oracledb:18c-se2-small
docker run -d --name 19c-se2-small    -p 1551:1521 --expose=1521 utplsqlv3/oracledb:19c-se2-small
```

### Stopping a running container

```bash
docker stop 12c-r1-se2      
docker stop 12c-r2-se2      
docker stop 18c-se2         
docker stop 12c-r1-se2-small
docker stop 12c-r2-se2-small
docker stop 18c-se2-small
docker stop 19c-se2-small
```

### (Re)starting previously stopped container

```bash
docker start 12c-r1-se2      
docker start 12c-r2-se2      
docker start 18c-se2         
docker start 12c-r1-se2-small
docker start 12c-r2-se2-small
docker start 18c-se2-small
docker start 19c-se2-small
```

### Removing container (keeps the image)

```bash
docker rm 12c-r1-se2      
docker rm 12c-r2-se2      
docker rm 18c-se2         
docker rm 12c-r1-se2-small
docker rm 12c-r2-se2-small
docker rm 18c-se2-small
docker rm 19c-se2-small
```