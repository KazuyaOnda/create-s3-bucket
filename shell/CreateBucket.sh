#!/bin/sh
## Enter Code
EnvCode='tpplocaltest'
StoreCode=$1

## CloudFormation Template
CFTemplate="../yaml/CreateBucket.yml"

## CloudFormation Stack Create
echo '* --------------------'
echo 'Create CloudFormation Stack Start'
aws cloudformation create-stack --stack-name $EnvCode-$StoreCode-create --template-body file://$CFTemplate --parameters ParameterKey=EnvCode,ParameterValue=$EnvCode ParameterKey=StoreCode,ParameterValue=$StoreCode --tags Key=ResourceGroup,Value=TPP --profile PersonalAdminRole
echo 'Create CloudFormation Stack Finish'
echo '-------------------- *'
echo ''

## Wait 10 Seconds S3 Bucket Create
sleep 10s

## Add Lambda InvokeFunction
# ErrorCheck Lambda
echo '* --------------------'
echo 'ErrorCheck Lambda Add Permission Start'
aws lambda add-permission --function-name test-check-s3-upload-object --statement-id $EnvCode-$StoreCode-upload-event --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode --profile PersonalAdminRole
echo 'ErrorCheck Lambda Add Permission Finish'
echo '-------------------- *'
echo ''

# DiffCheck Lambda
echo '* --------------------'
echo 'DiffCheck Lambda Add Permission Start'
aws lambda add-permission --function-name test-check-s3-temp-object --statement-id $EnvCode-$StoreCode-temp-event --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode --profile PersonalAdminRole
echo 'DiffCheck Lambda Add Permission Finish'
echo '-------------------- *'
echo ''

# AllTableReCreate Lambda
echo '* --------------------'
echo 'AllTableReCreate Lambda Add Permission Start'
aws lambda add-permission --function-name test-check-s3-diff-object --statement-id $EnvCode-$StoreCode-diff-event --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode --profile PersonalAdminRole
echo 'AllTableReCreate Lambda Add Permission Finish'
echo '-------------------- *'
echo ''

## Create Null Key for S3 Bucket
# upload
echo '* --------------------'
echo 'Create Null Key for S3 Start'
aws s3api put-object --bucket $EnvCode.$StoreCode --key upload/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key checked/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/upload/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/checked/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/brand/ --profile PersonalAdminRole
echo 'Create Null Key for S3 Finish'
echo '-------------------- *'
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

echo '* --------------------'
echo 'Add put-bucket-notification-configuration upload event Start'
aws s3api put-bucket-notification-configuration --bucket $EnvCode.$StoreCode --notification-configuration "${LambdaFunctionJson}" --profile PersonalAdminRole
echo 'Add put-bucket-notification-configuration upload event Finish'
echo '-------------------- *'
echo ''

## brand
# 
while read brand
do
    # Call CreateBrand.sh
    echo $brand start
    echo "`/bin/sh ./CreateBrand.sh $EnvCode $StoreCode $brand`"
    sleep 15s
done < ../list/brand.list
