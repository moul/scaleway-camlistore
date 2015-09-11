DOCKER_NAMESPACE =      armbuild/
NAME =                  scw-app-camlistore
VERSION =               latest
VERSION_ALIASES =       tip
TITLE =                 Camlistore
DESCRIPTION =           Camlistore with MySQL
SOURCE_URL =            https://github.com/mpl/camli-scaleway

IMAGE_VOLUME_SIZE =     50G
IMAGE_BOOTSCRIPT =      stable
IMAGE_NAME =            Camlistore tip

## Image tools  (https://github.com/scaleway/image-tools)
all:    docker-rules.mk
docker-rules.mk:
        wget -qO - http://j.mp/scw-builder | bash
-include docker-rules.mk
