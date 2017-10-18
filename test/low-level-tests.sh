#!/bin/bash
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## ansible-lint
# Perform test in virtualenv
VENVDIR=/tmp/testlow
rm -fr $VENVDIR
virtualenv $VENVDIR
. $VENVDIR/bin/activate
pip install -r $BASEDIR/../requirements.txt

which ansible-lint &> /dev/null || { echo "ERROR: Failed to find ansible-lint binary. Please install it first using pip."; exit 2; }
which pep8 &> /dev/null || { echo "ERROR: Failed to find pep8 binary. Please install it first using pip."; exit 2; }

result=0
echo "1) Running ansible-lint on all '*.yml' files"
for f in $(find $BASEDIR/.. -name '*.yml'|grep -v 'bundle/ruby');do
  echo "$f"
  ansible-lint -r $VENVDIR/site-packages/ansiblelint/rules $f
  if [ $? -ne 0 ];then
    echo FAIL
    result=1
  else
    echo -n OK
  fi
  echo
done

ANSIBLELINT=$?
echo "Ansible-lint RESULT=$ANSIBLELINT"

echo "2) Running pep8 on all '*.py' files"
for f in $(find $BASEDIR/.. -name '*.py');do
  pep8 --config=$BASEDIR/.pep8 $f
  if [ $? -ne 0 ];then
    echo FAIL
    result=1
  else
    echo -n OK
  fi
  echo
done

PEP8=$?
echo "PEP8 RESULT=$PEP8"

cd $BASEDIR/.. ;
ansible-playbook -i inventory/cdtest cf-aio.yml -e scope=low-level-tests
  if [ $? -ne 0 ];then
      echo FAIL
      result=1
    else
      echo -n OK
    fi
    echo

CLOUD=$?
echo "CloudFormation Tests RESULT=$CLOUD"

echo "3) Checking yaml syntax for all inventory files"
for f in $(find $BASEDIR/../inventory -type f ! \( -name "*.ini" -o -name "*.py" -o -name ".*" \));do
  yamllint -c $BASEDIR/../.yamllint $f
  if [ $? -eq 1 ];then
    echo FAIL
    result=1
  else
    echo -n OK
  fi
  echo
done

YAMLTEST=$?
echo "Yamllint Tests RESULT=$YAMLTEST"

echo "4) Checking inventories by executing dummy playbook"
for i in inventory/*;do
  echo -en ">> $i "
  ansible-playbook -i $i dummy.yml -e scope=low-level-tests > /dev/null
  if [ $? -ne 0 ];then
    echo FAIL
    result=1
  else
    echo -n OK
  fi
  echo
done

INVENTORY=$?

echo "
################################################################################
"
echo "1. Ansible-lint RESULT=$ANSIBLELINT"
echo "2. PEP8 RESULT=$PEP8"
echo "3. CloudFormation Tests RESULT=$CLOUD"
echo "4. Yamllint Tests RESULT=$YAMLTEST"
echo "5. Inventory RESULT=$INVENTORY"
echo "
################################################################################
"
exit $result
