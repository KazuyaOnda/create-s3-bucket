#!/bin/sh
## GetCode
EnvCode=$1
StoreCode=$2
ResourceGroup=$3
Database=$4
ACCOUNT_ID=$5
ForkFlg=$6
Brand=$7

## Get S3 notification-configuration
echo '_/_/_/ Check Brand Fork (AllBrand or OneBrand) _/_/_/'
if [ $ForkFlg = "all" ]; then
    while read Brand
    do
        /bin/bash ${CODEBUILD_SRC_DIR}/infra/CreateBrand/shell/CreateBrand.sh ${EnvCode} ${StoreCode} ${ResourceGroup} ${Database} ${ACCOUNT_ID} ${Brand}
        sleep 15
    done < ${CODEBUILD_SRC_DIR}/infra/CreateBrand/list/brand.list
elif [ $ForkFlg = "one" ]; then
    /bin/bash ${CODEBUILD_SRC_DIR}/infra/CreateBrand/shell/CreateBrand.sh ${EnvCode} ${StoreCode} ${ResourceGroup} ${Database} ${ACCOUNT_ID} ${Brand}
else
    echo '### ForkFlgは「all」か「one」を指定してください ###'
fi
