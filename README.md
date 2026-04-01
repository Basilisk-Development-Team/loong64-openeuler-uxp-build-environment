# loongarch64-openeuler-docker-uxp

Container image for building UXP on `loongarch64` with openEuler 24.03 LTS SP3.

Docker Hub: https://hub.docker.com/r/basiliskdev/loong64-openeuler-uxp-build-environment

## Contents

The image installs:

- openEuler 24.03 LTS SP3 as the base
- LLVM toolchain 19
- Common UXP build dependencies
- Python 2.7.18 via `pyenv` (will be removed once UXP build system is fully Python 3 compatible)

This image is intended for `loongarch64`. It will not work correctly on `x86_64` or `aarch64`.

## Build locally

```
docker build -t loongarch64-openeuler-docker-uxp .
```

## Run locally

`cd` into application directory. Example `cd /home/user/dev/uxp/basilisk`

```
docker run --rm -it \
-u "$(id -u):$(id -g)" \
-v "$(pwd):/src" \
-w /src basilisk-loongarch \
bash --login
```

Make sure you have a mozconfig file then run
`./mach build`

## Publish to Docker Hub

GitHub Actions workflow: [`.github/workflows/publish-dockerhub.yml`](.github/workflows/publish-dockerhub.yml)

The workflow builds the image for `linux/loong64` and pushes to Docker Hub on git pushes to `master`

Set these GitHub repository settings:

- Secret: `DOCKERHUB_TOKEN`
- Variable: `DOCKERHUB_USERNAME` (defaults to `basiliskdev`)
- Variable: `DOCKERHUB_IMAGE` (optional, defaults to the repository name)

Published tags:

- `latest` on the default branch
- `sha-<commit>` for pushed commits
