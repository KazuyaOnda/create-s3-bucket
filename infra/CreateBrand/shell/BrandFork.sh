#!/bin/sh
## GetCode
ForkFlg=$1
EnvCode=$2
StoreCode=$3
ResourceGroup=$4
Database=$5
Brand=$6

ACCOUNT_ID=`aws sts get-caller-identity --query 'Account' --output text`

## Check Brand Fork And Argment
echo '_/_/_/ Check Brand Fork (AllBrand or OneBrand) _/_/_/'
if [ $ForkFlg = "all" ]; then
  if [ $# -lt 5 ]; then
    echo "*-*-*-*-*-*-*-*-*- エラー！！ -*-*-*-*-*-*-*-*-*"
    echo "## 引数が不足しています。環境変数を確認してください。 ##"
    exit 1
  else
    while read Brand
    do
      echo 'All Brand Create'
      /bin/bash ${CODEBUILD_SRC_DIR}/infra/CreateBrand/shell/CreateBrand.sh ${EnvCode} ${StoreCode} ${ResourceGroup} ${Database} ${ACCOUNT_ID} ${Brand}
      sleep 15
    done < ${CODEBUILD_SRC_DIR}/infra/CreateBrand/list/brand.list
  fi
elif [ $ForkFlg = "one" ]; then
  if [ -z $Brand ]; then
    echo "*-*-*-*-*-*-*-*-*- エラー！！ -*-*-*-*-*-*-*-*-*"
    echo "## 環境変数の「Brand」に値が入力されていないエラーです ##"
    echo "## ForkFlgで「one」を指定した場合は、Brandに作成対象のブランド名を1つだけ入力してください ##"
    exit 1
  elif [ $# -lt 6 ]; then
    echo "*-*-*-*-*-*-*-*-*- エラー！！ -*-*-*-*-*-*-*-*-*"
    echo "## 引数が不足しています。環境変数を確認してください。 ##"
    echo "## ForkFlgで「one」を指定した場合は、Brandに作成対象のブランド名を1つだけ入力してください ##"
    exit 1
  else
    echo '_/_/_/ One Brand Create ('${Brand}') _/_/_/'
    /bin/bash ${CODEBUILD_SRC_DIR}/infra/CreateBrand/shell/CreateBrand.sh ${EnvCode} ${StoreCode} ${ResourceGroup} ${Database} ${ACCOUNT_ID} ${Brand}
  fi
else
  echo "*-*-*-*-*-*-*-*-*- エラー！！ -*-*-*-*-*-*-*-*-*"
  echo '### ForkFlgは「all」か「one」を指定してください ###'
  echo '## 「one」を指定した場合は、Brandに作成対象のブランド名を1つだけ入力してください ##'
  echo '## ForkFlgを正しく指定している場合は、他の環境変数が問題なく入力されていることを確認してください ##'
  exit 1
fi

exit 0