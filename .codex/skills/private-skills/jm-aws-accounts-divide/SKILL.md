---
name: jm-aws-accounts-divide
description: AWSアカウント分割に関する前提情報。AWSアカウントの構成や分割について話すときに使う。
---

# AWSアカウント構成

## jm-production (050067577205)
- リージョン: ap-northeast-1
- 用途: プロダクション環境
- AWS Profile: jm-production, default
- 略称: jm-prd, 本番アカウント
- 備考: 現状本番環境以外にQA環境も稼働している。QA環境のサフィックスとして、qa,qa02,qa03, qa-stagingが稼働している。
- terraform:
  - 本番環境: ${HOME}/ghq/github.com/medley-inc/job-medley-env/terraform_production
  - 現行QA: ${HOME}/ghq/github.com/medley-inc/job-medley-env/terraform_qa
  - 共通設定: ${HOME}/ghq/github.com/medley-inc/job-medley-env/terraform_common
 


## jm-qa(261766102406)
- リージョン: ap-northeast-1
- 用途: 開発チーム共通の開発環境
- AWS Profile: jm-qa
- 備考: 現状QA環境を移行すべく、jm-productionのコピーであるqaをqa01としてjm-qaへ移植している。色々なURLもqa01に変更しながら実施している。qa01,qa02,qa03で共通で使う場合のsuffixはqaのままだが、qa01で使う場合はqa01というsuffixを付与している。
- terraform: ${HOME}/ghq/github.com/medley-inc/job-medley-env/terraform/jm-qa/

## jm-sandbox(207783039000)
- リージョン: ap-northeast-1
- 用途: 開発者の個人ごと開発環境（sandbox, サンドボックス）
- AWS Profile: jm-sandbox
- 略称: jm-sb
- terraform: ${HOME}/ghq/github.com/medley-inc/job-medley-env/terraform/jm-sandbox/

## 分割時の注意事項


### 前提
元々jm-productionですべてのAWS環境が管理されいました。
昨年、サンドボックス環境をjm-sanboxへ移行しました。マスキング処理などで一部残タスクはあるものの、jm-sandboxへの移行は完了しており、開発者の方々はjm-sandbox上で動くサンドボックスで開発を行っています。
現在SREチームでは特定のメンバーで、jm-productionからjm-qa移行を行っている。

移行中なので、jm-productionで稼働しているQA環境と、jm-qaで稼働しているQA環境を意識した作りにする必要がある。
