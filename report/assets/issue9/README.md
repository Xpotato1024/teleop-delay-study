# Issue #9 最終図表監査snapshot

このdirectoryは、Issue #9で確定したfinal full artifactを内容変更せずに固定した、Issue #10 Phase Aの監査用snapshotです。

## 正本と入力identity

| 項目 | 値 |
|---|---|
| source artifact | `results/generated/analysis/i8v1_n40_2353bb12/i9v1_i8v1_n40_2353bb12_A3E247DF0482/20260723T120651252Z__3cc0b6b` |
| source commit | `3cc0b6bc383b6f614030011147f44e1849b76b3a` |
| experiment ID | `i8v1_n40_2353bb12` |
| input run ID | `20260723T013408166Z__0b95b1a` |
| input MAT SHA-256 | `E21B8B7486C89010A390CBF52BFF6286E6B217A5D911544D5102E39D87CDDEC8` |
| artifact manifest SHA-256 | `FEDA8738168F53AF38E606173AA5A1DA5F4DD8AD552DD0C42385B1C8F0F51CB6` |

標準40 case simulationは、このsnapshot作成時には再実行していません。入力MATおよび`analysis_tables.mat`は追跡対象へ複製していません。

## Figures

1. `figure_01_system_architecture`
2. `figure_02_representative_circle`
3. `figure_03_representative_lissajous`
4. `figure_04_lissajous_error_timeseries`
5. `figure_05_circle_delay_omega_map`
6. `figure_06_lissajous_delay_omega_map`
7. `figure_07_performance_vs_omega_delay`
8. `figure_08_performance_vs_omega_mean_packet_age`

各figureについて、`figures/`にPNGとvector PDFを1 fileずつ保存しています。監査対象とsource case IDは[`audit/figure-review-index.md`](audit/figure-review-index.md)を参照してください。

## Tables

- `figure_manifest.csv`
- `artifact_manifest.csv`
- `case_classification.csv`
- `extreme_cases.csv`
- `nearest_boundary_cases.csv`
- `boundary_brackets.csv`
- `representative_cases.csv`
- `instantaneous_error_extremes.csv`
- `dimensionless_diagnostics.csv`
- `identifiability.csv`
- `convergence.csv`

## 生成command

source artifactは、repository rootから次のfull mode相当のcommandで生成されました。`InputMat`はrepository-relative pathで明示します。

```powershell
matlab -batch "inputMat=fullfile(pwd,'results','generated','i8v1_n40_2353bb12','20260723T013408166Z__0b95b1a','i8v1_n40_2353bb12__results.mat'); result=run_issue9_analysis('InputMat',inputMat,'Mode','full'); assert(result.artifact.saved)"
```

このcommandはsnapshot作成時には再実行していません。

## Copyおよび再生成contract

PNG、PDF、CSVはsource artifactからbyte-for-byteでcopyし、source/destinationのsizeとSHA-256が全fileで一致することを確認しています。cropping、compression、metadata書換え、PDF再出力、手動修正は行っていません。

図の修正が必要な場合は画像を直接編集せずrendererを修正し、Issue #9相当の生成処理から再生成します。

`audit/tracked_file_manifest.csv`は自己参照しません。同manifestは自身以外のsnapshot fileを記録します。

## 解釈上の注意

- `q≈1.895`は文献値や実測境界ではなく、理想正弦波から導出した解析候補です。
- boundaryは離散gridで隣接するcaseのpairであり、補間境界ではありません。
- `omega*delay`と`omega*mean_packet_age`は異なる量です。
- Lissajous軌道は1:2周波数成分と方向変化を含むため、単一正弦波へ還元した断定は行いません。
