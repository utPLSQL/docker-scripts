# docker-scripts
The docker scripts are based on the [Oracle docker-images](https://github.com/oracle/docker-images/) repository but modified so that resulting image is small enough to be used with Travis CI.

To use the scripts you need to download the archive of the desired DB vesion from the Oracle website.

To build an image go to the folder of desired DB version and execute
```
docker build --no-cache --force-rm --squash -t ut-img12c-r2-se2 -f .\Dockerfile.se2 .
```
ut-img12c-r2-se2 - is the image name. 
Don't forget the dot(!) at the end of the command.

When the image is ready all you need is to publish it to your _private_ repository:
```
docker tag ut-img12c-r2-se2 utplsqlv3/oracledb:12c-r2-se2
docker login
docker push utplsqlv3/oracledb:12c-r2-se2
```

Now you can pull the image in your builds.

The password for SYS/SYSTEM accounts is "oracle"
PDB datafiles are stored at "/opt/oracle/oradata/pdbs" which is published as a volume you can define on docker start.
