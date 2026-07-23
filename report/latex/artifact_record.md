# 提出用PDFのartifact record

- final PDF path: `report/final_report.pdf`
- final PDF filename: `final_report.pdf`
- page count: 20
- file size: 2,146,827 bytes
- SHA-256: `A96393921D9F12CA3C2696204FE37A708F2B533FD8B079E70DBD72328AA1298A`
- LaTeX engine: MiKTeX 25.4 `uplatex`（e-upTeX）2回処理 + `dvipdfmx`（MiKTeX 25.4）
- build command: `& .\report\latex\build.ps1`
- template path: `C:\Users\miyut\Desktop\Xpotato-Apps\（参考）LaTeXテンプレート\template`
- build date/time: 2026-07-24 05:14:40 +09:00
- source commit SHA: `05b6e7e`（最終レイアウト修正・PDF・監査記録）

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

## レイアウト修正と最終監査

- 5.2の日本語擬似コードを`lstlisting`から番号付き手順へ置換した。
- 和文と英数字・inline codeの境界に明示的な字間を追加した。
- 表4・表5の列幅を再配分し、役割名・種別名を語単位で読める配置にした。
- 図2・3、図7・8を別ページへ配置し、図5・6は左右余白を`trim/clip`で削減した。
- MATLABコードのプログラム3はPDF 9ページにまとめた。
- pypdfium2とPopplerで20ページを各200 dpiで描画した。pypdfium2では文字・図表・コードを確認し、Popplerでは同じ配置と図の数値セルを照合した。PopplerはAdobe-Japan1言語パック不足の警告を出すため、日本語文字の判定はpypdfium2を基準とした。
