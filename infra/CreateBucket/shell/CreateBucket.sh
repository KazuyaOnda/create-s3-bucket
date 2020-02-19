#!/bin/sh
## Enter Code
EnvCode=$1
StoreCode=$2
ResourceGroup=$3
Database=$4
ACCOUNT_ID=$5

## CloudFormation Template
CFTemplate="${CODEBUILD_SRC_DIR}/infra/CreateBucket/yaml/CreateBucket.yml"

## CloudFormation Stack Create
echo '_/_/_/ Start Create CloudFormation Stack _/_/_/'
aws cloudformation create-stack --stack-name $EnvCode-$StoreCode-create --template-body file://$CFTemplate --parameters ParameterKey=EnvCode,ParameterValue=$EnvCode ParameterKey=StoreCode,ParameterValue=$StoreCode ParameterKey=Database,ParameterValue=$Database --tags Key=ResourceGroup,Value=$ResourceGroup
echo '_/_/_/ End Create CloudFormation Stack _/_/_/'

## Wait Complete Cloudformation Stack Create
echo '_/_/_/ Check Stack Status _/_/_/'
aws cloudformation wait stack-create-complete --stack-name $EnvCode-$StoreCode-create

## Add Lambda Permission
# ErrorCheck Lambda
echo '_/_/_/ Start ErrorCheck Lambda Add Permission _/_/_/'
aws lambda add-permission --function-name test-check-s3-upload-object --statement-id $EnvCode-$StoreCode-upload-event --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode
echo '_/_/_/ End ErrorCheck Lambda Add Permission _/_/_/'

# DiffCheck Lambda
echo '_/_/_/ Start DiffCheck Lambda Add Permission _/_/_/'
aws lambda add-permission --function-name test-check-s3-temp-object --statement-id $EnvCode-$StoreCode-temp-event --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode
echo '_/_/_/ End DiffCheck Lambda Add Permission _/_/_/'

# AllTableReCreate Lambda
echo '_/_/_/ Start AllTableReCreate Lambda Add Permission _/_/_/'
aws lambda add-permission --function-name test-check-s3-diff-object --statement-id $EnvCode-$StoreCode-diff-event --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode
echo '_/_/_/ End AllTableReCreate Lambda Add Permission _/_/_/'

## Create Null Key for S3 Bucket
# upload
echo '_/_/_/ Start Create Null Key for S3 _/_/_/'
aws s3api put-object --bucket $EnvCode.$StoreCode --key upload/
aws s3api put-object --bucket $EnvCode.$StoreCode --key checked/
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/upload/
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/checked/
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/brand/
echo '_/_/_/ End Create Null Key for S3 _/_/_/'

## S3 Event Type(Lambda Function)
# Create Object to 'upload/'
LambdaFunctionJson='{
  "LambdaFunctionConfigurations": [
    {
      "Id": "upload/",
      "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:'${ACCOUNT_ID}':function:test-check-s3-upload-object",
      "Events": [
        "s3:ObjectCreated:Put"
      ],
      "Filter": {
        "Key": {
          "FilterRules": [
            {
              "Name": "prefix",
              "Value": "upload/"
            }, 
            {
              "Name": "suffix", 
              "Value": "upload.csv"
            }
          ]
        }
      }
    }
  ]
}'

echo '_/_/_/ Start Add put-bucket-notification-configuration upload event _/_/_/'
aws s3api put-bucket-notification-configuration --bucket $EnvCode.$StoreCode --notification-configuration "${LambdaFunctionJson}"
echo '_/_/_/ End Add put-bucket-notification-configuration upload event _/_/_/'

## CloudFormation Stack Delete
echo '_/_/_/ Start Delete CloudFormation Stack _/_/_/'
aws cloudformation delete-stack --stack-name $EnvCode-$StoreCode-create
echo '_/_/_/ End Delete CloudFormation Stack _/_/_/'

echo '_/_/_/ Check Stack Status _/_/_/'
aws cloudformation wait stack-delete-complete --stack-name $EnvCode-$StoreCode-create
