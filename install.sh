#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$REPO_DIR/skills"
TARGET_DIR="${HOME}/.codex/skills"
REGISTRY_FILE="$REPO_DIR/registry.yaml"

mkdir -p "$TARGET_DIR"

usage() {
  cat <<'EOF'
Usage:
  ./install.sh list [--status STATUS]
  ./install.sh info <skill>
  ./install.sh validate
  ./install.sh install [--all] [--status STATUS] [skill...]
  ./install.sh help

Examples:
  ./install.sh list
  ./install.sh list --status draft
  ./install.sh info paper-revision
  ./install.sh validate
  ./install.sh install paper-revision
  ./install.sh install --status stable
  ./install.sh install --all

Notes:
  - Running with no arguments defaults to: ./install.sh install --all
  - Install overwrites the target skill directory in ~/.codex/skills
EOF
}

skill_exists() {
  local skill_name="$1"
  [[ -n "$(registry_get_field "$skill_name" "path")" ]]
}

registry_has_skill() {
  local skill_name="$1"
  awk -v target="$skill_name" '
    $1 == "-" && $2 == "id:" && $3 == target { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$REGISTRY_FILE"
}

registry_print_block() {
  local skill_name="$1"
  awk -v target="$skill_name" '
    $1 == "-" && $2 == "id:" {
      if (in_block) exit
      in_block = ($3 == target)
    }
    in_block { print }
  ' "$REGISTRY_FILE"
}

registry_get_field() {
  local skill_name="$1"
  local field_name="$2"
  awk -v target="$skill_name" -v field="$field_name" '
    $1 == "-" && $2 == "id:" {
      if (in_block) exit
      in_block = ($3 == target)
    }
    in_block && $1 == field ":" {
      sub("^[^:]+:[[:space:]]*", "", $0)
      print $0
      exit
    }
  ' "$REGISTRY_FILE"
}

registry_ids() {
  awk '
    $1 == "-" && $2 == "id:" { print $3 }
  ' "$REGISTRY_FILE"
}

registry_ids_by_status() {
  local wanted_status="$1"
  awk -v wanted="$wanted_status" '
    $1 == "-" && $2 == "id:" { current = $3 }
    $1 == "status:" && current != "" {
      if ($2 == wanted) print current
      current = ""
    }
  ' "$REGISTRY_FILE"
}

install_one() {
  local skill_name="$1"
  local registry_path
  local source_path
  local target_path="$TARGET_DIR/$skill_name"

  registry_path="$(registry_get_field "$skill_name" "path")"

  if [[ -z "$registry_path" ]]; then
    echo "Skill not found in registry: $skill_name" >&2
    exit 1
  fi

  source_path="$REPO_DIR/$registry_path"

  if [[ ! -d "$source_path" ]]; then
    echo "Skill path not found: $skill_name -> $registry_path" >&2
    exit 1
  fi

  rm -rf "$target_path"
  cp -r "$source_path" "$target_path"
  echo "Installed $skill_name -> $target_path"
}

list_skills() {
  local status_filter="${1:-}"
  local skill_name
  local title
  local status
  local summary

  for skill_name in $(registry_ids); do
    if [[ -n "$status_filter" ]]; then
      status="$(registry_get_field "$skill_name" "status")"
      [[ "$status" == "$status_filter" ]] || continue
    else
      status="$(registry_get_field "$skill_name" "status")"
    fi

    title="$(registry_get_field "$skill_name" "title")"
    summary="$(registry_get_field "$skill_name" "summary")"
    printf '%s [%s] - %s\n' "$skill_name" "$status" "$title"
    printf '  %s\n' "$summary"
  done
}

show_info() {
  local skill_name="$1"

  if ! registry_has_skill "$skill_name"; then
    echo "Skill not found in registry: $skill_name" >&2
    exit 1
  fi

  registry_print_block "$skill_name"
}

validate_skills() {
  local failed=0
  local skill_name
  local path

  while IFS= read -r skill_name; do
    path="$(registry_get_field "$skill_name" "path")"

    if [[ -z "$path" ]]; then
      echo "Missing path field in registry for: $skill_name" >&2
      failed=1
      continue
    fi

    if [[ ! -d "$REPO_DIR/$path" ]]; then
      echo "Registry path does not exist: $skill_name -> $path" >&2
      failed=1
      continue
    fi

    if [[ ! -f "$REPO_DIR/$path/SKILL.md" ]]; then
      echo "Missing SKILL.md: $path" >&2
      failed=1
    fi
  done < <(registry_ids)

  if [[ "$failed" -ne 0 ]]; then
    exit 1
  fi

  echo "Validation passed."
}

install_all_registered() {
  local skill_name
  while IFS= read -r skill_name; do
    [[ -n "$skill_name" ]] || continue
    install_one "$skill_name"
  done < <(registry_ids)
}

install_by_status() {
  local wanted_status="$1"
  local skill_name
  local found=0

  while IFS= read -r skill_name; do
    [[ -n "$skill_name" ]] || continue
    found=1
    install_one "$skill_name"
  done < <(registry_ids_by_status "$wanted_status")

  if [[ "$found" -eq 0 ]]; then
    echo "No skills found with status: $wanted_status" >&2
    exit 1
  fi
}

main() {
  local command="${1:-install}"

  if [[ $# -eq 0 ]]; then
    install_all_registered
    exit 0
  fi

  case "$command" in
    help|-h|--help)
      usage
      ;;
    list)
      shift
      if [[ "${1:-}" == "--status" ]]; then
        [[ $# -ge 2 ]] || { echo "Missing status value." >&2; exit 1; }
        list_skills "$2"
      else
        list_skills
      fi
      ;;
    info)
      shift
      [[ $# -ge 1 ]] || { echo "Missing skill name." >&2; exit 1; }
      show_info "$1"
      ;;
    validate)
      validate_skills
      ;;
    install)
      shift
      if [[ $# -eq 0 ]]; then
        install_all_registered
        exit 0
      fi

      if [[ "${1:-}" == "--all" ]]; then
        install_all_registered
        exit 0
      fi

      if [[ "${1:-}" == "--status" ]]; then
        [[ $# -ge 2 ]] || { echo "Missing status value." >&2; exit 1; }
        install_by_status "$2"
        exit 0
      fi

      for skill_name in "$@"; do
        install_one "$skill_name"
      done
      ;;
    *)
      echo "Unknown command: $command" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
