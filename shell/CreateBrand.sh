#!/bin/sh
## GetCode
EnvCode=$1
StoreCode=$2
Brand=$3
ResourceGroup=$4
Database=$5

## Get S3 notification-configuration
echo '_/_/_/ Start Get S3 notification-configuration _/_/_/'
tmpJson=`aws s3api get-bucket-notification-configuration --bucket $EnvCode.$StoreCode`
tmpJsonLine=`echo ${tmpJson} | python -m json.tool | wc -l`
echo '_/_/_/ End Get S3 notification-configuration _/_/_/'

## CloudFormation Template
CFTemplate="${CODEBUILD_SRC_DIR}/yaml/CreateTable_$Brand.yml"

## Create CloudFormation Stack
echo '_/_/_/ Start create CloudFormation Stack ('$Brand') _/_/_/'
aws cloudformation create-stack --stack-name $EnvCode-$StoreCode-$Brand-Table-create --template-body file://$CFTemplate --parameters ParameterKey=EnvCode,ParameterValue=$EnvCode ParameterKey=StoreCode,ParameterValue=$StoreCode ParameterKey=Brand,ParameterValue=$Brand ParameterKey=Database,ParameterValue=$Database --tags Key=ResourceGroup,Value=$ResourceGroup
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

## Edit S3 notification-configuration
echo '_/_/_/ Start add S3 Notification-Configuration ('$Brand') _/_/_/'
editJsonLine=$(($tmpJsonLine - 2))
LambdaFunctionJson=`echo $tmpJson | python -m json.tool | head -$editJsonLine`

LambdaFunctionJson+=',
    {
        "Id": "'/brand/'$Brand'/temp/'",
        "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:278790208951:function:test-check-s3-temp-object",
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
        "Id": "'/brand/'$brand'/diff/'",
        "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:278790208951:function:test-check-s3-diff-object",
        "Events": [
            "s3:ObjectCreated:Put"
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
echo '_/_/_/ Finish add S3 Notification-Configuration ('$Brand') _/_/_/'

echo '_/_/_/ Start add put-bucket-notification-configuration brand event _/_/_/'
aws s3api put-bucket-notification-configuration --bucket $EnvCode.$StoreCode --notification-configuration "${LambdaFunctionJson}"
echo '_/_/_/ Finish add put-bucket-notification-configuration brand event _/_/_/'
