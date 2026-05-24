#!/usr/bin/env bash
set -euo pipefail

TARGET_REPO="${TARGET_REPO:-${GITHUB_REPOSITORY:-KUAILESHANGWEI/FlClash}}"
TARGET_BRANCH="${TARGET_BRANCH:-main}"

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing required tool: $1" >&2
    exit 1
  fi
}

release_json() {
  local repo="$1"
  local selector="$2"

  if [[ "$selector" == "__latest__" ]]; then
    gh release view -R "$repo" --json tagName,name,body,isPrerelease
  else
    gh release view "$selector" -R "$repo" --json tagName,name,body,isPrerelease
  fi
}

ensure_release() {
  local target_tag="$1"
  local title="$2"
  local notes_file="$3"

  if gh release view "$target_tag" -R "$TARGET_REPO" >/dev/null 2>&1; then
    gh release edit "$target_tag" -R "$TARGET_REPO" --title "$title" --notes-file "$notes_file"
  else
    gh release create "$target_tag" -R "$TARGET_REPO" --target "$TARGET_BRANCH" --title "$title" --notes-file "$notes_file"
  fi
}

sync_github_release() {
  local source_repo="$1"
  local source_selector="$2"
  local target_tag="$3"
  local title_prefix="${4:-Mirrored release}"
  shift 4 || true
  local patterns=("$@")

  local metadata
  metadata="$(release_json "$source_repo" "$source_selector")"

  local source_tag
  local source_name
  source_tag="$(jq -r '.tagName' <<<"$metadata")"
  source_name="$(jq -r '.name // .tagName' <<<"$metadata")"

  if [[ "$target_tag" == "__same__" ]]; then
    target_tag="$source_tag"
  fi

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  local notes_file="$tmp_dir/release-notes.md"
  {
    echo "Mirrored from ${source_repo}@${source_tag}."
    echo
    jq -r '.body // ""' <<<"$metadata"
  } >"$notes_file"

  echo "Syncing ${source_repo}@${source_tag} -> ${TARGET_REPO}@${target_tag}"
  ensure_release "$target_tag" "${title_prefix}: ${source_name}" "$notes_file"

  local assets_dir="$tmp_dir/assets"
  mkdir -p "$assets_dir"
  if (( ${#patterns[@]} == 0 )); then
    gh release download "$source_tag" -R "$source_repo" --dir "$assets_dir" --clobber
  else
    local pattern
    for pattern in "${patterns[@]}"; do
      if ! gh release download "$source_tag" -R "$source_repo" --pattern "$pattern" --dir "$assets_dir" --clobber; then
        echo "No assets matched optional pattern '${pattern}' for ${source_repo}@${source_tag}"
      fi
    done
  fi

  shopt -s nullglob
  local assets=("$assets_dir"/*)
  if (( ${#assets[@]} == 0 )); then
    echo "No assets found for ${source_repo}@${source_tag}"
    return
  fi

  local asset
  for asset in "${assets[@]}"; do
    gh release delete-asset "$target_tag" "$(basename "$asset")" -R "$TARGET_REPO" -y >/dev/null 2>&1 || true
  done

  gh release upload "$target_tag" -R "$TARGET_REPO" "${assets[@]}" --clobber
  rm -rf "$tmp_dir"
}

sync_url_asset() {
  local target_tag="$1"
  local title="$2"
  local url="$3"
  local asset_name="$4"

  local tmp_dir
  tmp_dir="$(mktemp -d)"

  local notes_file="$tmp_dir/release-notes.md"
  printf 'Mirrored from %s.\n' "$url" >"$notes_file"

  echo "Syncing ${url} -> ${TARGET_REPO}@${target_tag}/${asset_name}"
  ensure_release "$target_tag" "$title" "$notes_file"

  curl -fL "$url" -o "$tmp_dir/$asset_name"
  gh release delete-asset "$target_tag" "$asset_name" -R "$TARGET_REPO" -y >/dev/null 2>&1 || true
  gh release upload "$target_tag" -R "$TARGET_REPO" "$tmp_dir/$asset_name" --clobber
  rm -rf "$tmp_dir"
}

main() {
  require_tool gh
  require_tool jq
  require_tool curl

  # Upstream FlClash is the only retained upstream project source address.
  if [[ "${SYNC_UPSTREAM_FLCLASH:-1}" == "1" ]]; then
    sync_github_release "chen08209/FlClash" "__latest__" "__same__" "FlClash upstream mirror"
  fi

  if [[ "${SYNC_META_RULES_DAT:-1}" == "1" ]]; then
    sync_github_release "MetaCubeX/meta-rules-dat" "latest" "third-party-meta-rules-dat-latest" "Third-party mirror"
  fi
  if [[ "${SYNC_APPIMAGEKIT:-1}" == "1" ]]; then
    sync_github_release "AppImage/AppImageKit" "continuous" "third-party-appimagekit-continuous" "Third-party mirror"
  fi
  local mihomo_patterns=(
    "version.txt"
    "checksums.txt"
    "mihomo-android-amd64-*.gz"
    "mihomo-android-arm64-v8-*.gz"
    "mihomo-android-armv7-*.gz"
    "mihomo-darwin-amd64-v[123]-*.gz"
    "mihomo-darwin-arm64-*.gz"
    "mihomo-linux-amd64-v[123]-*.gz"
    "mihomo-linux-arm64-*.gz"
    "mihomo-windows-amd64-v[123]-*.zip"
  )
  if [[ "${SYNC_MIHOMO:-1}" == "1" ]]; then
    sync_github_release "MetaCubeX/mihomo" "__latest__" "third-party-mihomo-latest" "Third-party mirror" "${mihomo_patterns[@]}"
    sync_github_release "MetaCubeX/mihomo" "Prerelease-Alpha" "third-party-mihomo-prerelease-alpha" "Third-party mirror" "${mihomo_patterns[@]}"
  fi

  if [[ "${SYNC_GOOGLETEST:-1}" == "1" ]]; then
    sync_url_asset \
      "third-party-googletest-release-1.11.0" \
      "Third-party mirror: googletest release-1.11.0" \
      "https://github.com/google/googletest/archive/release-1.11.0.zip" \
      "googletest-release-1.11.0.zip"
  fi

  if [[ "${SYNC_METACUBEXD:-1}" == "1" ]]; then
    sync_url_asset \
      "third-party-metacubexd-gh-pages" \
      "Third-party mirror: metacubexd gh-pages" \
      "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip" \
      "metacubexd-gh-pages.zip"
  fi
}

main "$@"
