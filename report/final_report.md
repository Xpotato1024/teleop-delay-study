# 遠隔操作ロボットの通信遅延に対する定速度予測補償の有効範囲

<!-- 学年・組・番号・氏名は提出版で記入する。 -->

## 1. シミュレーションの目的

<!--
- 遠隔位置指令に通信遅延が生じる背景
- この対象を選んだ理由
- 定速度予測自体を新規技術とは主張しない
- 明らかにする有効範囲と悪化条件
- 人間入力を使わず再現可能な軌道を使う理由
-->

## 2. 遠隔位置指令系のモデル化

### 2.1 対象システムと入出力

入力は2次元連続目標位置と解析速度である。通信Model Referenceは固定sampling、固定遅延、最新packet選択を担当し、同じpacketからZOH/CV commandを生成する。top-level modelはZOH/CV/referenceの3つの`first_order_2d.slx`を呼び出し、referenceには連続目標位置を直接入力する。公開simulation schemaは8つの名前付きDataset elementと`time_s`、solver、fixed stepで構成する。

### 2.2 目標軌道

<!--
- 円軌道
- 1:2 Lissajous軌道
- 必要なら最小ジャーク通過点軌道
- 位置、速度、加速度の式
-->

### 2.3 通信遅延と指令再構成

送信時刻を\(t_k\)、遅延を\(L\)とし、\(t_k+L\leq t\)を満たす最新packetを用いる。ZOHは\(\mathbf r(t_k)\)、CVは\(\mathbf r(t_k)+(t-t_k)\dot{\mathbf r}(t_k)\)であり、外挿時間はpacket ageである。

### 2.4 ロボット応答モデル

各軸のplantは\(T\dot{\mathbf x}+\mathbf x=\mathbf u\)で表す。同じtracked model、初期状態zero、`time_constant_s` mappingをZOH/CV/referenceで共有し、詳細な運動学・接触・力覚は対象外とする。

### 2.5 評価指標

追従誤差のreferenceは連続目標そのものではなく、同じplantへ直接入力した`reference_position_xy_m`である。評価window内でRMSE、trajectory amplitudeによるNRMSE、最大Euclidean誤差、CV/ZOH RMSE比、改善率を計算する。RMSE、最大誤差、mean packet ageは同じ評価sample集合を使用し、評価mask内のpacketは全件validでなければならない。全件invalidは`teleopDelay:NoValidPacketInEvaluation`、valid/invalid混在は`teleopDelay:IncompletePacketHistoryInEvaluation`、負の評価packet ageは`teleopDelay:InvalidPacketAgeInEvaluation`で拒否する。4つの無次元量\(\omega L\)、\(\omega\overline{age}\)、\(\omega T\)、\(\omega h_s\)を公開する。loggingの8要素は`Values.Time`の一致を検証してから対応付ける。

## 3. シミュレーション条件

### 3.1 仮定

固定遅延、packet lossなし、jitterなし、2次元直交座標、各軸独立の一次遅れ、機械学習なしを仮定する。詳細な運動学、接触、力覚、実ネットワークは対象外である。

### 3.2 初期条件と評価区間

plant初期状態はzero、packet到着前はinvalidである。基本周期は`period_s=2*pi/omega`、標準設定は10周期のうち最初の2周期を除外する。nominal start/endと、fixed grid上で実際にmetricsへ使用したsample start/end、count、logical maskを`output.evaluation`へ保存する。nominal endを覆わないsimulationや空windowは拒否する。

### 3.3 パラメータ

<!--
既定設定は`dt=0.01 s`、`h_s=0.05 s`、`L=0.10 s`、`T=0.20 s`、`A=1.0 m`、`omega=1.0 rad/s`、seed `0`である。
標準10周期のnominal endを覆うようsimulation durationをfixed gridへ切り上げる。これらは研究結果ではなく再現可能な既定条件である。
-->

### 3.4 数値計算法

solverは`ode4`、fixed stepは`dt`、実行環境はMATLAB R2025b Update 5 / Simulinkである。解析fixtureではcontinuous reference、ZOH packet reconstruction、CV packet reconstructionをsolver/logging semanticsに沿って別toleranceで検証する。

## 4. MATLABプログラム

### 4.1 Main Program

`run_project`はdefault configを生成・検証し、標準評価区間を覆うgrid-aligned durationを確定し、timegrid・trajectory・model validation・simulation・evaluationを順に実行する。出力は`config`、`trajectory`、`simulation`、`evaluation`である。

### 4.2 Sub Programs

MATLAB packageはconfig、timegrid、trajectory、Simulink実行、metricsを責務分離する。Simulink builderはcommunicationと3つのplant instance、named loggingを生成する。Issue #7では保存・作図・sweepは追加しない。

### 4.3 検証

metrics unitでは評価config、period、grid rounding、境界sample inclusion、空/不足window、RMSE、NRMSE、最大誤差、比率、改善率、zero denominator、packet-valid限定平均age、非有限値・shapeを検証する。model/integrationではreference direct path、3 plant共通model/argument、8要素logging、zero-delay fixture、path復元、model cleanup、hash不変、base workspace非残留を検証する。

## 5. 実行結果

<!-- コードから再生成した結果だけを掲載し、各図表を本文で説明する。 -->

### 5.1 代表軌道

### 5.2 遅延・速度・軌道形状の比較

### 5.3 補償の有効範囲と悪化条件

### 5.4 無次元量による整理

### 5.5 数値計算の収束性

## 6. 考察

### 6.1 結果の数理的背景

<!-- Taylor残差、加速度、位相遅れ、サンプリング。 -->

### 6.2 定速度予測が有効となる条件

### 6.3 補償が悪化する条件

### 6.4 モデル化の妥当性と限界

### 6.5 目的達成の判定

<!-- 最初の問いへ明示的に回答する。 -->

## 7. 参考文献

<!-- 本文で実際に引用した確認済み文献だけを記載する。 -->
## Issue #8 実験条件と再現手順

本研究の標準完全要因実験は、`circle` と `lissajous_1_2` の2軌道、delay `{0, 0.10, 0.20, 0.40, 0.50} s`、omega `{0.5, 1.0, 2.0, 4.0} rad/s` の40 caseで構成する。`dt = fixed step = 0.005 s`、sample period `0.020 s`、plant time constant `0.10 s`、total cycles `10`、warm-up cycles `2`、solver `ode4`を固定する。trajectory amplitudeは既存default configを使用する。

cleanなMATLAB sessionからrepository rootで次を実行すると、manifest生成、逐次Simulink実行、reference/ZOH/CV評価、aggregate CSV、全case時系列MAT保存、CSV/MAT round-trip検証までを再生成できる。

```matlab
result = run_standard_experiment();
```

生成結果は `results/generated/<experiment_id>/<run_id>/` に保存される。

## Issue #9 解析成果（実験結果の追記）

Issue #8のcomplete MATを明示入力として、標準40 caseを再実行せずに図・analysis table・境界tableを生成した。入力SHA-256は`E21B8B7486C89010A390CBF52BFF6286E6B217A5D911544D5102E39D87CDDEC8`である。

分類量は`G=RMSE_CV/RMSE_ZOH`、改善率は`(1-G)*100`とした。full modeの収束studyでは代表5 unique caseをfixed-step `0.005` sから`0.0025` sへ半減し、最大`|delta G|=0.0019707`、safety factor 4によるboundary tolerance約`0.0079`を得た。全収束行はvalidatedであり、標準40 case aggregateは置換していない。

| trajectory | improvement | equivalent | degradation |
|---|---:|---:|---:|
| circle | 19 | 0 | 1 |
| lissajous_1_2 | 18 | 0 | 2 |
| total | 37 | 0 | 3 |

代表条件は、circleではbest improvementが`omega=0.5 rad/s, delay=0 s`、worst/nearestが`omega=4 rad/s, delay=0.5 s`、Lissajousではbestが`omega=0.5 rad/s, delay=0 s`、worstが`omega=4 rad/s, delay=0.5 s`、nearestが`omega=2 rad/s, delay=0.5 s`である。図2–3はreference/ZOH/CV trajectory、図4はLissajous誤差normと加速度event、図5–6は離散delay×omega map、図7–8は`omega*delay`と`omega*mean_packet_age`を表示する。

円軌道の`q≈1.895`は文献値としては扱わず、理想正弦波で`E_CV=E_ZOH`を置いた`q=2 sin(q)`の最初の正の非零解という解析候補として比較する。sampled communication、packet-age変動、plant dynamics、fixed-step error、Lissajousの2周波数成分を無視するため、実測境界との一致を断定しない。`omega*time_constant`と`omega*sample_period`は標準designで独立効果を識別できない可能性をrank/collinearity tableへ記録し、因果寄与や統計的有意差は解釈しない。

入力semantic validation、`case_id` join、収束artifactのstrict validation、sidecar file manifest、保存figureのdeterminismを実装した。通常の`render-only`では40 case simulationを再実行せず、理想正弦波の`q=1.895494267...`は実測境界ではなく解析候補として扱う。詳細な数値表と図は生成artifactおよび`docs/reports/issue-9-boundary-analysis.md`を正本とする。
