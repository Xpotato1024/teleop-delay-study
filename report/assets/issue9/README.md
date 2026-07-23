# Issue #9 最終図表監査snapshot

このdirectoryは、Issue #8の保存済み40 case結果からIssue #9相当の図表をrender-onlyで再生成し、Issue #10 Phase Aの監査用に固定したsnapshotです。

## 正本と入力identity

| 項目 | 値 |
|---|---|
| source artifact | `results/generated/analysis/i8v1_n40_2353bb12/issue10_targeted_20260724` |
| source commit | `b1aa629911b17de80032de1dd8a6c9471da63b1c` |
| experiment ID | `i8v1_n40_2353bb12` |
| input run ID | `20260723T013408166Z__0b95b1a` |
| input MAT SHA-256 | `E21B8B7486C89010A390CBF52BFF6286E6B217A5D911544D5102E39D87CDDEC8` |
| convergence artifact | `results/generated/analysis/i8v1_n40_2353bb12/i9v1_i8v1_n40_2353bb12_A3E247DF0482/20260723T120651252Z__3cc0b6b/analysis_tables.mat` |
| convergence artifact SHA-256 | `157D22F59D10CA1F3972FFF7F5B5E7BAF8FFBCFE1909E5750891631F89D027F2` |
| artifact manifest SHA-256 | `156099C172679D2E72FBE04FC1D134CC1EEEDE7CD54BCA7629DEE359B18CEED1` |
| 日本語font | `Noto Sans JP` |

標準40 case simulationとconvergenceは再実行していません。入力MAT、`analysis_tables.mat`、`results/generated`は追跡対象へ複製していません。convergence artifactはpathを明示したstrict render-only入力です。図02–07と11 CSVの内容は変更していません。

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

図01と図08はrepository rootから、入力MATと保存済みconvergence artifactを明示した次のtargeted render-only commandで生成しました。render対象はこの2図だけです。

```powershell
matlab -batch "addpath('src'); inputMat='results/generated/i8v1_n40_2353bb12/20260723T013408166Z__0b95b1a/i8v1_n40_2353bb12__results.mat'; convergenceMat='results/generated/analysis/i8v1_n40_2353bb12/i9v1_i8v1_n40_2353bb12_A3E247DF0482/20260723T120651252Z__3cc0b6b/analysis_tables.mat'; target='results/generated/analysis/i8v1_n40_2353bb12/issue10_targeted_20260724'; result=run_issue9_analysis('InputMat',inputMat,'ConvergenceMat',convergenceMat,'OutputRoot','results/generated','Mode','render-only','SaveResults',false); teleopdelay.analysis.render_system_architecture(target,result.analysis.config); teleopdelay.analysis.render_dimensionless(result.analysis.tables.dimensionless_diagnostics,result.analysis.theory,'q_age','figure_08_performance_vs_omega_mean_packet_age',target,result.analysis.config)"
```

このcommandはsimulationまたはconvergenceを起動しません。

## Copyおよび再生成contract

図01/08のPNG・PDFはtargeted renderer出力からbyte-for-byteでcopyしました。source/destinationのsizeとSHA-256は4 fileで一致しています。図02–07と11 CSVは既存snapshotから変更していません。cropping、compression、metadata書換え、PDF再出力、手動修正は行っていません。

図の修正が必要な場合は画像を直接編集せずrendererを修正し、Issue #9相当の生成処理から再生成します。

`audit/tracked_file_manifest.csv`は自己参照せず、同manifest以外のsnapshot fileを記録します。
