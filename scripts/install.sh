#!/usr/bin/env bash
# Installs, uninstalls or lists skills from this repo in an agent's skills directory.
# Run with --help for usage.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/install.sh --target cursor|claude|agents [options]

Options:
  --skill NAME      Only act on this skill (repeatable). Default: all skills.
  --project PATH    Use PATH/.<target>/skills instead of ~/.<target>/skills.
  --copy            Copy instead of creating a symlink.
  --force           Replace existing installs; remove copies on --uninstall.
  --uninstall       Remove the selected skills.
  --list            Show the install status of each skill.
  -h, --help        Show this help.

Examples:
  scripts/install.sh --target cursor
  scripts/install.sh --target claude --skill prz-grillme --skill prz-plan
  scripts/install.sh --target cursor --project ../my-app
  scripts/install.sh --target cursor --list
  scripts/install.sh --target cursor --uninstall --skill prz-plan
EOF
}

die() {
  echo "Error: $*" >&2
  exit 1
}

warn() {
  echo "Warning: $*" >&2
}

target=""
project=""
copy=0
force=0
uninstall=0
list=0
skills=()

while [ $# -gt 0 ]; do
  case "$1" in
    --target) [ $# -ge 2 ] || die "--target needs a value"; target="$2"; shift 2 ;;
    --skill) [ $# -ge 2 ] || die "--skill needs a value"; skills+=("$2"); shift 2 ;;
    --project) [ $# -ge 2 ] || die "--project needs a value"; project="$2"; shift 2 ;;
    --copy) copy=1; shift ;;
    --force) force=1; shift ;;
    --uninstall) uninstall=1; shift ;;
    --list) list=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; die "unknown option '$1'" ;;
  esac
done

case "$target" in
  cursor|claude|agents) ;;
  "") usage >&2; die "--target is required" ;;
  *) die "--target must be cursor, claude or agents" ;;
esac

[ "$uninstall" -eq 1 ] && [ "$list" -eq 1 ] && die "--uninstall and --list cannot be combined"
if { [ "$uninstall" -eq 1 ] || [ "$list" -eq 1 ]; } && [ "$copy" -eq 1 ]; then
  die "--copy only applies to installs"
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
skills_root="$repo_root/skills"

if [ -n "$project" ]; then
  [ -d "$project" ] || die "project directory '$project' does not exist"
  base_dir="$(cd "$project" && pwd -P)"
else
  base_dir="$HOME"
fi
dest_root="$base_dir/.$target/skills"

repo_skills=()
for dir in "$skills_root"/*/; do
  [ -f "$dir/SKILL.md" ] && repo_skills+=("$(basename "$dir")")
done

is_repo_skill() {
  local name
  for name in "${repo_skills[@]}"; do
    [ "$name" = "$1" ] && return 0
  done
  return 1
}

if [ ${#skills[@]} -gt 0 ]; then
  for name in "${skills[@]}"; do
    is_repo_skill "$name" || die "skill '$name' not found in $skills_root"
  done
  selected=("${skills[@]}")
else
  selected=("${repo_skills[@]}")
fi

skill_status() {
  local dest="$1" src="$2"
  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then
      echo "linked"
    else
      echo "linked elsewhere"
    fi
  elif [ -e "$dest" ]; then
    echo "copied"
  else
    echo "not installed"
  fi
}

remove_installed() {
  if [ -L "$1" ]; then
    rm "$1"
  else
    rm -rf "$1"
  fi
}

install_skill() {
  local name="$1"
  local src="$skills_root/$name" dest="$dest_root/$name" status
  status="$(skill_status "$dest" "$src")"

  if [ "$status" = "linked" ] && [ "$copy" -eq 0 ]; then
    echo "[skip]    $name (already linked)"
    return
  fi
  if [ "$status" != "not installed" ]; then
    if [ "$force" -eq 0 ]; then
      warn "$dest already exists ($status); use --force to replace it."
      return
    fi
    remove_installed "$dest"
  fi

  if [ "$copy" -eq 0 ]; then
    if ln -s "$src" "$dest" 2>/dev/null && [ -L "$dest" ]; then
      echo "[linked]  $name -> $dest"
      return
    fi
    # Git Bash on Windows may "succeed" by copying instead of linking.
    [ -e "$dest" ] && remove_installed "$dest"
    warn "could not create a symlink for $name; copying instead."
  fi

  cp -R "$src" "$dest"
  echo "[copied]  $name -> $dest"
}

uninstall_skill() {
  local name="$1"
  local src="$skills_root/$name" dest="$dest_root/$name" status
  status="$(skill_status "$dest" "$src")"

  case "$status" in
    "not installed")
      echo "[skip]    $name (not installed)"
      ;;
    linked)
      remove_installed "$dest"
      echo "[removed] $name"
      ;;
    *)
      if [ "$force" -eq 0 ]; then
        warn "$dest is $status (may contain local changes); use --force to remove it."
        return
      fi
      remove_installed "$dest"
      echo "[removed] $name ($status)"
      ;;
  esac
}

show_skills() {
  local name entry width=0 external=()

  echo "Destination: $dest_root"
  if [ -d "$dest_root" ]; then
    if [ ${#skills[@]} -eq 0 ]; then
      for entry in "$dest_root"/*/ "$dest_root"/.[!.]*/; do
        [ -d "$entry" ] || continue
        name="$(basename "$entry")"
        is_repo_skill "$name" || external+=("$name")
      done
    fi
  else
    echo "  (directory does not exist)"
  fi

  for name in "${selected[@]}" ${external[@]+"${external[@]}"}; do
    [ ${#name} -gt "$width" ] && width=${#name}
  done
  width=$((width + 2))

  for name in "${selected[@]}"; do
    printf '  %-*s%s\n' "$width" "$name" "$(skill_status "$dest_root/$name" "$skills_root/$name")"
  done
  for name in ${external[@]+"${external[@]}"}; do
    printf '  %-*s%s\n' "$width" "$name" "external (not from this repo)"
  done
}

if [ "$list" -eq 1 ]; then
  show_skills
elif [ "$uninstall" -eq 1 ]; then
  for name in "${selected[@]}"; do uninstall_skill "$name"; done
else
  mkdir -p "$dest_root"
  for name in "${selected[@]}"; do install_skill "$name"; done
fi
