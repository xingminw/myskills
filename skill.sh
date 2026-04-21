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
  ./skill.sh list [--status STATUS] [--installed]
  ./skill.sh show <skill>
  ./skill.sh status [skill...]
  ./skill.sh install [--all] [--status STATUS] [skill...]
  ./skill.sh pull <skill>
  ./skill.sh uninstall [skill...]
  ./skill.sh uninstall --all-managed
  ./skill.sh help

Examples:
  ./skill.sh list
  ./skill.sh list --status draft
  ./skill.sh list --installed
  ./skill.sh show paper-revision
  ./skill.sh status
  ./skill.sh status paper-revision
  ./skill.sh install paper-revision
  ./skill.sh install --status stable
  ./skill.sh install --all
  ./skill.sh pull paper-revision
  ./skill.sh uninstall paper-revision
  ./skill.sh uninstall --all-managed

Notes:
  - Running with no arguments defaults to: ./skill.sh install --all
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

skill_field_from_file() {
  local file_path="$1"
  local field_name="$2"
  awk -v field="$field_name" '
    BEGIN { in_frontmatter = 0; seen_start = 0 }
    $0 == "---" {
      if (!seen_start) {
        seen_start = 1
        in_frontmatter = 1
        next
      }
      if (in_frontmatter) exit
    }
    in_frontmatter && $1 == field ":" {
      sub("^[^:]+:[[:space:]]*", "", $0)
      print $0
      exit
    }
  ' "$file_path"
}

print_skill_line() {
  local skill_name="$1"
  local lifecycle_status="${2:-}"
  local install_state="${3:-}"
  local source_label="${4:-}"
  local version="${5:-}"
  local trailer="${6:-}"
  local meta_parts=()

  printf '%s' "$skill_name"
  [[ -n "$lifecycle_status" ]] && meta_parts+=("$lifecycle_status")
  [[ -n "$install_state" ]] && meta_parts+=("$install_state")
  [[ -n "$source_label" ]] && meta_parts+=("$source_label")
  [[ -n "$version" ]] && meta_parts+=("v$version")
  if [[ "${#meta_parts[@]}" -gt 0 ]]; then
    printf ' ['
    local i
    for i in "${!meta_parts[@]}"; do
      [[ "$i" -gt 0 ]] && printf ' | '
      printf '%s' "${meta_parts[$i]}"
    done
    printf ']'
  fi
  [[ -n "$trailer" ]] && printf ' %s' "$trailer"
  printf '\n'
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

sync_from_global() {
  local skill_name="$1"
  local registry_path
  local repo_path
  local global_path="$TARGET_DIR/$skill_name"

  registry_path="$(registry_get_field "$skill_name" "path")"

  if [[ -z "$registry_path" ]]; then
    echo "Skill not found in registry: $skill_name" >&2
    exit 1
  fi

  if [[ ! -d "$global_path" ]]; then
    echo "Installed global skill not found: $global_path" >&2
    exit 1
  fi

  if [[ ! -f "$global_path/SKILL.md" ]]; then
    echo "Installed global skill is missing SKILL.md: $global_path" >&2
    exit 1
  fi

  repo_path="$REPO_DIR/$registry_path"

  rm -rf "$repo_path"
  mkdir -p "$(dirname "$repo_path")"
  cp -r "$global_path" "$repo_path"
  echo "Synced $skill_name from $global_path -> $repo_path"
}

list_repo_skills() {
  local status_filter="${1:-}"
  local skill_name
  local status
  local version
  local install_state

  for skill_name in $(registry_ids); do
    if [[ -n "$status_filter" ]]; then
      status="$(registry_get_field "$skill_name" "status")"
      [[ "$status" == "$status_filter" ]] || continue
    else
      status="$(registry_get_field "$skill_name" "status")"
    fi

    version="$(registry_get_field "$skill_name" "version")"
    if [[ -d "$TARGET_DIR/$skill_name" ]]; then
      install_state="installed"
    else
      install_state="not-installed"
    fi
    print_skill_line "$skill_name" "$status" "$install_state" "in-myskills" "$version"
  done
}

list_installed_skills() {
  local installed_name
  local count=0
  local installed_version
  local lifecycle_status
  local source_label

  for installed_name in $(installed_skill_ids); do
    count=1
    installed_version="$(skill_field_from_file "$TARGET_DIR/$installed_name/SKILL.md" "version")"
    if registry_has_skill "$installed_name"; then
      lifecycle_status="$(registry_get_field "$installed_name" "status")"
      source_label="in-myskills"
    else
      lifecycle_status=""
      source_label="external"
    fi
    print_skill_line "$installed_name" "$lifecycle_status" "installed" "$source_label" "$installed_version"
  done

  if [[ "$count" -eq 0 ]]; then
    echo "No installed skills found in $TARGET_DIR"
  fi
}

show_skill() {
  local skill_name="$1"

  if ! registry_has_skill "$skill_name"; then
    echo "Skill not found in registry: $skill_name" >&2
    exit 1
  fi

  registry_print_block "$skill_name"
}

check_one_consistency() {
  local skill_name="$1"
  local registry_path
  local repo_path
  local global_path
  local repo_name
  local global_name
  local repo_version
  local global_version
  local lifecycle_status
  local ok=1

  registry_path="$(registry_get_field "$skill_name" "path")"
  lifecycle_status="$(registry_get_field "$skill_name" "status")"

  if [[ -z "$registry_path" ]]; then
    print_skill_line "$skill_name" "error" "" "" "" "not found in registry"
    return 1
  fi

  repo_path="$REPO_DIR/$registry_path/SKILL.md"
  global_path="$TARGET_DIR/$skill_name/SKILL.md"

  if [[ ! -f "$repo_path" ]]; then
    print_skill_line "$skill_name" "$lifecycle_status" "" "in-myskills" "" "repo SKILL.md missing"
    return 1
  fi

  if [[ ! -f "$global_path" ]]; then
    print_skill_line "$skill_name" "$lifecycle_status" "not-installed" "in-myskills" "$(registry_get_field "$skill_name" "version")" "not compared against global"
    return 0
  fi

  repo_name="$(skill_field_from_file "$repo_path" "name")"
  global_name="$(skill_field_from_file "$global_path" "name")"
  repo_version="$(skill_field_from_file "$repo_path" "version")"
  global_version="$(skill_field_from_file "$global_path" "version")"

  if [[ "$repo_name" != "$global_name" ]]; then
    ok=0
  fi

  if [[ "$repo_version" != "$global_version" ]]; then
    ok=0
  fi

  if [[ "$ok" -eq 1 ]]; then
    print_skill_line "$skill_name" "$lifecycle_status" "installed" "in-myskills" "${repo_version:-}" "repo/global consistent"
  else
    print_skill_line "$skill_name" "$lifecycle_status" "installed" "in-myskills" "${repo_version:-}" "repo/global mismatch: repo(name=$repo_name version=${repo_version:-none}) global(name=$global_name version=${global_version:-none})"
    return 1
  fi
}

show_sync_status() {
  local failed=0
  local skill_name

  if [[ $# -gt 0 ]]; then
    for skill_name in "$@"; do
      if ! check_one_consistency "$skill_name"; then
        failed=1
      fi
    done
  else
    while IFS= read -r skill_name; do
      [[ -n "$skill_name" ]] || continue
      if ! check_one_consistency "$skill_name"; then
        failed=1
      fi
    done < <(registry_ids)
  fi

  if [[ "$failed" -ne 0 ]]; then
    exit 1
  fi
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
      if [[ "${1:-}" == "--installed" ]]; then
        list_installed_skills
        exit 0
      fi

      if [[ "${1:-}" == "--status" ]]; then
        [[ $# -ge 2 ]] || { echo "Missing status value." >&2; exit 1; }
        list_repo_skills "$2"
      else
        list_repo_skills
      fi
      ;;
    show)
      shift
      [[ $# -ge 1 ]] || { echo "Missing skill name." >&2; exit 1; }
      show_skill "$1"
      ;;
    status)
      shift
      show_sync_status "$@"
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
    pull)
      shift
      [[ $# -ge 1 ]] || { echo "Missing skill name." >&2; exit 1; }
      sync_from_global "$1"
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
