#!/usr/bin/env bash

BASE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $BASE/../tf
for env in test prod;do
    terraform workspace select $env && terraform destroy
    terraform workspace select default
    terraform workspace delete $env
done
