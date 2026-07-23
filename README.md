# 遠隔操作遅延シミュレーション

遠隔位置指令系における通信遅延と定速度予測補償を扱うMATLABシミュレーション研究です。

## 研究質問

通信遅延、軌道速度、軌道形状の組合せによって、定速度予測はどの範囲で追従誤差を低減し、どこから効果を失う、または補償なしのゼロ次ホールドより悪化するのでしょうか。

定速度予測そのものを新規手法とは主張しません。本課題の中心は、再現可能な比較基盤を構築し、総追従誤差と通信遅延起因誤差を分離し、単一の成功例ではなく有効範囲と悪化境界を求めることです。

## 比較する系

1. 通信を通さない連続指令のreference plant
2. 通信遅延あり・ゼロ次ホールド（ZOH）
3. 通信遅延あり・定速度デッドレコニング（CV）

ロボット応答は各軸独立の一次遅れ系で表します。決定論的な中心軌道として円軌道と1:2 Lissajous軌道を用います。

## 現在の状態

現在は、MATLAB package、固定時間grid、円軌道と1:2 Lissajous軌道、独立した通信Model Reference、ZOH/CV指令再構成、ZOH/CV/referenceの3つの一次遅れplant、headless simulation、出力logging、評価window、追従誤差metrics、標準40 caseの保存、結果図・境界解析までを実装しています。

`run_project()`の公開outputは`config`、`trajectory`、`simulation`、`evaluation`です。`simulation`は次のschemaを持ちます。

```text
time_s                    N x 1 double [s]
zoh_command_xy_m          N x 2 double [m]
cv_command_xy_m           N x 2 double [m]
zoh_position_xy_m         N x 2 double [m]
cv_position_xy_m          N x 2 double [m]
reference_position_xy_m   N x 2 double [m]
packet_timestamp_s        N x 1 double [s]
packet_age_s              N x 1 double [s]
packet_valid              N x 1 logical
solver                    string scalar
fixed_step_s              scalar double [s]
```

既定評価は`total_cycles=10`、`warmup_cycles=2`である。nominal区間は`[2*period_s, 10*period_s]`、metricsに使うsampleはnominal start以上の最初からnominal end以下の最後までとし、nominal境界と実sample境界を`evaluation`へ記録します。
評価mask内のpacketは全sampleでvalidであることを要求し、valid/invalid混在は`teleopDelay:IncompletePacketHistoryInEvaluation`、全件invalidは`teleopDelay:NoValidPacketInEvaluation`で拒否します。`evaluation`は区間情報に加えてRMSE、NRMSE、最大誤差、性能比、改善率、mean packet age、4つの無次元量を持ちます。8つのlogged signalは全`Values.Time`の一致を検証してからschemaへ変換します。

## 必要環境

- bootstrap検証済み環境: MATLAB R2025b Update 5
- 後続PRで必要性を確認するまで、特定Toolboxへの依存を前提としない
- branch / PR運用のためのGit

## クイックスタート

リポジトリルートから実行します。

```matlab
status = run_project();
assert(status == 0);
```

smoke test:

```matlab
addpath("tests");
cleanup = onCleanup(@() rmpath("tests"));
status = smoke_test();
assert(status == 0);
```

非対話実行:

```powershell
matlab -batch "status=run_project(); assert(status==0)"
matlab -batch "addpath('tests'); c=onCleanup(@() rmpath('tests')); status=smoke_test(); assert(status==0)"
```

## リポジトリ構成

```text
.
├── AGENTS.md
├── CONTRIBUTING.md
├── run_project.m
├── src/+teleopdelay/
│   ├── +app/
│   ├── +config/
│   ├── +metrics/
│   ├── +timegrid/
│   ├── +trajectory/
│   └── +simulink/
├── models/
│   ├── communication/sampled_communication.slx
│   ├── plant/first_order_2d.slx
│   └── system/teleop_delay_system.slx
├── tests/
├── research/
│   ├── problem_statement.md
│   └── log.md
├── docs/
│   ├── architecture.md
│   ├── development.md
│   ├── roadmap.md
│   ├── migrated-assets-policy.md
│   └── reports/
├── skills/
│   ├── devkit-doc-edit/
│   ├── devkit-encoding-hygiene/
│   ├── devkit-git-drafts/
│   ├── devkit-inspect-edit-verify/
│   ├── devkit-metrics-review/
│   ├── devkit-project-bootstrap/
│   ├── devkit-release-maintainer/
│   ├── devkit-tree-explore/
│   ├── matlab-engineering/
│   └── teleop-delay-matlab/
├── results/
├── report/
│   ├── final_report.md
│   └── figures/
└── references/
```

## 再現性方針

- すべてのシミュレーション条件を設定データとして保持します。
- 乱数を使う条件ではseedを明示し、比較方式間で同じ軌道を再利用します。
- 結果、表、レポート用図はコードから再生成します。
- MATLAB version、実行コマンド、検証状態を記録します。
- 比較する方式では、同一の軌道実体と評価区間を使用します。

## 対象外

- 人を対象とした実験と主観的作業負荷
- 実ネットワーク計測
- packet loss、jitter、順序入替え
- 詳細な3Dロボット形状、IK、関節制限、接触、衝突、力覚
- 機械学習による予測

## 文書の読み方

最初に[`AGENTS.md`](AGENTS.md)を確認し、続いて[研究課題](research/problem_statement.md)と[設計・モデル契約](docs/architecture.md)を参照してください。

## ライセンス

[`LICENSE`](LICENSE)を参照してください。第三者資産を導入する場合、そのディレクトリに追加のLICENSEまたはNOTICEが含まれることがあります。

汎用MATLAB作業規則は、内製の`skills/matlab-engineering/`にあります。本研究固有の規則は`skills/teleop-delay-matlab/`にあります。検証済み上流MATLAB packageは現在追跡していません。

## Issue #8 標準40 case

標準実験は `circle` と `lissajous_1_2`、`dt = fixed step = 0.005 s`、sample period `0.020 s`、plant time constant `0.10 s`、delay `{0, 0.10, 0.20, 0.40, 0.50} s`、omega `{0.5, 1.0, 2.0, 4.0} rad/s`、total cycles `10`、warm-up cycles `2`、solver `ode4` の40 caseです。trajectory amplitudeは既存default configの値を使用します。

cleanなMATLAB sessionから次を実行します。

```matlab
result = run_standard_experiment();
```

生成物は `results/generated/<experiment_id>/<run_id>/` に保存されます。complete runはaggregate CSVと全case時系列を含むMATを持ち、CSV/MATのround-trip検証後に確定します。`results/generated/` は `.gitignore` 対象です。

## Issue #9 結果図とCV有効境界解析

Issue #8のcomplete MATを明示的な入力として指定します。既定の`render-only`は保存済み40 caseを再simulationせず、図・CSV・MAT tableを再生成します。

```matlab
inputMat = "C:/absolute/path/to/i8v1_n40_2353bb12__results.mat";
fullResult = run_issue9_analysis("InputMat", inputMat, "Mode", "full");
renderResult = run_issue9_analysis("InputMat", inputMat, "Mode", "render-only");
```

`full`は自動選定した代表caseだけをfixed-step `0.005` sから`0.0025` sへ半減して収束を確認した後、全図・全tableを生成します。`render-only`で保存済み収束artifactも使う場合は、必要に応じて`"ConvergenceMat", ".../analysis_tables.mat"`を明示できます。出力先は`results/generated/analysis/<experiment_id>/<analysis_id>/<analysis_run_id>/`で、PNG/PDF、analysis table CSV、`analysis_tables.mat`、metadata、figure manifestを含みます。生成物は`.gitignore`対象です。
