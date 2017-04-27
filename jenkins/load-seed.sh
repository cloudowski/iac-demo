#!/bin/bash

curl -s -XPOST 'http://localhost:8888/createItem?name=iac-demo' --data-binary @seed-job.xml -H "Content-Type:text/xml"
