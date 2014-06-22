We do this part on the server we're migrating from
--------------------------------------------------

Stop the container:
```
# docker stop CONTAINER_NAME_OR_ID
```

Commit it to an image:
```
# docker commit CONTAINER_NAME_OR_ID REPOSITORY_NAME:TAG_NAME
```

Save it: 
```
# docker save REPOSITORY_NAME:TAG_NAME > REPOSITORY_NAME:TAG_NAME.tar
```

Send it to the new server:
```
# scp ./REPOSITORY_NAME\:TAG_NAME.tar root@IPADDRESS_OR_HOSTNAME:/root
```

Now, go over to your other server and to the next steps
--------------------------------------------------------
Load it back into docker:
```
# docker load < REPOSITORY_NAME\:TAG_NAME.tar
```

Check out your images and compare sizes with the tar's to confirm the IMAGE ID:
```
# docker images
```

Run it as you normally would now. For me I normally do this:
```
# docker run --name DESCRIPTIVE_NAME -dit DOCKER_IMAGE_ID /opt/docker.init
```

Now we'll commit our changes:
```
# docker commit DESCRIPTIVE_NAME DOCKER_IMAGE_ID
```

You can get the old image name back by simply replacing DOCKER_IMAGE_ID with REPOSITORY_NAME:TAG_NAME, just don't forget to clean up images:
```
# docker images
# docker rmi DOCKER_IMAGE_ID
```
