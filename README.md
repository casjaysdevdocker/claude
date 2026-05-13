## 👋 Welcome to claude 🚀  

claude README  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update claude
```
  
## Install and run container
  
```shell
dockerHome="/var/lib/srv/$USER/docker/casjaysdevdocker/claude/claude/latest/rootfs"
mkdir -p "/var/lib/srv/$USER/docker/claude/rootfs"
git clone "https://github.com/dockermgr/claude" "$HOME/.local/share/CasjaysDev/dockermgr/claude"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/claude/rootfs/." "$dockerHome/"
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-claude-latest \
--hostname claude \
-e TZ=${TIMEZONE:-America/New_York} \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 80:80 \
casjaysdevdocker/claude:latest
```
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ProjectName:
    image: casjaysdevdocker/claude
    container_name: casjaysdevdocker-claude
    environment:
      - TZ=America/New_York
      - HOSTNAME=claude
    volumes:
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/claude/claude/latest/rootfs/data:/data:z"
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/claude/claude/latest/rootfs/config:/config:z"
    ports:
      - 80:80
    restart: always
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/claude
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/claude" "$HOME/Projects/github/casjaysdevdocker/claude"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/claude"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
