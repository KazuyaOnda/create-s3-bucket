## CreateBucket

加盟店コード毎にS3 Bucketを作成

### codebuild

| ファイル名    | 用途                                       | 備考 |
| :-----------: | :---------------------------------------: | :--: |
| buildspec.yml | CodeBuildのビルド時に実行するシェルコマンド |      |

以下の処理を実行

- buildspec.yml
  - AWSのアカウントIDの取得(整形)
  - CreateBucket.shの実行(引数も指定)

### shell

| ファイル名      | 用途                                        | 備考              |
| :-------------: | :----------------------------------------: | :----------------: |
| CreateBucket.sh | S3 Bucket作成とその他Brand以外のリソース作成 | 処理内容は下記参照 |

以下の処理を実行

- CreateBucket.sh
  - CloudFormationにてS3 Bucketおよびupload/のCSVファイルを参照するTableを作成
  - AWS CLIにてLambda Functionに作成したS3 BucketのPermissionを追加
  - AWS CLIにて作成したS3バケットにBrand関連以外のNull Keyを追加
  - AWS CLIにて作成したS3バケットからErrorCheckFunctionへのNotificationを追加
  - 最初に作成したCloudFormationのStackを削除

※CloudFormationを利用するが、構成管理は行わないのでリソース作成後にStackを削除する

### yaml

| ファイル名       | 用途                                                        | 備考 |
| :--------------: | :---------------------------------------------------------: | :--: |
| CreateBucket.yml | CreateBucket.shで作成するCloudFormationのStackのテンプレート |      |

以下のリソースを定義

- CreateBucket.yml
  - S3 Bucket
  - upload/のCSVファイルを参照するTable

#### add-test-20200219