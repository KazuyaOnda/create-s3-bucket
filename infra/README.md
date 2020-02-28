## SMAP インフラ環境 自動化用スクリプト

インフラ環境として、今後追加が想定される以下のリソースを作成・編集する

- S3 Bucket (Bucket作成、Null Key追加、Notification Configurationの追加)
- Glue Table (Athenaで利用)
- Lambda (Permissionの追加)

### CreateBucket

加盟店コード毎に以下を作成する

- S3 Bucket作成
- Glue Table作成
- Lambda Permission追加
- S3 -> LambdaへのNotification追加

### CreateBrand

各ブランド毎に以下を作成する

- Glue Tableの作成
- S3 BucketにNull Keyを作成

# Comment Test