#!/bin/sh
## GetCode
EnvCode=$1
StoreCode=$2
ResourceGroup=$3
Database=$4
ACCOUNT_ID=$5
ForkFlg=$6
Brand=$7

## Check if arguments are entered
#if [ $# -ne 6 ]; then
#  echo "引数が不足しています。環境変数を確認してください。"
#  exit 1
#fi

echo $ForkFlg
echo $Brand

## Get S3 notification-configuration
echo '_/_/_/ Check Brand Fork (AllBrand or OneBrand) _/_/_/'
if [ $ForkFlg = "all" ]; then
    while read Brand
    do
        echo 'All Brand Create'
        /bin/bash ${CODEBUILD_SRC_DIR}/infra/CreateBrand/shell/CreateBrand.sh ${EnvCode} ${StoreCode} ${ResourceGroup} ${Database} ${ACCOUNT_ID} ${Brand}
        sleep 15
    done < ${CODEBUILD_SRC_DIR}/infra/CreateBrand/list/brand.list
elif [ $ForkFlg = "one" ]; then
    echo 'One Brand Create ('${Brand}')'
    /bin/bash ${CODEBUILD_SRC_DIR}/infra/CreateBrand/shell/CreateBrand.sh ${EnvCode} ${StoreCode} ${ResourceGroup} ${Database} ${ACCOUNT_ID} ${Brand}
else
    echo '### ForkFlgは「all」か「one」を指定してください ###'
    echo '## 「one」を指定した場合は、brandに作成対象のブランド名を1つだけ入力してください ##'
    exit 1
fi

exit 0