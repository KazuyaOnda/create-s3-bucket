#!/bin/bash
## GetCode
EnvCode=$1
StoreCode=$2
ResourceGroup=$3
Database=$4
ACCOUNT_ID=$5
Brand=$6

## Execute Date
ExecDate=`date "+%Y%m%d%H%M%S"`

## CloudFormation Template
CFTemplate="${CODEBUILD_SRC_DIR}/infra/CreateBrand/yaml/CreateTable_$Brand.yml"

## Create CloudFormation Stack
echo '_/_/_/ Start create CloudFormation Stack ('$Brand') _/_/_/'
aws cloudformation create-stack \
--stack-name $EnvCode-$StoreCode-$Brand-Table-create \
--template-body file://$CFTemplate \
--parameters ParameterKey=EnvCode,ParameterValue=$EnvCode \
ParameterKey=StoreCode,ParameterValue=$StoreCode \
ParameterKey=Brand,ParameterValue=$Brand \
ParameterKey=Database,ParameterValue=$Database \
--tags Key=ResourceGroup,Value=$ResourceGroup

## Wait Complete Cloudformation Stack Create
aws cloudformation wait stack-create-complete --stack-name $EnvCode-$StoreCode-$Brand-Table-create
echo '_/_/_/ End create CloudFormation Stack ('$Brand') _/_/_/'

## Create Null key for S3 Bucket
echo '_/_/_/ Start create Null key for S3 Bucket ('$Brand') _/_/_/'
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/$Brand/
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/$Brand/all/
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/$Brand/temp/
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/$Brand/diff/
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/brand/$Brand/
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/brand/$Brand/all/
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/brand/$Brand/diff/
echo '_/_/_/ End create Null key for S3 Bucket ('$Brand') _/_/_/'

## Copy Default All CSV File
echo '_/_/_/ Start copy default all csv file _/_/_/'
aws s3api copy-object --bucket $EnvCode.$StoreCode \
--copy-source $EnvCode.master-files/template-csv/${Brand}_all_default.csv \
--key brand/$Brand/all/all_$EnvCode.$StoreCode_$Brand_$ExecDate.csv
echo '_/_/_/ End copy default all csv file _/_/_/'

echo '_/_/_/ Start add put-bucket-notification-configuration ('$Brand') _/_/_/'
## Get S3 notification-configuration
tmpJson=`aws s3api get-bucket-notification-configuration --bucket $EnvCode.$StoreCode`
tmpJsonByte=`echo ${tmpJson} | wc -c`

if [ $tmpJsonByte -le 1 ]; then
  LambdaFunctionJson='{
    "LambdaFunctionConfigurations": [
'
else
  ## Edit S3 notification-configuration
  ### Get Current Configuration Lines
  tmpJsonLine=`echo ${tmpJson} | python -m json.tool | wc -l`
  ### Current Lines -2 Lines
  editJsonLine=$(($tmpJsonLine - 2))
  ### Current Configuration Get the last two lines deleted
  LambdaFunctionJson=`echo $tmpJson | python -m json.tool | head -$editJsonLine`
  ### Add Comma for next Setting
  LambdaFunctionJson+=','
fi

## Add S3 Notification Configuration
LambdaFunctionJson+='{
        "Id": "brand/'$Brand'/temp/",
        "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:'${ACCOUNT_ID}':function:test-check-s3-temp-object",
        "Events": [
            "s3:ObjectCreated:Put"
        ],
        "Filter": {
            "Key": {
                "FilterRules": [
                    {
                        "Name": "Prefix",
                        "Value": "brand/'$Brand'/temp/"
                    }, 
                    {
                        "Name": "Suffix", 
                        "Value": ".csv"
                    }
                ]
            }
        }
    },
    {
        "Id": "brand/'$Brand'/diff/diff_",
        "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:'${ACCOUNT_ID}':function:test-check-s3-diff-object",
        "Events": [
            "s3:ObjectCreated:Copy"
        ],
        "Filter": {
            "Key": {
                "FilterRules": [
                    {
                        "Name": "Prefix",
                        "Value": "brand/'$Brand'/diff/diff_"
                    }, 
                    {
                        "Name": "Suffix", 
                        "Value": ".csv"
                    }
                ]
            }
        }
    }
    ]
}
'

aws s3api put-bucket-notification-configuration --bucket $EnvCode.$StoreCode \
--notification-configuration "${LambdaFunctionJson}"
echo '_/_/_/ Finish add put-bucket-notification-configuration ('$Brand') _/_/_/'

## CloudFormation Stack Delete
echo '_/_/_/ Start Delete CloudFormation Stack _/_/_/'
aws cloudformation delete-stack --stack-name $EnvCode-$StoreCode-$Brand-Table-create

## Wait Complete Cloudformation Stack Delete
aws cloudformation wait stack-delete-complete --stack-name $EnvCode-$StoreCode-$Brand-Table-create
echo '_/_/_/ End Delete CloudFormation Stack _/_/_/'
