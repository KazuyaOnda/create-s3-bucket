#!/bin/sh
## GetCode
EnvCode=$1
StoreCode=$2
brand=$3

## Get S3 notification-configuration
echo '_/_/_/ Start Get S3 notification-configuration _/_/_/'
tmpJson=`aws s3api get-bucket-notification-configuration --bucket $EnvCode.$StoreCode --profile PersonalAdminRole`
tmpJsonLine=`echo ${tmpJson} | python -m json.tool | wc -l`
echo '_/_/_/ Finish Get S3 notification-configuration _/_/_/'

## CloudFormation Template
CFTemplate="../yaml/CreateTable_$brand.yml"

## Create CloudFormation Stack
echo '_/_/_/ Start create CloudFormation Stack ('$brand') _/_/_/'
aws cloudformation create-stack --stack-name $EnvCode-$StoreCode-$brand-Table-create --template-body file://$CFTemplate --parameters ParameterKey=EnvCode,ParameterValue=$EnvCode ParameterKey=StoreCode,ParameterValue=$StoreCode --tags Key=ResourceGroup,Value=TPP --profile PersonalAdminRole
echo '_/_/_/ Finish create CloudFormation Stack ('$brand') _/_/_/'

## Create Null key for S3 Bucket
echo '_/_/_/ Start create Null key for S3 Bucket ('$brand') _/_/_/'
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/$brand/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/$brand/all/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/$brand/temp/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key brand/$brand/diff/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/brand/$brand/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/brand/$brand/all/ --profile PersonalAdminRole
aws s3api put-object --bucket $EnvCode.$StoreCode --key old/brand/$brand/diff/ --profile PersonalAdminRole
echo '_/_/_/ Finish create Null key for S3 Bucket ('$brand') _/_/_/'

## Edit S3 notification-configuration
echo '_/_/_/ Start add S3 Notification-Configuration ('$brand') _/_/_/'
editJsonLine=$(($tmpJsonLine - 2))
LambdaFunctionJson=`echo $tmpJson | python -m json.tool | head -$editJsonLine`

LambdaFunctionJson+=',
    {
        "Id": "'$EnvCode'.'$StoreCode'/'$brand'/temp/",
        "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:278790208951:function:test-check-s3-temp-object",
        "Events": [
            "s3:ObjectCreated:Put"
        ],
        "Filter": {
            "Key": {
                "FilterRules": [
                    {
                        "Name": "Prefix",
                        "Value": "brand/'$brand'/temp/"
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
        "Id": "'$EnvCode'.'$StoreCode'/'$brand'/diff/",
        "LambdaFunctionArn": "arn:aws:lambda:ap-northeast-1:278790208951:function:test-check-s3-diff-object",
        "Events": [
            "s3:ObjectCreated:Put"
        ],
        "Filter": {
            "Key": {
                "FilterRules": [
                    {
                        "Name": "Prefix",
                        "Value": "brand/'$brand'/diff/"
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
echo '_/_/_/ Finish add S3 Notification-Configuration ('$brand') _/_/_/'

#echo $LambdaFunctionJson | python -m json.tool

echo '_/_/_/ Start add put-bucket-notification-configuration brand event _/_/_/'
aws s3api put-bucket-notification-configuration --bucket $EnvCode.$StoreCode --notification-configuration "${LambdaFunctionJson}" --profile PersonalAdminRole
echo '_/_/_/ Finish add put-bucket-notification-configuration brand event _/_/_/'
