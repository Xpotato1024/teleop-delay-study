# 遠隔操作遅延シミュレーション

遠隔位置指令系における通信遅延と定速度予測補償を扱うMATLABシミュレーション研究です。

## 研究質問

通信遅延、軌道速度、軌道形状の組合せによって、定速度予測はどの範囲で追従誤差を低減し、どこから効果を失う、または補償なしのゼロ次ホールドより悪化するのでしょうか。

定速度予測そのものを新規手法とは主張しません。本課題の中心は、再現可能な比較基盤を構築し、総追従誤差と通信遅延起因誤差を分離し、単一の成功例ではなく有効範囲と悪化境界を求めることです。

## 比較する系

1. 通信遅延なしのpacketized command
2. 通信遅延あり・ゼロ次ホールド（ZOH）
3. 通信遅延あり・定速度デッドレコニング（CV）

ロボット応答は各軸独立の一次遅れ系で表します。決定論的な中心軌道として円軌道とLissajous軌道を用い、P1では周期運動以外への頑健性を確認するため、通過点間を結ぶ最小ジャーク軌道を追加します。

## 現在の状態

現在は、MATLAB package、固定時間grid、円軌道と1:2 Lissajous軌道、独立した通信Model Reference、ZOH/CV指令再構成、並列した一次遅れplant、headless simulation、出力loggingまでを実装しています。評価指標、parameter sweep、実験、最終図は対象外です。

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
│   ├── +timegrid/
│   ├── +trajectory/
│   └── +simulink/
├── models/
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
補足: 評価指標、parameter sweep、実験、最終図は研究全体の対象外ではなく、現時点では未実装であり後続PRの対象です。
