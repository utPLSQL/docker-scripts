# docker-scripts
The docker scripts are based on the Oracle docker-images repository but midified so that resulting image is small enough to be used with Travis CI.

To build an image go to the folder of desired DB version and execute
```
docker build --no-cache --force-rm --squash -t ut-img12c-r2-se2 -f .\Dockerfile.se2 .
```
ut-img12c-r2-se2 - is the image name. 
Don't forget the dot(!) at the end ofthe command.

When the image is ready all you need is to publish it to your _private_ repository:
```
docker tag ut-img12c-r2-se2 utplsqlv3/oracledb:12c-r2-se2
docker login
docker push utplsqlv3/oracledb:12c-r2-se2
```

Now you can pull the image in your builds.

The password for SYS/SYSTEM accounts is "oracle"