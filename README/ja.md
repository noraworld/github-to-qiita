# GitHub-to-Qiita
| [English](/README/en.md) | **日本語** |

GitHub-to-Qiita を使用すると、Qiita の記事を GitHub リポジトリに統合できます。GitHub-to-Qiita を設定し、記事を GitHub リポジトリにプッシュすると、記事は自動的に [Qiita](https://qiita.com) に公開されます。

執筆作業を効率化して時間を節約しましょう! 😉



## セットアップ
セットアップは簡単です。以下の手順に沿ってワークフローを設定します。

### Qiita アクセストークンの生成
[Qiita のアクセストークン生成ページ](https://qiita.com/settings/tokens/new) にアクセスします。

![](/screenshots/generate_qiita_access_token.png)

以下の情報を入力し、トークン生成ボタンをクリックします。

| キー | 説明 | 固定値かどうか | サンプル値または固定値 |
| --- | --- | --- | --- |
| Description | そのアクセストークンの使用用途をあとで把握しやすいように説明を入力します | false | `GitHub to Qiita` |
| Scopes | アクセストークンの権限を指定します | true | `read_qiita` and `write_qiita` |

アクセストークンを生成すると画面に表示されるのでコピーしておきます。

![](/screenshots/qiita_access_token.png)

アクセストークンは一度しか表示されません。わからなくなった場合は再生成してください。

**WARNING:** 上記のスクリーンショットにあるアクセストークンはダミーの値です。アクセストークンを含むスクリーンショットを撮ったりアクセストークンを他の人に教えたりしないでください。

### Qiita アクセストークンをリポジトリに設定
リポジトリのシークレット作成ページにアクセスします。`https://github.com/<USERNAME>/<REPONAME>/settings/secrets/actions/new` という URL でアクセスできます。

![](/screenshots/actions_secrets.png)

以下の情報を入力し、`Add secret` ボタンをクリックします。

| キー | 説明 | サンプル値 |
| --- | --- | --- |
| Name  | Qiita アクセストークンを格納するための名前を入力します | `QIITA_ACCESS_TOKEN` |
| Value | Qiita アクセストークンを入力します | `7ace9cfa98815ed3d5cd1e1bba8e745c152e9071` (これはサンプル値です!!) |

### ワークフローファイルの作成
ファイル名を `.github/workflows/qiita.yml` としてファイルを作成し、ワークフローを設定します。

以下は例です。

```yaml
# .github/workflows/qiita.yml

name: "GitHub to Qiita"

on:
  push:
    branches: [ main ]

jobs:
  qiita:
    runs-on: ubuntu-latest
    steps:
      - name: "Publish to Qiita"
        uses: noraworld/github-to-qiita@v1.0.0
        with:
          dir: "articles"
          qiita_access_token: ${{ secrets.QIITA_ACCESS_TOKEN }}
          mapping_filepath: "mapping.txt"
          strict: false
```

上記の YAML コードの一部を以下の情報に置き換えます。

| キー | 説明 | 必須かどうか | サンプル値またはデフォルト値 |
| --- | --- | --- | --- |
| `jobs.qiita.steps[*].with.dir` | Qiita に投稿したい記事が格納されているディレクトリを指定します | true | `articles` |
| `jobs.qiita.steps[*].with.qiita_access_token` | Qiita アクセストークンを指定します (`${{ secrets.QIITA_ACCESS_TOKEN }}` で参照できます [^1]) | true | `${{ secrets.QIITA_ACCESS_TOKEN }}` |
| `jobs.qiita.steps[*].with.mapping_filepath` | マッピングファイルのパスを指定します | false | `mapping.txt` |
| `jobs.qiita.steps[*].with.strict` | 厳密チェックモードをオンにするかオフにするかを指定します | false | `false` |

[^1]: 一つ前の手順でリポジトリに設定した環境変数名が `QIITA_ACCESS_TOKEN` である場合のみ。

**WARNING:** 最新版のコードはバグを含んでいたり仕様が頻繁に変わったりする可能性があるため、`jobs.qiita.steps[*].uses` でバージョンを `@main` に設定しないでください。最新のタグのバージョンを指定することをおすすめします。タグ一覧は [Tags](/../../tags) からアクセスできます。

#### 厳密チェックモードについて
厳密チェックモードは Qiita 上に記事が見つからない、かつ、リポジトリ上の記事ファイルが追加ではなく更新された場合に、Qiita に該当記事を投稿するかどうかを指定します。厳密チェックモードがオン (`jobs.qiita.steps[*].with.strict` が `true` に設定されている) の場合、マッピングファイルが不完全なために該当する Qiita の記事が見つからず、記事ファイルが更新された場合には Qiita に投稿されません。厳密チェックモードがオフの場合は Qiita に投稿されます。

厳密チェックモードをオフにすると、Qiita に該当記事が存在していても、マッピング情報が不完全であるために、新しい記事として Qiita に投稿されてしまう可能性があります。そのため、マッピング情報が不完全な場合は厳密チェックモードをオンにすることをおすすめします。ただし、新しい記事ファイルをプッシュした際に何らかの理由で Qiita への投稿が失敗した場合に、手動で Qiita に投稿しない限りはその記事が投稿されることがない点にご注意ください。この問題を回避したい場合は `jobs.qiita.steps[*].with.strict` を `false` に設定することをご検討ください。

---

設定はこれで以上となります。



## 記述ルール
記事の Markdown ファイルには以下のような YAML ヘッダをつける必要があります。

```yaml
---
title: "Your awesome title"
topics: ["GitHub Actions", "Ruby", "YAML"]
published: true
---

Your article starts here.
```

| キー | 説明 | 型 | 制約 |
| --- | --- | --- | --- |
| `title` | 記事のタイトルを指定します | 文字列 | |
| `topics` | 記事のタグを指定します | 配列[文字列, <文字列, 文字列, ...>] | タグの数は 1 〜 5 個まで |
| `published` | 一般公開するか限定共有にするかを指定します | 真偽値 | |

記事のファイルは `---` から始める必要があります。

追加のキーや値を含めることができます。これらは単純に無視されます。



## 動作方法
特定のディレクトリ内 (上記のワークフローの例でいう `articles` ディレクトリ) の記事を特定のブランチ (上記のワークフローの例でいう `main` ブランチ) にプッシュすると、自動的に動作します。追加の操作は必要ありません。

ワークフローが正常に動作したかどうかは `https://github.com/<USERNAME>/<REPONAME>/actions/workflows/qiita.yml` で確認できます。



## 開発に参加する方法
ローカル開発用のファイルやディレクトリは以下のとおりです。

* `.env`
* `mapping.txt`
* `articles/`

上記のファイルやディレクトリは Git で無視される (`.gitignore` に記載されている) ため、動作確認用にデータを入れて使用することができます。

**WARNING:** `articles` ディレクトリ内の記事の YAML ヘッダの `published` は常に `false` に設定しておいてください。`true` に設定すると、開発用のテスト記事が一般公開されてしまいます。

```yaml
---
title: "Test"
topics: ["Foo", "Bar", "Baz"]
published: false # <= 重要!!!
---

This is a test article.
```

### 環境変数
ローカル開発のデバッグ用に以下の環境変数を設定する必要があります。`.env` ファイルは開発環境でのみロードされます。

以下は `.env` ファイルの例です。

```ruby
ADDED_FILES="articles/test01.md"
MODIFIED_FILES="articles/test02.md"
MAPPING_FILEPATH="mapping.txt"
QIITA_ACCESS_TOKEN="7f6c7aec310ded84ae3acfe8f920cb1c7556c7d3" # これはサンプル値です!!
STRICT="true"
```

| 環境変数名 | 説明 | 必須かどうか |
| --- | --- | --- |
| `ADDED_FILES` | 新しく投稿される記事のパス | false |
| `MODIFIED_FILES` | 編集される記事のパス | false |
| `MAPPING_FILEPATH` | マッピング情報を格納するファイルのパス | true |
| `QIITA_ACCESS_TOKEN` | Qiita アクセストークン (開発用) | true |
| `STRICT` | 厳密チェックモードをオンにするかどうか ([厳密チェックモードについて](#厳密チェックモードについて) を参照) | true |

**NOTE:** 本番用とは異なる Qiita アクセストークンを使用することをおすすめします。

`ADDED_FILES` または `MODIFIED_FILES` のいずれかを省略することができますが、両方とも省略した場合は何も実行されません。



## お知らせ
古い実装は [noraworld/github-to-qiita-server](https://github.com/noraworld/github-to-qiita-server) に移動し、メンテナンスされなくなりました。



## ライセンス
本リポジトリ内のすべてのコードは MIT ライセンスに基づき利用することができます。詳細は [LICENSE](/LICENSE) をご覧ください。
