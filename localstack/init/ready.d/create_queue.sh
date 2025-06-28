#!/usr/bin/env bash

awslocal sqs create-queue --queue-name default.fifo --region ap-northeast-1  --attributes "FifoQueue=true"
