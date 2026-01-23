# Language

- Japanese

## Outputs

- Markdown

## Search files

- grepではなく、高速なのでrgを使用して

## job-medley-env リポジトリでterraformを実行する場合の注意点

- terraform applyは実行してはならない
- terraform planの実行の際、下記に記述するディレクトリ以外は下記のdocker execを使ってterraform planを実行すること
  - job-medley-env/terraform/jm-sandbox 配下はdocker execを使わずに terraform plan を実行すること


