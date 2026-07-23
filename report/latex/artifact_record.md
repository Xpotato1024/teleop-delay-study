# 提出用PDFのartifact record

- final PDF path: `report/final_report.pdf`
- final PDF filename: `final_report.pdf`
- page count: 18
- file size: 2,144,922 bytes
- SHA-256: `F7B0FBEF8D0D9F830AD28F6D65E5975E5EFD0F1728095BAF44AF69E937226068`
- LaTeX engine: MiKTeX 25.4 `uplatex`（e-upTeX）2回処理 + `dvipdfmx`（MiKTeX 25.4）
- build command: `& .\report\latex\build.ps1`
- template path: `C:\Users\miyut\Desktop\Xpotato-Apps\（参考）LaTeXテンプレート\template`
- build date/time: 2026-07-24 04:26:18 +09:00
- source commit SHA: `e72f95749080063207b28d5a241985f3994accb3`

## 使用図ファイル

以下の既存vector PDFを直接読み込んだ。PNGからの再ラスタライズ、手動編集、再生成は行っていない。

- `report/assets/issue9/figures/figure_01_system_architecture.pdf`
- `report/assets/issue9/figures/figure_02_representative_circle.pdf`
- `report/assets/issue9/figures/figure_03_representative_lissajous.pdf`
- `report/assets/issue9/figures/figure_04_lissajous_error_timeseries.pdf`
- `report/assets/issue9/figures/figure_05_circle_delay_omega_map.pdf`
- `report/assets/issue9/figures/figure_06_lissajous_delay_omega_map.pdf`
- `report/assets/issue9/figures/figure_07_performance_vs_omega_delay.pdf`
- `report/assets/issue9/figures/figure_08_performance_vs_omega_mean_packet_age.pdf`

## フォント情報

- 本文・見出し: `HaranoAjiMincho-Regular.otf`、`HaranoAjiGothic-Medium.otf`
- 本文用font map: `report/latex/upjis-haranoaji.map`
- コード・数式: TeX標準のComputer Modern系フォント
- 既存vector図に内包されたフォント: `NotoSansJP-Thin`、`MS-UIGothic`等

本文の日本語フォントは、テンプレートの日本語組版を維持したupLaTeX/dvipdfmx経路でPDFへ埋め込んだ。
