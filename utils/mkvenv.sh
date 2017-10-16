# this file should be sourced inside other scripts to use virtualenv based on requirements.txt

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REQFILE="$BASEDIR/../requirements.txt"

VENVNAME=venv
# prepare virtualenv
VENVDIR=$BASEDIR/../$VENVNAME
virtualenv $VENVDIR
. $VENVDIR/bin/activate
pip install -r $REQFILE


