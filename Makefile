NAME =			camlistore
VERSION =		latest
VERSION_ALIASES =	def28fc337ff85105b8b7dc6f0cda64af62b1615
TITLE =			Camlistore
DESCRIPTION =		Camlistore with MySQL, pre-0.9
SOURCE_URL =		https://github.com/scaleway-community/scaleway-camlistore
VENDOR_URL =		https://camlistore.org

IMAGE_VOLUME_SIZE =	50G
IMAGE_BOOTSCRIPT =	stable
IMAGE_NAME =		Camlistore (pre-0.9) with MySQL


## Image tools  (https://github.com/scaleway/image-tools)
all:	docker-rules.mk
docker-rules.mk:
	wget -qO - http://j.mp/scw-builder | bash
-include docker-rules.mk
