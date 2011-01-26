#!/usr/bin/env bash

usage() {
  printf "

  Usage:

    rvm-install-system-wide [options]

  Options:

    --trace      - Run turn on bash xtrace while the script runs.
    --debug      - Turn on bash verbose while the script runs.
    --version X  - Install RVM version X
    --revision X - Install RVM revision X (sha1)
    --help       - Display this usage text.

"
return 0
}

__rvm_system_wide_permissions() {
  [[ -z "$1" ]] && return 1

  chown -R root:"$rvm_group_name" "$1"

  chmod -R g+w "$1"

  if [[ -d "$1" ]] ; then
    find "$1" -type d -print0 | xargs -n1 -0 chmod g+s
  fi

  return 0
}

__rvm_create_user_group() {
  [[ -z "$1" ]] && return 1

  if \grep -q "$1" /etc/group ; then
    echo "Group '$1' exists, proceeding with installation."
  else
    echo "Creating the group '$1'"

    case "$os_type" in
      "FreeBSD") pw groupadd -q "$rvm_group_name";;
      "Linux")   groupadd -f "$rvm_group_name";;
    esac
  fi

  return 0
}

__rvm_add_user_to_group() {
  [[ -z "$1" || -z "$2" ]] && return 1

  echo "Adding '$1' to the group '$2'"
  
  case "$os_type" in
    "FreeBSD") pw usermod "$1" -G "$2";;
    "Linux")   usermod -a -G "$2" "$1";;
  esac

  return 0
}

os_type="$(uname)"

# Require root to install it.
if [[ "$(whoami)" != "root" ]]; then
  echo "Please rerun this installer as root." >&2
  exit 1

# Check for the presence of git.
elif [[ -z "$(command -v git)" ]] ; then
  echo "Please ensure git is installed and available in PATH to continue." >&2
  exit 1

elif [[ "$os_type" != "Linux" && "$os_type" != "FreeBSD" ]]; then
  echo "The rvm system wide installer currently only supports Linux and FreeBSD." >&2
  exit 1
fi

while [[ $# -gt 0 ]] ; do
  case $1 in
    --trace)
      rvm_trace_flag=1
      set -o xtrace
      ;;
    --debug)
      rvm_trace_flag=1
      set -o verbose
      ;;
    --version|--revision)
      if [[ -n "${2:-""}" ]] ; then
        revision="$2"
        shift
      else
        usage
        exit 1
      fi
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
    ;;
  esac
  shift
done

# Load the rvm config.
rvm_ignore_rvmrc=${rvm_ignore_rvmrc:-0}
if [[ $rvm_ignore_rvmrc -eq 0 ]]; then
  [[ -s /etc/rvmrc ]] && source /etc/rvmrc
  [[ -s "$HOME/.rvmrc" ]] && source "$HOME/.rvmrc"
fi

rvm_path="${rvm_path:-"/usr/local/rvm"}"
export rvm_selfcontained=0

rvm_group_name="${rvm_group_name:-"rvm"}"

__rvm_create_user_group "$rvm_group_name"
__rvm_add_user_to_group "$(whoami)" "$rvm_group_name"

echo "Creating the destination dir and making sure the permissions are correct"
mkdir -p "$rvm_path"
__rvm_system_wide_permissions "$rvm_path"

mkdir -p "$rvm_path/src/"
builtin cd "$rvm_path/src"

rm -rf ./rvm/

git clone --depth 1 git://github.com/wayneeseguin/rvm.git || git clone http://github.com/wayneeseguin/rvm.git

builtin cd rvm

if [[ "${revision:-""}" ]]; then
  echo "Checking out revision $revision"
  git checkout $revision
fi

echo "Running the install script."
bash ./scripts/install "$@"

__rvm_system_wide_permissions "$rvm_path"

echo "Setting up group permissions"
rvm_parent_dir="$(dirname "$rvm_path")"
for dir in bin share/man; do
  __rvm_system_wide_permissions "$rvm_parent_dir/$dir"
done; unset dir

echo "Generating system wide rvmrc"
rm -f /etc/rvmrc
touch /etc/rvmrc
cat > /etc/rvmrc <<END_OF_RVMRC
# Setup default configuration for rvm.
# If an rvm install exists in the home directory, don't load this.'
if [[ ! -s "\$HOME/.rvm/scripts/rvm" ]]; then
  umask g+w
  export rvm_selfcontained=0
  export rvm_prefix="$rvm_parent_dir/"
fi
END_OF_RVMRC

echo "Generating $rvm_parent_dir/lib/rvm to load rvm"
rm -f "$rvm_parent_dir/lib/rvm"
touch "$rvm_parent_dir/lib/rvm"
cat > "$rvm_parent_dir/lib/rvm" <<END_OF_RVM_SH
# Automatically source rvm
if [[ -s "\$HOME/.rvm/scripts/rvm" ]]; then
  source "\$HOME/.rvm/scripts/rvm"
elif [[ -s "/usr/local/rvm/scripts/rvm" ]]; then
  source "/usr/local/rvm/scripts/rvm"
fi
END_OF_RVM_SH

echo "Correct permissions on rvmrc and the rvm loader"
# Finally, ensure the rvmrc is owned by the group.
for file in /etc/rvmrc "$rvm_parent_dir/lib/rvm" ; do
  __rvm_system_wide_permissions "$file"
done; unset file

echo "RVM is now installed. To use, source '$rvm_parent_dir/lib/rvm' to your shell profile."

unset rvm_parent_dir
