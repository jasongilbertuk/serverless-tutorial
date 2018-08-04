# AWS Serverless Tutorial - Stage 1

A tutorial which is based on AWS Serverless Application Model (SAM).
In this stage, we'll create the most basic of lambda functions, using the SAM template.
As per the screenshot below, this will consist of a lambda function, together with an S3 bucket that stores the lambda code.
[Link to previous step](https://github.com/jasongilbertuk/ServerlessTutorial/tree/0)


![Alt text](documentation/stage1.png?raw=true "Stage 1")

## template.yaml     
### SAM CloudFormation Template 

The SAM (Serverless Application Model) provides a series of extentions to the CloudFormation template that dramatically simply the setup of a Serverless stack (API Gateway / Lambda / Dynamo etc).

We will use yaml and start by defining a basic SAM template that creates a basic Lambda.

Create a file called template.yaml. Here is the full file we'll use for this stage:
```
AWSTemplateFormatVersion: 2010-09-09
Transform: AWS::Serverless-2016-10-31
Description: AWS Serverless Tutorial
Resources:
  MyFirstLambda:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: MyFirstLambda
      Handler: index.handler
      Runtime: nodejs6.10
      CodeUri: myCode 
      MemorySize: 128 
      Timeout: 30
      Policies:
        - AWSLambdaBasicExecutionRole
```
Let's disect it a line at a time:
```
AWSTemplateFormatVersion: 2010-09-09
```
This is standard for any cloudformation template, you don't change this. It basically tells the CloudFormation system what version of cloudformation syntax is supported. 

```
Transform: AWS::Serverless-2016-10-31
```
This is standard for any SAM based cloudformation template, you don't change this. It basically tells the CloudFormation system that this template contains serverless extensions and needs to be processed accordingly.

```
Description: AWS Serverless Tutorial
```
A textual description that will be associated with the Cloudformation stack generated.


```
Resources:
```
Defines the start of the resources section. What follows are resources that we want cloudformation to create.

```
  MyFirstLambda:
    Type: AWS::Serverless::Function
```
Our first resource is called MyFirstLambda and is of type AWS::Serverless::Function (IE: a lambda)

```
    Properties:
```
Defines the start of the Properties section for the MyFirstLambda resource.

```
      FunctionName: MyFirstLambda
```
The name of the Lambda Function

```
      Handler: index.handler
```
The file / function within file to invoke when the Lambda is triggered. See description of index.js later in this file.

```
      Runtime: nodejs6.10
```
The runtime for the lambda. In our case, the lambda code is written in nodejs and we're using v6.10 of the node runtime.

```
      CodeUri: myCode
```
The local directory (relative to the yaml file) that contains the code for the lambda (index.js)

<<<<<<< HEAD
## Next step
[Proceed to next step](https://github.com/jasongilbertuk/ServerlessTutorial/tree/1)
=======
```
      MemorySize: 128
```
The memory size required by the AWS resource that runs the lambda.

```
      Timeout: 30
```
Maximum time (in seconds) which the lambda function can run for. 

```
      Policies:
        - AWSLambdaBasicExecutionRole
```
For the lambda to run, it will need to be given one or more roles. At this stage, we will just give it
the basic execution role. Later, as we start to expand the functionality of our lamda, we will add additional roles (eg: access to dynamodb)


## myCode/index.js    
### Our lambda function
Create a file called index.js in a subdirectory called myCode. This file will hold our nodejs lambda code.

Here is the full file:
```
'use strict';

exports.handler = function(event, context, callback) {

  var responseBody = {
    "message" : "Hello World!"
  };

    const response = { 'statusCode': 200, 
                       'headers': {'Content-Type': 'application/json'},
                       'body': JSON.stringify(responseBody),
                       'isBase64Encoded' : false };
    callback(null, response);
}
```

This is relatively simple. The 'use strict' ensures that our code is run in strict mode, good programming practice for javascript. We tgen export a function called handler (note this matches the index.handler definition earlier in the template.yaml file). That function generates a response json object and invokes the supplied callback to return this.

## publish.sh    
### Shell script to package and deploy our serverless application
Create a file called publish.sh. Here is the full file we'll use for this stage:
```
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

```
Let's disect it a line at a time:

```
#!/bin/bash
```
Shell script 101. If you don't know what this is, google it.

```
# project and associated bucket name
PROJECT_NAME=serverless-tutorial
BUCKET_NAME=$PROJECT_NAME-20180802
```
Two variables define. The first is a name for our project, the second is the name we wish to use for our S3 bucket, which is the project name suffixed with a unique identfiier (in this case I've used todays date). Two key points to note: (1) everything should be in lowercase, as s3 buckets do not support uppercase and (2) name of bucket should be unique (IE: If you try to use exact name as specified, this will fail as the bucket nameed serverless-tutorial-20180802 belongs to my AWS account)

```
# create a local build directory
rm -rf build
mkdir build
```
We are going to use a temp directory to hold our build files. The above steps empty / remove this directory if it exists, then creates the directory afresh.

```
# create the bucket
aws s3 mb s3://$BUCKET_NAME 
```
This step calls the AWS CLI to create the S3 bucket. If the bucket name already exists, this step will fail, but the script will continue.

```
# create the package
aws cloudformation package                   \
    --template-file template.yaml            \
    --output-template-file build/output.yaml \
    --s3-bucket $BUCKET_NAME                 
```
This step uses the information held in the template.yaml file to package up and upload the application to AWS. This includes the uploading of the Lambda code to the s3 bucket specified (as a zipped file) and creates a copy of the template.yaml file, called output.yaml, where the code uri has been altered to point to this zipped up file in the S3 bucket.


```
aws cloudformation deploy                     \
    --template-file build/output.yaml         \
    --stack-name $PROJECT_NAME                \
    --capabilities CAPABILITY_IAM                     
```
This step calls the AWS CLI to deploy the project using cloudformation.

## Putting it all together
If you have not already done so, first make this file executable by running the command chmod +x publish.sh 
Now run the publish.sh shell script. If all correct, this should package and deploy your lambda.
![Alt text](documentation/screenshot0.png?raw=true "Screenshot 0")

In the AWS console, go to CloudFormation and check that your stack deployed successfully.
![Alt text](documentation/screenshot1.png?raw=true "Screenshot 1")

In the AWS console, go to Lambda and examine the myFirstLambda function deployed.
![Alt text](documentation/screenshot2.png?raw=true "Screenshot 2")


In the AWS console,run a test on the Lambda, and ensure that it executes and returns the result expected.
![Alt text](documentation/screenshot4.png?raw=true "Screenshot 4")


## Next step
[Proceed to next step](https://github.com/jasongilbertuk/ServerlessTutorial/tree/2)
>>>>>>> master
