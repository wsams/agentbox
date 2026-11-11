#!/usr/bin/env bash
# Build agentbox images from build.conf / flavors/*.conf and feature toggles.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${ROOT}"

ALL_FEATURES=(
  network databases aws gcp azure terraform pulumi
  ansible secrets gitops supplychain local-k8s mesh rclone golang
  security k8s k8s-extras container-tools argocd rust
)

IMAGE=""
PLATFORM=""
WITHOUT=""
WITH=""
CONFIG_FILE="${ROOT}/build.conf"
USE_CONFIG=1
FLAVOR=""
VARIANT=""
NO_SKILL_UPDATE=0
PUSH=0
LIST_FEATURES=0
DRY_RUN=0
EXTRA_BUILD_ARGS=()

usage() {
  cat <<'EOF'
Usage: build.sh [options]

  --flavor NAME       Load flavors/NAME.conf (core|k8s|terraform|pulumi|full)
  --config FILE       Config file (default: build.conf)
  --no-config         Ignore config; all feature groups on
  --without GROUPS    Comma-separated groups to disable (or 'all')
  --with GROUPS       Comma-separated groups to enable (after --without)
  --variant SUFFIX    Tag as IMAGE-SUFFIX (when IMAGE has no custom tag dance)
  --platform PLAT     docker build --platform
  --image NAME        Override IMAGE
  --list-features     Print feature groups and exit
  --no-skill-update   Do not fetch skills; use existing clones
  --push              docker push after build
  --dry-run           Print the docker build command only
  -h, --help          Show help

Feature groups default ON. WITHOUT/WITH in the config file set the baseline;
CLI flags apply on top for that one build.
EOF
}

die() { echo "error: $*" >&2; exit 1; }

parse_conf() {
  local file="$1"
  [[ -f "${file}" ]] || die "config not found: ${file}"
  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%%#*}"
    line="$(echo "${line}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "${line}" ]] && continue
    local key="${line%%=*}"
    local val="${line#*=}"
    key="$(echo "${key}" | sed 's/[[:space:]]*$//')"
    val="$(echo "${val}" | sed 's/^[[:space:]]*//')"
    case "${key}" in
      IMAGE) IMAGE="${val}" ;;
      PLATFORM) PLATFORM="${val}" ;;
      WITHOUT) WITHOUT="${val}" ;;
      WITH) WITH="${val}" ;;
      *) ;;
    esac
  done < "${file}"
}

feature_to_arg() {
  local f="$1"
  echo "WITH_$(echo "${f}" | tr '[:lower:]-' '[:upper:]_')"
}

# Resolve enabled set from WITHOUT/WITH strings
declare -A ENABLED=()

reset_features_on() {
  local f
  for f in "${ALL_FEATURES[@]}"; do
    ENABLED["${f}"]=1
  done
}

apply_without() {
  local raw="$1"
  [[ -z "${raw}" ]] && return 0
  local part
  IFS=',' read -ra parts <<<"${raw}"
  for part in "${parts[@]}"; do
    part="$(echo "${part}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "${part}" ]] && continue
    if [[ "${part}" == "all" ]]; then
      local f
      for f in "${ALL_FEATURES[@]}"; do ENABLED["${f}"]=0; done
      continue
    fi
    [[ -n "${ENABLED[${part}]+x}" ]] || die "unknown feature: ${part}"
    ENABLED["${part}"]=0
  done
}

apply_with() {
  local raw="$1"
  [[ -z "${raw}" ]] && return 0
  local part
  IFS=',' read -ra parts <<<"${raw}"
  for part in "${parts[@]}"; do
    part="$(echo "${part}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "${part}" ]] && continue
    [[ -n "${ENABLED[${part}]+x}" ]] || die "unknown feature: ${part}"
    ENABLED["${part}"]=1
  done
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --flavor) FLAVOR="$2"; shift 2 ;;
    --config) CONFIG_FILE="$2"; shift 2 ;;
    --no-config) USE_CONFIG=0; shift ;;
    --without) WITHOUT_CLI="${WITHOUT_CLI:-}$2,"; shift 2 ;;
    --with) WITH_CLI="${WITH_CLI:-}$2,"; shift 2 ;;
    --variant) VARIANT="$2"; shift 2 ;;
    --platform) PLATFORM="$2"; shift 2 ;;
    --image) IMAGE="$2"; shift 2 ;;
    --list-features) LIST_FEATURES=1; shift ;;
    --no-skill-update) NO_SKILL_UPDATE=1; shift ;;
    --push) PUSH=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option: $1" ;;
  esac
done

if [[ "${LIST_FEATURES}" -eq 1 ]]; then
  printf '%s\n' "${ALL_FEATURES[@]}"
  exit 0
fi

reset_features_on
if [[ -n "${FLAVOR}" ]]; then
  CONFIG_FILE="${ROOT}/flavors/${FLAVOR}.conf"
  USE_CONFIG=1
fi
if [[ "${USE_CONFIG}" -eq 1 ]]; then
  parse_conf "${CONFIG_FILE}"
fi
apply_without "${WITHOUT}"
apply_with "${WITH}"
apply_without "${WITHOUT_CLI:-}"
apply_with "${WITH_CLI:-}"

[[ -n "${IMAGE}" ]] || IMAGE="wsams/agentbox:dev"
if [[ -n "${VARIANT}" ]]; then
  if [[ "${IMAGE}" == *:* ]]; then
    IMAGE="${IMAGE}-${VARIANT}"
  else
    IMAGE="${IMAGE}:${VARIANT}"
  fi
fi

# --- Skills staging ---
stage_skills() {
  local repos="${ROOT}/skills/repos"
  local build="${ROOT}/skills/build"
  local conf="${ROOT}/skills.conf"
  mkdir -p "${repos}" "${build}"
  # Clear previous build output but keep .gitkeep semantics
  find "${build}" -mindepth 1 ! -name '.gitkeep' -exec rm -rf {} + 2>/dev/null || true
  : >"${build}/.sources"

  [[ -f "${conf}" ]] || return 0

  # Local skills/ folders (except repos/ and build/)
  if [[ -d "${ROOT}/skills" ]]; then
    local dir
    for dir in "${ROOT}/skills"/*; do
      [[ -d "${dir}" ]] || continue
      local base
      base="$(basename "${dir}")"
      [[ "${base}" == "repos" || "${base}" == "build" ]] && continue
      if [[ -f "${dir}/SKILL.md" ]]; then
        local name
        name="$(awk '/^name:/{print $2; exit}' "${dir}/SKILL.md" | tr -d '\r')"
        [[ -n "${name}" ]] || name="${base}"
        rm -rf "${build}/${name}"
        mkdir -p "${build}/${name}"
        cp -a "${dir}/." "${build}/${name}/"
        rm -rf "${build}/${name}/.git"
        echo "${name}@local  local:skills/${base}" >>"${build}/.sources"
      fi
    done
  fi

  while IFS= read -r line || [[ -n "${line}" ]]; do
    line="${line%%#*}"
    line="$(echo "${line}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "${line}" ]] && continue
    local url ref=""
    read -r url ref <<<"${line}"
    local slug
    slug="$(echo "${url}" | sed 's#[.]git$##;s#.*/##')"
    local dest="${repos}/${slug}"
    if [[ -d "${dest}/.git" ]]; then
      if [[ "${NO_SKILL_UPDATE}" -eq 0 ]]; then
        if [[ -n "$(git -C "${dest}" status --porcelain 2>/dev/null || true)" ]]; then
          die "skill clone has local changes: ${dest}"
        fi
        GIT_SSH_COMMAND="ssh -o BatchMode=yes" git -C "${dest}" fetch --all --tags --prune || \
          echo "warning: fetch failed for ${url}; using existing clone" >&2
        if [[ -n "${ref}" ]]; then
          git -C "${dest}" checkout --force "${ref}"
        else
          local branch
          branch="$(git -C "${dest}" remote show origin | awk '/HEAD branch/{print $NF}')"
          git -C "${dest}" checkout --force "${branch:-main}"
          git -C "${dest}" reset --hard "origin/${branch:-main}" 2>/dev/null || true
        fi
      fi
    else
      if [[ "${NO_SKILL_UPDATE}" -eq 1 ]]; then
        die "no clone for ${url} and --no-skill-update set"
      fi
      mkdir -p "${repos}"
      if [[ -n "${ref}" ]]; then
        GIT_SSH_COMMAND="ssh -o BatchMode=yes" git clone --depth 1 --branch "${ref}" "${url}" "${dest}" \
          || GIT_SSH_COMMAND="ssh -o BatchMode=yes" git clone "${url}" "${dest}"
        git -C "${dest}" checkout --force "${ref}"
      else
        GIT_SSH_COMMAND="ssh -o BatchMode=yes" git clone --depth 1 "${url}" "${dest}"
      fi
    fi
    local commit
    commit="$(git -C "${dest}" rev-parse --short HEAD)"
    # Copy every directory that contains SKILL.md
    while IFS= read -r -d '' skillmd; do
      local skilldir
      skilldir="$(dirname "${skillmd}")"
      local name
      name="$(awk '/^name:/{print $2; exit}' "${skillmd}" | tr -d '\r')"
      [[ -n "${name}" ]] || name="$(basename "${skilldir}")"
      if [[ -e "${build}/${name}" ]]; then
        die "duplicate skill name: ${name}"
      fi
      mkdir -p "${build}/${name}"
      cp -a "${skilldir}/." "${build}/${name}/"
      rm -rf "${build}/${name}/.git"
      echo "${name}@${commit}  ${url}" >>"${build}/.sources"
    done < <(find "${dest}" -type f -name SKILL.md -print0)
  done < "${conf}"
}

stage_skills

CREATED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REVISION="$(git -C "${ROOT}" rev-parse --short HEAD 2>/dev/null || echo unknown)"
if [[ -n "$(git -C "${ROOT}" status --porcelain 2>/dev/null || true)" ]]; then
  REVISION="${REVISION}-dirty"
fi

BUILD_ARGS=()
for f in "${ALL_FEATURES[@]}"; do
  arg="$(feature_to_arg "${f}")"
  BUILD_ARGS+=(--build-arg "${arg}=${ENABLED[${f}]}")
done
CMD=(docker build -t "${IMAGE}"
  --label "org.opencontainers.image.created=${CREATED}"
  --label "org.opencontainers.image.revision=${REVISION}"
  --label "agentbox.config=$(basename "${CONFIG_FILE}")"
  "${BUILD_ARGS[@]}"
)
if [[ -n "${PLATFORM}" ]]; then
  CMD+=(--platform "${PLATFORM}")
fi
CMD+=("${EXTRA_BUILD_ARGS[@]}" "${ROOT}")

echo "▶ Image     : ${IMAGE}"
echo "▶ Config    : ${CONFIG_FILE}"
echo "▶ Created   : ${CREATED}"
echo "▶ Revision  : ${REVISION}"
echo -n "▶ Features  : "
for f in "${ALL_FEATURES[@]}"; do
  if [[ "${ENABLED[${f}]}" -eq 1 ]]; then
    echo -n "${f} "
  fi
done
echo
if [[ -f "${ROOT}/skills/build/.sources" ]]; then
  echo "▶ Skills    : $(tr '\n' ' ' < "${ROOT}/skills/build/.sources")"
fi

if [[ "${DRY_RUN}" -eq 1 ]]; then
  printf '%q ' "${CMD[@]}"
  echo
  exit 0
fi

"${CMD[@]}"

if [[ "${PUSH}" -eq 1 ]]; then
  docker push "${IMAGE}"
fi

echo "Built ${IMAGE}"
