#!/bin/sh
set -e

image_tag=justudior

script_dir=$(readlink -f "$(dirname "$0")")

(
  cd "${script_dir}"

  docker build \
    --tag ${image_tag} \
    .

  mkdir -p workspace
  workdir=$(readlink -f workspace)

  docker run \
    --rm \
    -it \
    --hostname rcontainer \
    --volume "${workdir}":/home/tony/workspace \
    --publish 8787:8787 \
    --publish 8888:8888 \
    ${image_tag} \
    "$@"
)
