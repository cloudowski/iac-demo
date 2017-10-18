#!/bin/bash

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $BASEDIR/..

bundle install --standalone

echo "Running test-kitchen"
bundle exec kitchen test --destroy=always --concurrency=5
result=$?

echo "RESULT=$result"
exit $result
