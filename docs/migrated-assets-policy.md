# 移植資産ポリシー

## 目的

別プロジェクトからコピーされたローカル未追跡ファイルには、有用なtoolingだけでなく、古い前提、互換性のないpath、不明なlicense、秘密情報が含まれる可能性がある。監査が完了するまで信頼済み資産として扱わない。

## 監査結果の記録

監査結果は`docs/reports/migrated-assets-audit.md`へ記録し、各候補を次のいずれかに分類する。

- **Adopt** — 関連性、安全性、licenseを確認でき、実質的な変更なしで利用できる。
- **Adapt** — 関連性とlicenseは確認できるが、明示的なプロジェクト固有修正が必要である。
- **Defer** — 有用な可能性はあるが、出典、license、互換性、必要性のいずれかが未解決である。
- **Reject** — 無関係、重複、不安全、非互換、または再配布不可である。

明示的な指示なしにDeferまたはRejectしたローカルファイルを削除しない。

## 必須確認項目

各候補について次を確認する。

1. 正確なpathとfile type
2. 目的と想定利用者
3. source URLまたはrepository
4. source revision、tag、release
5. LICENSEとNOTICEの要件
6. upstreamを特定できる場合の差分
7. secret、token、private URL、個人識別情報、絶対path
8. 別repository、command、Skill、directoryへの参照
9. 実行commandとローカル環境での対応状況
10. tracked fileとの重複
11. 1週間の研究で直ちに利用する価値

これらを記録する前にstageしない。

## MathWorks等の上流MATLAB Skill

ローカルにコピーされたMATLAB Skillが公式資産に見えても、記憶やcopyright表記だけで公式版と断定しない。

出典と再配布条件を確認できた場合:

- 可能な範囲でupstream構造を維持する。
- 必要な`LICENSE`、`NOTICE`、attributionを保持する。
- source、revision、import日、local modification、licenseを記録した`UPSTREAM.md`を追加する。
- upstream fileを原則として改変しない。
- 上流の一般MATLAB guidanceと研究固有規則を分離する。
- 研究固有規則は`skills/teleop-delay-matlab/SKILL.md`へ置く。

出典または再配布条件を確認できない場合:

- 公式版と主張しない。
- commitしない。
- `Defer`とする。
- 研究固有Skillを独立して維持する。

現在の汎用MATLAB作業規則は内製の`skills/matlab-engineering/`であり、未検証の上流packageを通常routingへ含めない。

## `devkit.toml`

採用前に次を確認する。

- 対応するtoolとschema
- toolがローカルに存在すること
- 実際のhelpまたは公式文書
- 全commandとpath
- 別プロジェクト固有参照の有無
- 本リポジトリでの具体的な価値

Toolまたはschemaを確認できない場合は`Defer`とする。

## First-party Devkit Skills

ユーザーが作成した`skills/devkit-*`は第三者移植物ではなくfirst-party資産である。stage前に、secret、個人path、cross-project参照、導入済みDevkit versionとのcommand互換性、scriptの副作用を確認する。安全性または互換性の修正が必要な場合を除き、構造と内容を維持し、修正理由を監査報告へ記録する。

Devkit CLIの通常利用とDevkit本体source保守を区別する。source保守用Skillやscriptは、必要なsource markerと明示的依頼がある場合だけ使用する。

## 参照専用のローカルSkill

参照後の整理をユーザーが明示的に依頼した場合、Rejectまたはreference-onlyとしたSkill群は削除せず、指定されたリポジトリ外archiveへ移動する。移動前後のinventoryとhashを照合し、archive内にSHA-256 manifestを作成する。archiveとmanifestを本リポジトリへstageしない。

## Stage規則

監査後:

- Adoptと承認済みAdaptだけをstageする。
- 残る未追跡ファイルを明示する。
- `git diff --cached --name-status`を確認する。
- broad stagingで候補が誤って追加されていないことを確認する。

## 公開repositoryの規則

移植資産に次を含めてはならない。

- credentialまたはtoken
- private URL
- 個人filesystem path
- 非公開研究データ
- 再配布許可のない第三者資産