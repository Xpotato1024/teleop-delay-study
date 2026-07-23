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

`run_project`は`src/`だけを一時的にMATLAB pathへ追加し、呼出元のpathを復元する。出力は`config`、`trajectory`、`simulation`、`evaluation`を持ち、simulationは`time_s`、ZOH/CV/referenceのcommand・plant position、packet timestamp・age・validityを持つ。`time_constant_s`、`sample_period_s`、`delay_s`は`SimulationInput.setVariable(...,Workspace='teleop_delay_system')`でcase単位に渡し、base workspaceへassignしない。

## 12. Issue #7 focused検証

reference/evaluation/metricsの変更では、次の順で実行する。

```powershell
matlab -batch "addpath('src'); c=teleopdelay.config.default_config(); p=teleopdelay.simulink.model_paths(pwd); teleopdelay.simulink.build_models(p,c)"
matlab -batch "addpath('src'); results=runtests('tests/unit/test_metrics.m'); assertSuccess(results)"
matlab -batch "addpath('src'); results=runtests('tests/unit/test_logged_time_alignment.m'); assertSuccess(results)"
matlab -batch "addpath('src'); results=runtests('tests/models/test_reference_plant.m'); assertSuccess(results)"
```

`test_reference_plant`のzero-delay fixtureは、`sample_period=fixed_step`かつ`delay=0`でZOH/CV commandが同一時刻の連続目標sampleに一致すること、reference plantが円軌道の一次遅れ解析解へsolver tolerance内で一致すること、ZOH/CV/referenceのplant出力関係を確認する。referenceの解析解誤差、solver-stage packet reconstructionとの誤差は実行時に測定して報告する。

Issue #7後の公開simulation schemaは、`time_s`、5つの`N x 2` position/command signal、3つのpacket diagnostics、`solver`、`fixed_step_s`である。Datasetは8つの名前付きelementを完全一致で検証し、Dataset順序には依存しない。`run_project`後の`output.evaluation`はnominal/sample境界とmetricsを持つ。
評価mask内のpacket validityはfail-closedであり、全件validだけをmetricsへ渡す。全件invalidは`teleopDelay:NoValidPacketInEvaluation`、混在は`teleopDelay:IncompletePacketHistoryInEvaluation`、負の評価packet ageは`teleopDelay:InvalidPacketAgeInEvaluation`で拒否する。8要素の`Values.Time`は`teleopdelay.simulink.validate_logged_time_alignment`でcanonical vectorとの一致を確認する。

### 通信Model Referenceのbuilderと検証

追跡済みmodelを再生成する明示的commandは次である。

```text
matlab -batch "addpath('src'); c=teleopdelay.config.default_config(); p=teleopdelay.simulink.model_paths(pwd); teleopdelay.simulink.build_models(p,c)"
```

生成されるmodelは`models/communication/sampled_communication.slx`、`models/plant/first_order_2d.slx`、`models/system/teleop_delay_system.slx`である。focused通信検証は`matlab -batch "addpath('src'); results=runtests('tests/models/test_sampled_communication.m')"`で実行する。runtimeの`run_project`、test、smokeはmodelを再生成・保存しない。

解析testでは、circleと1:2 Lissajousの解析位置・速度・加速度、plantの定値入力解析解、solver step半減を検証する。解析差分の許容値は、軌道の有限差分誤差に対してcircle `1e-7`、Lissajous速度 `2e-7`・加速度 `5e-7`、plant解析解に対して`1e-5`とした。plantの実測最大誤差とstep半減結果はPR実装報告に記録する。
## Issue #8 focused/full test

focused testはrepository rootから次で実行します。

```powershell
matlab -batch "addpath('src'); results=runtests('tests/unit/test_experiment_manifest.m'); assertSuccess(results)"
matlab -batch "addpath('src'); results=runtests('tests/unit/test_experiment_aggregation_persistence.m'); assertSuccess(results)"
matlab -batch "addpath('src'); results=runtests('tests/integration/test_experiment_runner.m'); assertSuccess(results)"
```

既存を含むfull testは次です。

```powershell
matlab -batch "addpath('src'); results=runtests('tests/unit'); assertSuccess(results)"
matlab -batch "addpath('src'); results=runtests('tests/models'); assertSuccess(results)"
matlab -batch "addpath('src'); results=runtests('tests/integration'); assertSuccess(results)"
matlab -batch "addpath('tests'); c=onCleanup(@() rmpath('tests')); status=smoke_test(); assert(status==0)"
```

## Issue #8 標準実験の再現手順

cleanなMATLAB sessionでrepository rootを作業基準にし、次を単独で実行します。

```powershell
matlab -batch "result=run_standard_experiment(); assert(result.run_status==\"complete\")"
```

既定の保存先は `results/generated/<experiment_id>/<run_id>/` です。保存を一時directoryへ変更する場合は `run_standard_experiment('OutputRoot', fullfile(tempdir,'teleop-delay-study-results'))` を使います。`SaveResults=false` は成功時のcomplete artifactだけを抑制し、失敗時のdiagnostic CSV/MAT保存は抑制しません。

実行前後に `path`、`pwd`、`bdIsLoaded`、base workspaceのparameter名を確認し、model fileのSHA-256が変化していないことを確認します。標準実験のduration、評価境界、solver、fixed step、sampling周期はmanifestとMAT metadataで追跡します。

## 13. Issue #9 分析・図・収束検証

入力MATは自動探索せず、Issue #8のcomplete artifactを`InputMat`で明示します。SHA-256、40 rows、40 successful cases、標準delay/omega grid、case schema、時系列shape/time alignment、aggregateとcase metricsの一致をfail-closedに検証します。

focused analysis unit test:

```powershell
matlab -batch "results=runtests('tests/unit/issue9AnalysisTest.m'); assert(all([results.Passed]))"
```

保存済み結果からの通常再生成はsimulationを行わない次のcommandです。

```powershell
matlab -batch "result=run_issue9_analysis('InputMat','C:/absolute/path/to/issue8__results.mat','Mode','render-only'); assert(result.artifact.saved)"
```

初回の収束artifactを含む生成は次です。標準40 caseは再実行せず、代表caseのfixed-step半減だけを実行します。

```powershell
matlab -batch "result=run_issue9_analysis('InputMat','C:/absolute/path/to/issue8__results.mat','Mode','full'); assert(result.artifact.saved)"
```

Issue #9のartifactには8 figureのPNG/PDF、`case_classification`、`extreme_cases`、`nearest_boundary_cases`、`boundary_brackets`、`representative_cases`、`instantaneous_error_extremes`、`dimensionless_diagnostics`、`identifiability`、`convergence`、`figure_manifest`を保存します。分類許容幅はfull modeでは収束時の最大`|delta G|`に固定safety factorを掛け、render-onlyで収束artifactがない場合はmachine-precision-onlyとmetadataへ明記します。離散grid外の境界は実測結果として描画しません。

収束studyではsample period `0.020` sとrefined step `0.0025` sの整数alignment、solver、model hash、path、pwd、model close、base workspace非残留を確認します。図のbinary hashはrenderer環境に依存し得るため、manifestのfile existence、size、source case IDs、axes contract、CSV/MAT source dataを再現性の正本とします。

P1/P2のfocused確認は、row permutation、InputMat semantic negative fixture、収束artifact候補の空table・不整合・曖昧性・同一内容選択、relative delta、percentile設定、保存figure determinism、sidecar hash round-tripを含めて実行します。保存figure determinismは`SaveResults=false`の比較ではなく、同一input/configを2回保存し、figure ID、case ID、caption、axes contract、source table、PNG/PDF存在・非空を比較します。`artifact_manifest.csv`の各行は最終fileのsize・SHA-256を再計算して照合します。

```powershell
matlab -batch "addpath('src'); results=runtests('tests/unit/issue9AnalysisTest.m'); assert(all([results.Passed]))"
matlab -batch "result=run_issue9_analysis('InputMat','C:/absolute/path/to/issue8__results.mat','Mode','render-only'); assert(result.artifact.saved)"
matlab -batch "result=run_issue9_analysis('InputMat','C:/absolute/path/to/issue8__results.mat','Mode','full'); assert(result.artifact.saved)"
```
