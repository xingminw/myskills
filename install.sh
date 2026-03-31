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
  ./install.sh list-installed
  ./install.sh info <skill>
  ./install.sh status
  ./install.sh validate
  ./install.sh install [--all] [--status STATUS] [skill...]
  ./install.sh uninstall [skill...]
  ./install.sh uninstall --all-managed
  ./install.sh help

Examples:
  ./install.sh list
  ./install.sh list --status draft
  ./install.sh list-installed
  ./install.sh info paper-revision
  ./install.sh status
  ./install.sh validate
  ./install.sh install paper-revision
  ./install.sh install --status stable
  ./install.sh install --all
  ./install.sh uninstall paper-revision
  ./install.sh uninstall --all-managed

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

installed_skill_ids() {
  local skill_dir
  for skill_dir in "$TARGET_DIR"/*; do
    [[ -d "$skill_dir" ]] || continue
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    basename "$skill_dir"
  done
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

list_installed_skills() {
  local installed_name
  local count=0

  for installed_name in $(installed_skill_ids); do
    count=1
    if registry_has_skill "$installed_name"; then
      printf '%s [managed]\n' "$installed_name"
    else
      printf '%s [unmanaged]\n' "$installed_name"
    fi
  done

  if [[ "$count" -eq 0 ]]; then
    echo "No installed skills found in $TARGET_DIR"
  fi
}

show_info() {
  local skill_name="$1"

  if ! registry_has_skill "$skill_name"; then
    echo "Skill not found in registry: $skill_name" >&2
    exit 1
  fi

  registry_print_block "$skill_name"
}

show_status() {
  local skill_name
  local installed=0

  while IFS= read -r skill_name; do
    [[ -n "$skill_name" ]] || continue
    if [[ -d "$TARGET_DIR/$skill_name" ]]; then
      printf '%s [installed]\n' "$skill_name"
      installed=1
    else
      printf '%s [not installed]\n' "$skill_name"
    fi
  done < <(registry_ids)

  if [[ "$installed" -eq 0 ]]; then
    :
  fi
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

uninstall_one() {
  local skill_name="$1"
  local target_path="$TARGET_DIR/$skill_name"

  if [[ ! -d "$target_path" ]]; then
    echo "Installed skill not found: $skill_name" >&2
    exit 1
  fi

  rm -rf "$target_path"
  echo "Removed $skill_name from $target_path"
}

uninstall_all_managed() {
  local skill_name
  local found=0

  while IFS= read -r skill_name; do
    [[ -n "$skill_name" ]] || continue
    if [[ -d "$TARGET_DIR/$skill_name" ]]; then
      uninstall_one "$skill_name"
      found=1
    fi
  done < <(registry_ids)

  if [[ "$found" -eq 0 ]]; then
    echo "No managed installed skills found in $TARGET_DIR"
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
    list-installed)
      list_installed_skills
      ;;
    info)
      shift
      [[ $# -ge 1 ]] || { echo "Missing skill name." >&2; exit 1; }
      show_info "$1"
      ;;
    status)
      show_status
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
    uninstall)
      shift
      [[ $# -ge 1 ]] || { echo "Missing uninstall target." >&2; exit 1; }

      if [[ "${1:-}" == "--all-managed" ]]; then
        uninstall_all_managed
        exit 0
      fi

      for skill_name in "$@"; do
        uninstall_one "$skill_name"
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
