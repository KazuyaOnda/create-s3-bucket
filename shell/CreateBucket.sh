#!/bin/sh
## Enter Code
EnvCode=$1
StoreCode=$2
ResourceGroup=$3

## CloudFormation Template
CFTemplate="../yaml/CreateBucket.yml"

## CloudFormation Stack Create
echo '_/_/_/ Start Create CloudFormation Stack _/_/_/'
aws cloudformation create-stack --stack-name $EnvCode-$StoreCode-create --template-body file://$CFTemplate --parameters ParameterKey=EnvCode,ParameterValue=$EnvCode ParameterKey=StoreCode,ParameterValue=$StoreCode --tags Key=ResourceGroup,Value=$ResourceGroup --profile PersonalAdminRole
echo '_/_/_/ End Create CloudFormation Stack _/_/_/'
echo ''

## Wait 10 Seconds S3 Bucket Create
sleep 10s

## Add Lambda InvokeFunction
# ErrorCheck Lambda
echo '_/_/_/ Start ErrorCheck Lambda Add Permission _/_/_/'
aws lambda add-permission --function-name test-check-s3-upload-object --statement-id $EnvCode-$StoreCode-upload-event --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode --profile PersonalAdminRole
echo '_/_/_/ End ErrorCheck Lambda Add Permission _/_/_/'
echo ''

# DiffCheck Lambda
echo '_/_/_/ Start DiffCheck Lambda Add Permission _/_/_/'
aws lambda add-permission --function-name test-check-s3-temp-object --statement-id $EnvCode-$StoreCode-temp-event --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode --profile PersonalAdminRole
echo '_/_/_/ End DiffCheck Lambda Add Permission _/_/_/'
echo ''

# AllTableReCreate Lambda
echo '_/_/_/ Start AllTableReCreate Lambda Add Permission _/_/_/'
aws lambda add-permission --function-name test-check-s3-diff-object --statement-id $EnvCode-$StoreCode-diff-event --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode --profile PersonalAdminRole
echo '_/_/_/ End AllTableReCreate Lambda Add Permission _/_/_/'
echo ''

## Create Null Key for S3 Bucket
# upload
echo '_/_/_/ Start Create Null Key for S3 _/_/_/'
aws s3api put-object --bucket $EnvCode.$StoreCode --key upload/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key checked/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/upload/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/checked/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/brand/ --profile PersonalAdminRole
echo '_/_/_/ End Create Null Key for S3 _/_/_/'
echo ''

## S3 Event Type(Lambda Function)
# Create Object to 'upload/'
LambdaFunctionJson='{
  "LambdaFunctionConfigurations": [
    {
      "Id": "'$EnvCode'.'$StoreCode'/upload/",
      "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:278790208951:function:test-check-s3-upload-object",
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
              "Value": ".csv"
            }
          ]
        }
      }
    }
  ]
}'

echo '_/_/_/ Start Add put-bucket-notification-configuration upload event _/_/_/'
aws s3api put-bucket-notification-configuration --bucket $EnvCode.$StoreCode --notification-configuration "${LambdaFunctionJson}" --profile PersonalAdminRole
echo '_/_/_/ End Add put-bucket-notification-configuration upload event _/_/_/
echo ''

## Brand
# 
while read Brand
do
    # Call CreateBrand.sh
    echo $Brand start
    echo "`/bin/sh ./CreateBrand.sh $EnvCode $StoreCode $Brand $ResourceGroup`"
    sleep 15s
done < ../list/brand.list
