#!/usr/bin/env bash
# Disposable mise-bootstrap POC harness. Tests the REAL dotfiles mise config
# (rendered by chezmoi inside the container) on a throwaway Linux box.
#
# Distro selected via DISTRO env (debian|arch), default debian:
#   DISTRO=arch ./run.sh up
#
#   ./run.sh build    -> (re)build the base image for $DISTRO
#   ./run.sh up       -> fresh container, render config + run `mise bootstrap`
#   ./run.sh shell    -> exec a shell in the running container
#   ./run.sh boot     -> re-run `mise bootstrap` (idempotency check)
#   ./run.sh render   -> show the rendered ~/.config/mise/config.toml
#   ./run.sh reset    -> docker rm -f the container
#   ./run.sh clean    -> reset + remove the image
# Default (no arg) = build + up.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISTRO="${DISTRO:-debian}"
case "$DISTRO" in
  debian) DOCKERFILE="$DIR/Dockerfile" ;;
  arch)   DOCKERFILE="$DIR/Dockerfile.arch" ;;
  *) echo "unknown DISTRO: $DISTRO (use debian|arch)" >&2; exit 1 ;;
esac
IMG="mise-poc-$DISTRO"
NAME="mise-poc-$DISTRO"
USER_NAME=riku
REPO="${DOTFILES_REPO:-$HOME/projects/dotfiles}"
TMPL="dot_config/mise/config.toml.tmpl"
CFG_DST="/home/${USER_NAME}/.config/mise/config.toml"

build() { docker build -f "$DOCKERFILE" -t "$IMG" "$DIR"; }

render_and_boot() {
  docker exec "$NAME" bash -lc "
    set -e
    mkdir -p ~/.config/mise
    chezmoi execute-template < /repo/${TMPL} > ${CFG_DST}
    echo '>> rendered config:'; sed -n '1,40p' ${CFG_DST}
    echo '>> trust + bootstrap'
    mise trust -y ${CFG_DST}
    mise bootstrap --yes
  "
}

up() {
  [ -f "$REPO/$TMPL" ] || { echo "dotfiles repo not found at $REPO ($TMPL)"; exit 1; }
  docker rm -f "$NAME" >/dev/null 2>&1 || true
  docker run -d --name "$NAME" -v "$REPO:/repo:ro" "$IMG" sleep infinity >/dev/null
  render_and_boot
}

shell()  { docker exec -it "$NAME" bash -l; }
boot()   { docker exec "$NAME" bash -lc "mise bootstrap --yes"; }
render() { docker exec "$NAME" bash -lc "chezmoi execute-template < /repo/${TMPL}"; }
reset()  { docker rm -f "$NAME" >/dev/null 2>&1 || true; echo "removed $NAME"; }
clean()  { reset; docker rmi "$IMG" >/dev/null 2>&1 || true; echo "removed image $IMG"; }

case "${1:-default}" in
  build) build ;;
  up)    up ;;
  shell) shell ;;
  boot)  boot ;;
  render) render ;;
  reset) reset ;;
  clean) clean ;;
  default) build && up ;;
  *) echo "unknown: $1" >&2; exit 1 ;;
esac
