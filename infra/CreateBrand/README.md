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

- 全ブランドのリソースを作成する際の対象リスト
- ブランド(決裁事業者)が増えた場合はこのリストにブランド名(処理で使う名前)を追加する
- ループ処理の中でEOFまで実行する処理となっているので、最後のブランド名の後にも改行を入れておく
  - 最後の1行は空行にしておくこと！
- 以下の計算でCodeBuildの「SMAPCreateBrandのタイムアウト値を設定しているためブランドが増えた場合はタイムアウト値も検討する
  - 1ブランドあたりのリソース作成完了に約3分
  - 2020年2月の構築時点でブランドが8社
  - 3 × 8 ＝ 24分 ≒ 30分

※環境の変更を実施する際に「AWS CodeBuild にこのサービスロールの編集を許可し、ビルドプロジェクトでの使用を可能にする」のチェックを外すこと！

### shell

| ファイル名     | 用途                                                               | 備考              |
| :------------: | :---------------------------------------------------------------: | :----------------: |
| BrandFork.sh   | 全てのBrandのリソースを作成するか1つのブランドを作成するかの条件分岐 | 処理内容は下記参照 |
| CreateBrand.sh | 1ブランドで必要なリソースを作成                                    | 処理内容は下記参照 |

以下の処理を実行

- BrandFork.sh
  - 「ForkFlg」を参照して全ブランドか1つのブランドかを判断してCreateBrand.shを呼び出す
    - 「ForkFlg」についてはCodeBuildの環境変数で「all」か「one」を入力する
    - 「all」の場合は「list/brand.list」に記載されているブランド分「CreateBrand.sh」を実行
    - 「one」の場合は「Brand」で指定されたブランドのみ「CraeteBrand.sh」を実行
      - 「Brand」についてはCodeBuildの環境変数で対象のブランド名を入力する

- CreateBrand.sh
  - CloudFormationにて以下の3つのTableを作成
    - 「brand/{ブランド名}/temp/」を参照するTable
    - 「brand/{ブランド名}/diff/」を参照するTable
    - 「brand/{ブランド名}/all/」を参照するTable
  - AWS CLIにて必要なブランド関連のNull keyを追加
  - AWS CLIにて以下のLambda FunctionへのNotificationを追加
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

各YAMLにて以下のリソースを定義

- 「brand/{ブランド名}/diff/」を参照するテーブル
- 「brand/{ブランド名}/tmep/」を参照するテーブル
- 「brand/{ブランド名}/all/」を参照するテーブル

#### 新規にブランド(決裁事業者)が増えた場合
- template_CreateTable.ymlをもとに「CreataTable_{ブランド名}.yml」を作成
- 新規ブランドのColumnに併せてColumnの定義を追記
  - 各ブランド毎に連携するデータが変更となるのでColumnを修正する
  - その他のパラメータについては、特に変更不要
