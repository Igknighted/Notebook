To list running containers:
```
# docker ps
```

To list all containers both running and exited:
```
# docker ps -a
```

To remove a non running container found from the previous command:
```
# docker rm CONTAINER_ID
```

To attach to a running container:
```
# docker attach CONTAINER_NAME_OR_ID
```
* Escape sequence is needed to get out of that container press ^p and then ^q and you will drop back to shell. Run reset to fix any issues you may have.
