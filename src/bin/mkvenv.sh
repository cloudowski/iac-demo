# this file should be sourced inside other scripts to use virtualenv based on requirements.txt

REQFILE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../requirements.txt"

VENVNAME=venv-iac
VENVDIR=/tmp/$VENVNAME
virtualenv $VENVDIR
. $VENVDIR/bin/activate
pip install --upgrade -r $BASEDIR/../requirements.txt
