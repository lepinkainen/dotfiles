#!/usr/bin/env bash
# shellcheck shell=bash

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "ollama_image_client.sh is a helper meant to be sourced, not executed directly." >&2
  exit 1
fi

if [[ -n "${OLLAMA_IMAGE_CLIENT_LOADED:-}" ]]; then
  return 0
fi

OLLAMA_IMAGE_CLIENT_LOADED=1

ollama_image_client_require_tools() {
  if [[ -n "${OLLAMA_IMAGE_CLIENT_DEPS_READY:-}" ]]; then
    return 0
  fi

  local tool
  for tool in curl jq base64 mktemp; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "Missing required dependency: $tool" >&2
      return 1
    fi
  done

  OLLAMA_IMAGE_CLIENT_DEPS_READY=1
}

ollama_image_client_api_url() {
  local api_url host base
  if [[ -n "${OLLAMA_API_URL:-}" ]]; then
    api_url="${OLLAMA_API_URL%/}"
  else
    host="${OLLAMA_HOST:-127.0.0.1:11434}"
    if [[ "$host" == http://* || "$host" == https://* ]]; then
      base="${host%/}"
    else
      base="http://${host}"
    fi
    api_url="${base}/api/generate"
  fi

  printf '%s' "$api_url"
}

ollama_image_prompt() {
  local model="$1"
  local image_path="$2"
  local prompt="$3"

  if [[ -z "$model" || -z "$image_path" || -z "$prompt" ]]; then
    echo "ollama_image_prompt requires model, image path, and prompt" >&2
    return 1
  fi

  if [[ ! -f "$image_path" ]]; then
    echo "Image not found: $image_path" >&2
    return 1
  fi

  if ! ollama_image_client_require_tools; then
    return 1
  fi

  local tmp_b64
  tmp_b64=$(mktemp) || {
    echo "Failed to allocate temp file" >&2
    return 1
  }

  if ! base64 <"$image_path" | tr -d '\n' >"$tmp_b64"; then
    echo "Failed to base64 encode image: $image_path" >&2
    rm -f "$tmp_b64"
    return 1
  fi

  local api_url
  api_url=$(ollama_image_client_api_url) || {
    rm -f "$tmp_b64"
    return 1
  }

  local response
  if ! response=$(
    jq -n \
      --arg model "$model" \
      --arg prompt "$prompt" \
      --rawfile image "$tmp_b64" \
      '{model: $model, prompt: $prompt, stream: false, images: [$image]}' |
      curl -sS -f -X POST "$api_url" -H "Content-Type: application/json" --data-binary @-
  ); then
    echo "Request to Ollama API failed. Ensure the server is reachable at $api_url." >&2
    rm -f "$tmp_b64"
    return 1
  fi

  rm -f "$tmp_b64"

  local extracted
  if ! extracted=$(printf '%s' "$response" | jq -er '.response'); then
    echo "Unexpected response from Ollama API (missing 'response' field)." >&2
    printf '%s\n' "$response" >&2
    return 1
  fi

  printf '%s' "$extracted"
}
