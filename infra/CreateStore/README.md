## CreateStore

- 以下の処理を実施

### codebuild

| ファイル名    | 用途                                       | 備考 |
| :-----------: | :---------------------------------------: | :--: |
| buildspec.yml | CodeBuildのビルド時に実行するシェルコマンド |      |

以下の処理を実行

- buildspec.yml
  - AWSのアカウントIDの取得(整形)
  - CreateStore.shの実行(引数も指定)

### shell

| ファイル名      | 用途                                        | 備考              |
| :-------------: | :----------------------------------------: | :----------------: |
| CreateStore.sh | S3 Bucket作成とその他Brand以外のリソース作成 | 処理内容は下記参照 |

以下の処理を実行

- CreateStore.sh
  - CloudFormationで以下のリソースを作成
    - 加盟店コード毎にS3 Bucketを作成
    - 作成したS3 Bucketの「upload/」を参照するテーブルを作成
  - 以下の3つのLambda Functionに対してPermissionを追加
    - ErrorCheckFunction
    - CreateDiffFunction
    - CreateAllFunction
  - ブランド関連以外のNull Keyを作成
  - ErrorCheckFunctionへのNotificationを追加 (実際にはS3 Bucket側に設定を追加)
    - Prefix : upload/
    - Suffix : upload.csv
  - 最初に作成したCloudFormationのStackを削除

※CloudFormationを利用するが、構成管理は行わないのでリソース作成後にStackを削除する処理も実施

### yaml

| ファイル名      | 用途                                                       | 備考 |
| :-------------: | :--------------------------------------------------------: | :--: |
| CreateStore.yml | CreateStore.shで作成するCloudFormationのStackのテンプレート |      |

以下のリソースを定義

- CreateStore.yml
  - S3 Bucket
  - upload/のCSVファイルを参照するTable
