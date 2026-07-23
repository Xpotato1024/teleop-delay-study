# Issue #9 結果図・無次元整理・CV有効境界解析

## 目的と入力

Issue #8で保存したcomplete MATを明示的な`InputMat`として読み、標準40 caseを通常の可視化処理で再実行せずに分析する。入力は`run_status=complete`、success 40、failed 0、aggregate/cases 40、標準delay/omega grid、case時系列shape/time alignment、aggregateとcase metricsの一致、SHA-256を検証する。検証失敗時はstable errorで全図・全tableの生成を行わない。

```matlab
result = run_issue9_analysis("InputMat", inputMat, "Mode", "full");
result = run_issue9_analysis("InputMat", inputMat, "Mode", "render-only");
```

`full`は代表caseのfixed-step半減収束だけを追加実行し、`render-only`は保存済み時系列から再描画する。成果物は`results/generated/analysis/<experiment_id>/<analysis_id>/<analysis_run_id>/`へatomic renameする。

## 分類

分類量は`G=RMSE_CV/RMSE_ZOH`、`improvement_percent=(1-G)*100`とした。full modeではmachine-precision floorと、代表case収束で得た最大`|delta G|`へ固定safety factor 4を適用する。収束artifactのないrender-onlyはmachine-precision-onlyとしてmetadataへ記録する。

入力MATに対するrender-onlyの実測分類は次の通りである。

| trajectory | improvement | equivalent | degradation |
|---|---:|---:|---:|
| circle | 19 | 0 | 1 |
| lissajous_1_2 | 18 | 0 | 2 |
| total | 37 | 0 | 3 |

## 代表caseと境界

代表caseは指標を降順/昇順に比較し、最終tie-breakをcanonical `case_id`昇順とした。worst degradationが存在しないtrajectoryではnearest boundaryをfallbackとして理由付きで保持する。同じcaseが複数roleへ選ばれる場合はrole mappingを隠さない。

現入力での代表条件は次の通りである。

| trajectory | best improvement | worst degradation | nearest boundary |
|---|---|---|---|
| circle | omega=0.5, delay=0 s | omega=4, delay=0.5 s | omega=4, delay=0.5 s |
| lissajous_1_2 | omega=0.5, delay=0 s | omega=4, delay=0.5 s | omega=2, delay=0.5 s |

boundary tableは各trajectoryのfixed omegaにおける隣接delay pair、fixed delayにおける隣接omega pairだけを正式結果とする。G=1の滑らかな補間曲線は描かず、nearest-G pairとimprovement/degradation pairを`bracket_type`で区別する。

## 理論候補との比較

repository内に`q≈1.895`の文献出典・既存定義は見つからなかったため、文献値として扱わない。理想正弦波と正確な遅延速度を用いる定速度外挿について、

```text
E_ZOH^2 = 2(1-cos(q))
E_CV^2  = (1-cos(q))^2 + (q-sin(q))^2
E_CV=E_ZOH  ->  q=2 sin(q)
```

の最初の正の非零解を解析的に求め、`q_candidate=1.895494267...`とした。これはsampled communication、packet-age変動、sampled velocity、plant dynamics、fixed-step error、Lissajousの複数周波数成分を無視する理想候補である。circleでは`omega*delay`と`omega*mean_packet_age`を比較し、Lissajousでは`q1=omega*age`と`q2=2*omega*age`を別々に表示する。

## 収束

base fixed stepは`0.005` s、refined fixed stepは`0.0025` s、sample periodは`0.020` s、solverは`ode4`である。代表roleをunique caseへ圧縮し、5 caseをrefineした。初回full実行では全行が`validated`で、最大`|delta G|`は`0.0019707`、したがってboundary toleranceは約`0.0079`となった。収束tableは標準40 caseのaggregateを置換せず、supplementary resultとして保存する。

## 図とtable

必須図はsystem architecture、circle代表軌跡、Lissajous代表軌跡、Lissajous error/acceleration、circle/Lissajous discrete map、`G`対`omega*delay`、`G`対`omega*mean_packet_age`の8図である。すべてPNG 300 dpiとvector PDFを生成し、figure manifestへcase IDs、caption、axes contract、size、SHA-256を記録する。

CSV/MAT tableは`case_classification`、`extreme_cases`、`nearest_boundary_cases`、`boundary_brackets`、`representative_cases`、`instantaneous_error_extremes`、`dimensionless_diagnostics`、`identifiability`、`convergence`、`figure_manifest`である。

## 識別可能性と制限

`omega*time_constant`と`omega*sample_period`は固定値をomegaへ掛けた列であり、design matrixのrank/collinearityをtableへ保存する。この40 caseだけから両者の独立した因果寄与を分離できないため、多変量係数やp-valueは使用しない。Lissajousを単一正弦波へ置換せず、方向変化・高加速度と誤差peakの時間的対応は観察結果として示し、因果関係とは断定しない。離散grid外の境界、packet loss/jitter、実ネットワーク、別軌道、統計的有意差は対象外である。

## P1/P2 re-review addendum

dimensionless、代表case、boundary、figure 7/8のsource tableは`case_id` joinで構築し、入力aggregateのrow permutationに依存しないことをfixtureで確認した。InputMat validatorはmanifest 40要素、top-level/metadata ID、全condition、trajectory/simulation time alignment、evaluation mask、packet validity、再計算metric・無次元量をfail-closedに検証する。

収束artifactは空tableを保存済み結果と呼ばず、候補ごとの拒否理由をdiagnosticへ記録する。有効候補のsemantic contentが異なる場合はstable ambiguity error、同一内容ならcanonical path順で選択する。relative deltaは真の相対差であり、`analysis_tables.mat`のself hashはmetadataから除外して`artifact_manifest.csv`へ最終MATを記録する。event acceleration percentileはconfig値をselection、caption、axes contractで共有する。
