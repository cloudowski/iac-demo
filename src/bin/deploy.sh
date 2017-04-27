#!/bin/bash

set -e

unset CDPATH
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

print_usage() {
cat << EOF

Usage: $0 env

env - environment name from inventory/

EOF

}
[ $# -eq 0 ] && { print_usage; exit 2; }

ENV=$1
SUFFIX=$2
shift $#

[ "$VERSION" ] || { echo "VERSION variable undefined. Please set it up manually with value from existing tags in repo." >&2; exit 1; }
[ -d $BASEDIR/../inventory/$ENV ] || { echo "No inventory found for environment $ENV" >&2; exit 1; }

# use virtualenv
. $BASEDIR/mkvenv.sh

cd $BASEDIR/..

ansible-playbook -i inventory/$ENV \
   -e iac_version="$VERSION" \
   site.yml
