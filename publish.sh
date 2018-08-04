#!/bin/bash

# project and associated bucket name
PROJECT_NAME=serverless-tutorial
BUCKET_NAME=$PROJECT_NAME-20180802

# create a local build directory
rm -rf build
mkdir build

# create the bucket
aws s3 mb s3://$BUCKET_NAME 

# create the package
aws cloudformation package                   \
    --template-file template.yaml            \
    --output-template-file build/output.yaml \
    --s3-bucket $BUCKET_NAME                      

# deploy the package
aws cloudformation deploy                     \
    --template-file build/output.yaml         \
    --stack-name $PROJECT_NAME                \
    --capabilities CAPABILITY_IAM             

