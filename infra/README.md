## SMAP インフラ環境 自動化用スクリプト

インフラ環境として、今後追加が想定される以下のリソースを作成・編集する

- S3 Bucket (Bucket作成、Null Key追加、Notification Configurationの追加)
- Glue Table (Athenaで利用)
- Lambda Function (Permissionの追加)

### CreateStore

加盟店コード毎に以下を作成する

- S3 Bucket作成
- 「upload/」を参照するGlue Table作成
- Lambda Permission追加
- 「upload/」のS3 -> LambdaへのNotification追加

### CreateBrand

各ブランド毎に以下を作成する

- 各ブランドの「temp」「diff」「All」を参照するGlue Tableの作成
- S3 Bucketに各ブランドのNull Keyを作成
- 各ブランドの「temp」「diff」のS3 -> LambdaへのNotification追加
