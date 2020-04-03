#!/bin/sh
## Enter Code
EnvCode=$1
StoreCode=$2
ResourceGroup=$3
Database=$4

ACCOUNT_ID=`aws sts get-caller-identity --query 'Account' --output text`

## Check if arguments are entered
if [ $# -lt 4 ]; then
  echo "## エラー ##"
  echo "## 引数が不足しています。環境変数を確認してください ##"
  exit 1
fi

## CloudFormation Template
CFTemplate="${CODEBUILD_SRC_DIR}/infra/CreateStore/yaml/CreateStore.yml"

## CloudFormation Stack Create
echo '_/_/_/ Start Create CloudFormation Stack _/_/_/'
aws cloudformation create-stack --stack-name $EnvCode-$StoreCode-create --template-body file://$CFTemplate --parameters ParameterKey=EnvCode,ParameterValue=$EnvCode ParameterKey=StoreCode,ParameterValue=$StoreCode ParameterKey=Database,ParameterValue=$Database --tags Key=ResourceGroup,Value=$ResourceGroup

## Wait Complete Cloudformation Stack Create
aws cloudformation wait stack-create-complete --stack-name $EnvCode-$StoreCode-create
echo '_/_/_/ End Create CloudFormation Stack _/_/_/'

# DiffCheck Lambda
echo '_/_/_/ Start CreateDiffFunction Lambda Add Permission _/_/_/'
aws lambda add-permission --function-name CreateDiffFunction --statement-id $EnvCode-$StoreCode-permission --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode
echo '_/_/_/ End CreateDiffFunction Lambda Add Permission _/_/_/'

# AllTableReCreate Lambda
echo '_/_/_/ Start CreateAllFunction Lambda Add Permission _/_/_/'
aws lambda add-permission --function-name CreateAllFunction --statement-id $EnvCode-$StoreCode-permission --action lambda:InvokeFunction --principal s3.amazonaws.com --source-arn arn:aws:s3:::$EnvCode.$StoreCode
echo '_/_/_/ End CreateAllFunction Lambda Add Permission _/_/_/'

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

## CloudFormation Stack Delete
echo '_/_/_/ Start Delete CloudFormation Stack _/_/_/'
aws cloudformation delete-stack --stack-name $EnvCode-$StoreCode-create

## Wait Complete Cloudformation Stack Delete
aws cloudformation wait stack-delete-complete --stack-name $EnvCode-$StoreCode-create
echo '_/_/_/ Check Stack Status _/_/_/'
