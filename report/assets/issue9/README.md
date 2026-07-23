# Issue #9 最終図表監査snapshot

このdirectoryは、Issue #8の保存済み40 case結果からIssue #9相当の図表をrender-onlyで再生成し、Issue #10 Phase Aの監査用に固定したsnapshotです。

## 正本と入力identity

| 項目 | 値 |
|---|---|
| source artifact | `results/generated/analysis/i8v1_n40_2353bb12/i9v1_i8v1_n40_2353bb12_A3E247DF0482/20260723T152620103Z__fb27487` |
| source commit | `fb27487` |
| experiment ID | `i8v1_n40_2353bb12` |
| input run ID | `20260723T013408166Z__0b95b1a` |
| input MAT SHA-256 | `E21B8B7486C89010A390CBF52BFF6286E6B217A5D911544D5102E39D87CDDEC8` |
| convergence artifact | `results/generated/analysis/i8v1_n40_2353bb12/i9v1_i8v1_n40_2353bb12_A3E247DF0482/20260723T120651252Z__3cc0b6b/analysis_tables.mat` |
| convergence artifact SHA-256 | `157D22F59D10CA1F3972FFF7F5B5E7BAF8FFBCFE1909E5750891631F89D027F2` |
| artifact manifest SHA-256 | `6DAAF449F2BCFE57E4C2F9502C1CEEBEA78D6BD464A8FA59BF3D4DD63810FA96` |
| 日本語font | `Noto Sans JP` |

標準40 case simulationとconvergenceは再実行していません。入力MAT、`analysis_tables.mat`、`results/generated`は追跡対象へ複製していません。convergence artifactはpathを明示したstrict render-only入力です。

## Figures

1. `figure_01_system_architecture`
2. `figure_02_representative_circle`
3. `figure_03_representative_lissajous`
4. `figure_04_lissajous_error_timeseries`
5. `figure_05_circle_delay_omega_map`
6. `figure_06_lissajous_delay_omega_map`
7. `figure_07_performance_vs_omega_delay`
8. `figure_08_performance_vs_omega_mean_packet_age`

各figureについて、`figures/`にPNGとvector PDFを1 fileずつ保存しています。タイトル、軸名、凡例、注記、図題は日本語へ統一し、監査対象とsource case IDは[図監査index](audit/figure-review-index.md)を参照してください。ChatGPT review statusは全件`pending`です。

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

source artifactはrepository rootから、入力MATと保存済みconvergence artifactを明示して次のrender-only commandで生成しました。

```powershell
matlab -batch "inputMat=fullfile(pwd,'results','generated','i8v1_n40_2353bb12','20260723T013408166Z__0b95b1a','i8v1_n40_2353bb12__results.mat'); convergenceMat=fullfile(pwd,'results','generated','analysis','i8v1_n40_2353bb12','i9v1_i8v1_n40_2353bb12_A3E247DF0482','20260723T120651252Z__3cc0b6b','analysis_tables.mat'); result=run_issue9_analysis('InputMat',inputMat,'Mode','render-only','ConvergenceMat',convergenceMat,'OutputRoot','results/generated'); assert(result.artifact.saved)"
```

このcommandはsimulationまたはconvergenceを起動しません。

## Copyおよび再生成contract

PNG、PDF、CSVはsource artifactからbyte-for-byteでcopyしました。source/destinationのsizeとSHA-256はcopy対象27 fileで一致しています。cropping、compression、metadata書換え、PDF再出力、手動修正は行っていません。

図の修正が必要な場合は画像を直接編集せずrendererを修正し、Issue #9相当の生成処理から再生成します。

`audit/tracked_file_manifest.csv`は自己参照せず、同manifest以外のsnapshot fileを記録します。
