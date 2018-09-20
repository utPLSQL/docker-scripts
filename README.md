# docker-scripts
The docker scripts are based on the [Oracle docker-images](https://github.com/oracle/docker-images/) repository but modified so that resulting image is small enough to be used with Travis CI.

To use the scripts you need to download the archive of the desired DB vesion from the Oracle website.

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