# 提出用PDFのartifact record

## 実際に提出した成果物

- submission date: 2026-07-25
- filename: `シミュレーション工学_最終課題_三ツ井雅翔_提出版.pdf`
- page count: 19
- page size: A4
- file size: 4,874,221 bytes
- encrypted: no
- PDF version: 1.5
- SHA-256: `FC48B9D3F1B6BE87030F7A6D4F282DD46A20596130BFDAED3229F36A5F823AD4`
- source SHA-256 before repository-path adaptation: `05AE27B8F9CCEBCCCA2D4C9C6A38FEA0A5B5710E1D6A5F7C7389C706F612FBC2`

このPDFを授業の最終成果物として提出済みである。

## リポジトリ正本

- source: `report/latex/final_report.tex`
- build command: `& .\report\latex\build.ps1`
- output: `report/final_report.pdf`
- engine: XeLaTeX 2 passes
- figures: `report/assets/issue9/figures/figure_01_*.pdf` ～ `figure_08_*.pdf`

リポジトリ用原稿は、提出時原稿の図パスのみを追跡済みassetへ変更したもの。ローカル再ビルドと実提出PDFを200 dpiで全19ページ比較し、changed pages 0、pixel difference 0を確認した。

## 提出前最終監査

- A4、19ページ
- 数式番号: 式(1)～式(19)の連続性を確認
- TODO / FIXME / placeholder / ローカル絶対パスなし
- 未解決参照なし
- XeLaTeX warningなし
- overfull / underfull boxなし
- 全フォント埋め込み
- PDFium / Popplerの双方で全ページ描画可能
- 文字切れ、重なり、文字化け、空白ページなし
- 採点基準7項目を充足し、P0/P1なし

## GitHub生成物

GitHub Actionsによる生成後、この節は生成日時、commit、ページ数、サイズ、SHA-256を含む確定記録へ自動更新される。
