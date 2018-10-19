<h1><a href="https://camlistore.org"><img src="http://camlistore.org/static/camli-header.jpg" width="300" alt="Camlistore"/></a> on Scaleway</h1>

## Install

[![GuardRails badge](https://badges.production.guardrails.io/moul/scaleway-camlistore.svg)](https://www.guardrails.io)

**This image is meant to be used on a scaleway C1 server.**

Install from the [scaleway imagehub](https://www.scaleway.com/imagehub/)

Once installed, run **camlistore-configure** for an initial setup.
For further configuration, see [camlistore server-config](https://camlistore.org/docs/server-config) and edit /home/camli/.config/camlistore/server-config.json

See the [documentation](https://www.scaleway.com/docs/create-and-connect-to-your-server/) to connect your to your C1 server.

---

## Development

This image is built using [Image Tools](https://github.com/scaleway/image-tools) and depends on the official [Ubuntu](https://github.com/scaleway/image-ubuntu) (vivid) image.

We use the Docker's building system and convert it at the end to a disk image that will boot on real servers without Docker. Note that the image is still runnable as a Docker container for debug or for inheritance.

---
