#!/usr/bin/env bash

curl -s -XPOST 'http://localhost:8888/createItem?name=ansible-pipeline' --data-binary @seed-job.xml -H "Content-Type:text/xml"
curl -s -XPOST 'http://localhost:8888/createItem?name=terraform-aws-vpc-pipeline' --data-binary @seed-job-tf.xml -H "Content-Type:text/xml"
