# 提出用PDFのartifact record

> **Status: REBUILD REQUIRED**
>
> 表紙・組版・ビルド構造を`cover.tex`、`report_style.sty`、`submission_main.tex`へ分離したため、現在追跡されている`report/final_report.pdf`は旧ビルド成果物である。新しいビルド手順を実行し、全ページ監査とhash更新が完了するまで提出用final artifactとして扱わない。

## 直前のPDF artifact

- final PDF path: `report/final_report.pdf`
- final PDF filename: `final_report.pdf`
- page count: 20
- file size: 2,146,827 bytes
- SHA-256: `A96393921D9F12CA3C2696204FE37A708F2B533FD8B079E70DBD72328AA1298A`
- LaTeX engine: MiKTeX 25.4 `uplatex`（e-upTeX）2回処理 + `dvipdfmx`（MiKTeX 25.4）
- previous build command: `& .\report\latex\build.ps1`
- template path: `C:\Users\miyut\Desktop\Xpotato-Apps\（参考）LaTeXテンプレート\template`
- build date/time: 2026-07-24 05:14:40 +09:00
- source commit SHA: `05b6e7e`（旧レイアウト修正・PDF・監査記録）

上記hashは構造分離前のPDFを識別するために残す。再ビルド後はこの節を新しいartifact情報へ置換する。

## 新しい生成構造

- entry point: `report/latex/submission_main.tex`
- cover: `report/latex/cover.tex`
- style: `report/latex/report_style.sty`
- content source: `report/latex/final_report.tex`
- generated body: `report/latex/.generated/report_body.tex`（追跡しない）
- build command: `& .\report\latex\build.ps1`

## 使用図ファイル

以下の既存vector PDFを直接読み込む。PNGからの再ラスタライズ、手動編集、再生成は行わない。

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

## 再ビルド後の必須更新

1. page count
2. file size
3. SHA-256
4. build date/time
5. source commit SHA
6. 表紙を含む全ページの視覚監査結果
7. 図5・6の全セル値可読性
8. 表4・5、コード、和欧文間隔の確認
