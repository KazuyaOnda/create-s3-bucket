## CreateBrand

Brand毎に必要なリソースを作成

### codebuild

| ファイル名    | 用途                                       | 備考 |
| :-----------: | :---------------------------------------: | :--: |
| buildspec.yml | CodeBuildのビルド時に実行するシェルコマンド |      |

以下の処理を実行

- buildspec.yml
  - AWSのアカウントIDの取得(整形)
  - BrandFork.shの実行(引数も指定)

### list

| ファイル名 | 用途                                                 | 備考 |
| :--------: | :--------------------------------------------------: | :--: |
| brand.list | 一括で全Brandのリソースを作成する際の対象Brandのリスト |      |

- S3 Bucketを作成した際に、全Brandのリソースを作成する際の対象リスト
- ブランド(決裁事業者)が増えた場合はこのリストにブランド名(処理で使う名前)を追加する
- ループ処理の中でEOFまで実行する処理となっているので、最後のブランド名の後にも改行を入れておく
  - 最後の1行は空行にしておくこと！

### shell

| ファイル名     | 用途                                                               | 備考              |
| :------------: | :---------------------------------------------------------------: | :----------------: |
| BrandFork.sh   | 全てのBrandのリソースを作成するか1つのブランドを作成するかの条件分岐 | 処理内容は下記参照 |
| CreateBrand.sh | 1ブランドで必要なリソースを作成                                    | 処理内容は下記参照 |

以下の処理を実行

- BrandFork.sh
  - ForkFlgを参照して全ブランドか1つのブランドかを判断してCreateBrand.shを呼び出す
    - allの場合はlist/brand.listに記載されているbrand分CreateBrand.shを実行
    - oneの場合はBrandで指定されたbrandのみCraeteBrand.shを実行


- CreateBrand.sh
  - CloudFormationにてdiff/temp/allの3つのTableを作成
  - AWS CLIにて必要なBrand関連のNull keyを追加
  - AWS CLIにて以下のFunctionへのNotificationを追加
    - CreateDiffFunction
      - Prefix : brand/{ブランド名}/temp/
      - Suffix : .csv
    - CreateAllFunction
      - Prefix : brand/{ブランド名}/diff/diff_
      - Suffix : .csv
  - 最初に作成したCloudFormationのStackを削除

※CloudFormationを利用するが、構成管理は行わないのでリソース作成後にStackを削除する

### yaml

| ファイル名                 | 用途                                         | 備考                                         |
| :------------------------: | :-----------------------------------------: | :------------------------------------------: |
| CreateTable_aupay.yml      | aupayのTable作成用のテンプレートファイル      |                                              |
| CreateTable_dpayment.yml   | dpaymentのTable作成用のテンプレートファイル   |                                              |
| CreateTable_gift.yml       | giftのTable作成用のテンプレートファイル       |                                              |
| CreateTable_linepay.yml    | linepayのTable作成用のテンプレートファイル    |                                              |
| CreateTable_merpay.yml     | merpayのTable作成用のテンプレートファイル     |                                              |
| CreateTable_paypay.yml     | paypayのTable作成用のテンプレートファイル     |                                              |
| CreateTable_rakutenpay.yml | rakutenpayのTable作成用のテンプレートファイル |                                              |
| CreateTable_yuchopay.yml   | yuchopayのTable作成用のテンプレートファイル   |                                              |
| template_CreteTable.yml    | 新規payのTable作成用の元ファイル              | 新規Brand追加時にColumnの定義のみ修正する想定 |

以下のリソースを定義

- brand/{ブランド名}/diff/diff_{加盟店コード}_yyyymmddHHMMSS.csvファイルを参照するテーブル
- brand/{ブランド名}/tmep/AthenaのQueryID.csvファイルを参照するテーブル
- brand/{ブランド名}/all/all_{加盟店コード}_yyyymmddHHMMSS.csvファイルを参照するテーブル

#### 新規にブランド(決裁事業者)が増えた場合
- template_CreateTable.ymlをもとに「CreataTable_{ブランド名}.yml」を作成
- 新規ブランドのColumnに併せてColumnの定義を追記

※各ブランド毎にColumnの定義が変わる想定