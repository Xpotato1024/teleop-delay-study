# 開発・検証手順

## 1. 検証済み環境

bootstrapはMATLAB R2025b Update 5で検証した。後続PRでは実際に使用したversionを報告する。必要性と利用可能性を文書化するまで、特定Toolboxを必須としない。

## 2. Entry point

リポジトリルートから実行する。

```powershell
matlab -batch "status=run_project(); assert(status==0)"
```

smoke test:

```powershell
matlab -batch "addpath('tests'); c=onCleanup(@() rmpath('tests')); status=smoke_test(); assert(status==0)"
```

対話実行の場合:

```matlab
status = run_project();
assert(status == 0);
```

```matlab
addpath("tests");
cleanup = onCleanup(@() rmpath("tests"));
status = smoke_test();
assert(status == 0);
```

entry pointはMATLAB pathを元の状態へ復元する。テストは、過去の実行が残した状態に依存してはならない。

## 3. BranchとPRの運用

- 更新済み`main`から開始する。
- 一つの作業単位につき一つのbranchを作成する。
- 実際のbacklogを記録する必要がない限りIssueを増やさない。
- 実装または検証が未完了の間はPRをdraftに保つ。
- Codexからmergeしない。
- 人間によるreviewでReady化とmergeを判断する。

各PRで次を同期する。

1. 実装
2. テスト
3. `research/log.md`
4. `docs/reports/`以下の実装報告
5. 影響する設計または開発文書

## 4. 実装順序

1. 決定論的軌道の契約とgenerator
2. 送信sampling、packet遅延、ZOH、CV再構成
3. plantモデルと数値積分
4. 参照系と評価指標
5. 決定論的な完全要因実験
6. 任意の乱数軌道と感度解析
7. 最終レポート生成

## 5. MATLAB実装方針

汎用MATLAB作業の正本は`skills/matlab-engineering/SKILL.md`、本研究固有の正本は`skills/teleop-delay-matlab/SKILL.md`である。将来上流MathWorks Skillを検討する場合も、別資産として出典と再配布条件を検証し、研究固有契約を優先する。

中心方針:

- base workspace scriptではなく関数を用いる。
- 設定とunitを明示する。
- 時系列配列を`N x 2`で統一する。
- 不正入力を早期に拒否する。
- 結果生成を決定論的にする。
- 隠れたToolbox依存を作らない。
- warningまたはerrorを全体で抑制しない。

## 6. Skill routingと継続改善

MATLAB作業では次の順に読む。

1. `skills/matlab-engineering/SKILL.md`
2. `skills/teleop-delay-matlab/SKILL.md`
3. `docs/architecture.md`
4. 対象コードとテスト

失敗、検証済みコマンド、反復手順が他のMATLABプロジェクトにも一般化できる場合は、同じPRで`matlab-engineering`を更新してよい。通信遅延研究固有の規則は`teleop-delay-matlab`へ、単発の詳細はコードコメントまたはPR報告へ、研究判断は`research/log.md`へ記録する。汎用Skill変更の根拠と検証結果は`skills/matlab-engineering/CHANGELOG.md`へ追記する。単発の局所問題を一般化せず、重複規則を増やさず、Skillを簡潔に保つ。

通常のDevkit利用では、tree、encoding、inspect/edit/verify、Git draft、文書、metrics、project bootstrap CLIのうち、タスクに対応するfirst-party Skillだけを読む。`devkit-release-maintainer`は通常routingに含めない。対象がDevkit source checkoutで、`.github/workflows/release.yml`、`rust/crates/devkit-cli`、`rust/crates/devkit-installer`が存在し、Devkit本体のrelease保守を明示的に依頼された場合だけ使用する。`teleop-delay-study`のreleaseには使用しない。`devkit-project-bootstrap`のPython同期scriptもDevkit本体向けfallbackであり、本リポジトリではDevkit CLIを優先する。

## 7. 検証水準

### 文書のみのPR

- 相対リンクを確認する。
- `research/problem_statement.md`と用語を一致させる。
- 記載コマンドを実ファイルと照合する。
- 人間向け文書が日本語であることを確認する。
- `git diff --check`を実行する。

### Entry point・設定PR

- `run_project`を実行する。
- `smoke_test`を実行する。
- status `0`を確認する。
- 実行前後のMATLAB pathを比較する。
- 不正設定が拒否されることを確認する。

### 科学関数PR

- 変更に集中したunit testを追加する。
- 手計算または解析可能なfixtureを含める。
- 境界と不正入力をテストする。
- 出力が有限で想定shapeであることを確認する。
- smoke testとentry pointを実行する。

### 数値モデルPR

上記に加えて、

- 可能な範囲で解析解と比較する。
- 積分刻みを半減し、評価指標の変化を定量化する。
- NaNとInfを拒否する。
- solver、時間刻み、収束thresholdを記録する。

### 実験PR

- cleanな出力directoryを使用する。
- 結果と設定を一緒に保存する。
- 同じ軌道に対して方式を対応付けて実行する。
- 予定case数を確認する。
- 保存結果から図を生成する。
- 実行時間と失敗caseを報告する。

## 8. 結果と図

`results/`には中間データ、run manifest、診断値、表を保存する。placeholder以外は通常Git追跡しない。

`report/figures/`には最終レポートで使用する図を保存し、Git追跡する。commitする図には再生成コマンドとsource result/configを対応付ける。

plot値を手作業で変更したり、生成図を見た目だけ似た別ファイルに置換したりしない。

## 9. 研究ログ

次が変わった場合は、日付付きで追記する。

- 研究質問または仮説
- 信号または評価指標の定義
- defaultまたはsweep parameter
- 初期化または評価区間
- solverまたは収束threshold
- scopeまたは優先度
- 結果の解釈

過去entryを後から書き換えない。

## 10. 失敗時の処理

コマンドが失敗した場合:

1. 正確なコマンドと必要な出力を保持する。
2. 環境、契約、実装、データのどこで失敗したか分類する。
3. 成功として報告しない。
4. 最小の修正を行う。
5. 失敗したcheckと関連regression checkを再実行する。
6. 未解決の失敗をPRへ記録する。

## 11. 移植資産

ローカル移植ファイルをstageする前に`docs/migrated-assets-policy.md`へ従う。監査結果は`docs/reports/migrated-assets-audit.md`へ記録する。

上流Skillと本研究固有の説明を混在させない。

## 12. Issue #2基盤の検証

MATLAB R2025b Update 5で、リポジトリルートから次を実行する。

```powershell
matlab -batch "addpath('src'); c=teleopdelay.config.default_config(); p=teleopdelay.simulink.model_paths(pwd); teleopdelay.simulink.build_models(p,c)"
matlab -batch "status=run_project(); assert(status==0)"
matlab -batch "addpath('tests'); c=onCleanup(@() rmpath('tests')); status=smoke_test(); assert(status==0)"
matlab -batch "addpath('src'); results=runtests('tests/unit'); assertSuccess(results)"
matlab -batch "addpath('src'); results=runtests('tests/models'); assertSuccess(results)"
matlab -batch "addpath('src'); results=runtests('tests/integration'); assertSuccess(results)"
matlab -batch "files=dir(fullfile('src','+teleopdelay','**','*.m')); for k=1:numel(files); checkcode(fullfile(files(k).folder,files(k).name),'-id'); end"
git diff --check
```

先頭のbuilder commandだけが追跡済み`.slx`を更新する明示的なmodel保守操作である。通常の`run_project`、`smoke_test`、各testはmodelを再生成・保存しない。modelがない場合、runtimeは`teleopDelay:MissingModel`を返す。builder実行後に`.slx`が更新された場合だけGit差分が生じる。`*.slxc`、`slprj/`、`*.slx.bak`は中間生成物または退避ファイルとして追跡しない。

`run_project`は`src/`だけを一時的にMATLAB pathへ追加し、呼出元のpathを復元する。出力は`config`、`trajectory`、`simulation`を持ち、simulationは`time_s`、`command_xy_m`、`position_xy_m`を持つ。`time_constant_s`は`SimulationInput.setVariable(...,Workspace='teleop_delay_system')`でmodel argumentへ渡し、base workspaceへassignしない。

解析testでは、circleと1:2 Lissajousの解析位置・速度・加速度、plantの定値入力解析解、solver step半減を検証する。解析差分の許容値は、軌道の有限差分誤差に対してcircle `1e-7`、Lissajous速度 `2e-7`・加速度 `5e-7`、plant解析解に対して`1e-5`とした。plantの実測最大誤差とstep半減結果はPR実装報告に記録する。
