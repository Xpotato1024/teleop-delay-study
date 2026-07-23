# 提出用PDFの生成

## 採用したテンプレート

指定された `C:\Users\miyut\Desktop\Xpotato-Apps\（参考）LaTeXテンプレート\template` を監査し、`template.tex` の構成を提出用原稿へ移植した。

- 文書クラス: `jarticle` 相当の `ujarticle`、11pt、A4、title page
- 用紙と余白: 上35 mm、下30 mm、左右30 mm
- 日本語組版: upLaTeXのUTF-8入力、`dvipdfmx`出力
- 日本語フォント: HaranoAjiMincho-Regular / HaranoAjiGothic-Mediumを埋め込み
- 見出し: `section`、`subsection`、`subsubsection`
- 表紙: テンプレートの `titlepage` 配置を維持し、学年・組・番号・氏名を反映
- 図・表・数式: `graphicx`、`booktabs`、`array`、`amsmath`、テンプレートの中央キャプション定義を使用
- プログラム: `listings`、行番号、枠線、長行折返しを使用
- キャプション: 図は図下、表は表上
- ページ番号: テンプレートの `fancyhdr` による下中央ページ番号
- 参考文献: `thebibliography` 相当の手動リストで本文の[1]--[5]と対応

元テンプレートはpLaTeXの `jarticle` とJY1フォント定義を前提としていたが、現行Windows MiKTeXの `platex.exe` は実行時DLL不足で起動できず、`uplatex` では `jarticle` のJY1定義を解決できなかった。このため、テンプレートのA4・余白・見出し・表紙・キャプション・ページスタイルを維持したupLaTeX互換クラス `ujarticle` を使用した。`upjis-haranoaji.map` はその互換実行に必要なフォントmapである。

## ビルド

リポジトリルートから次を実行する。

```powershell
& .\report\latex\build.ps1
```

スクリプトは `report/latex/final_report.tex` をupLaTeXで2回処理し、`dvipdfmx`で `report/final_report.pdf` を生成する。図は `report/assets/issue9/figures/figure_01_*.pdf` から `figure_08_*.pdf` を直接読み込み、PNGからの再ラスタライズは行わない。

必要な実行環境はMiKTeX 25.4の `uplatex`、`dvipdfmx` と、MiKTeXユーザーフォントのHaranoAjiである。`pandoc`は原稿移植時の変換確認にのみ使用し、提出PDFのビルドは追跡済みLaTeX原稿から行う。

## Simulink画面の扱い

Simulink画面のスクリーンショットは追加していない。図1が通信モデル、ZOH/CV/参照の3プラント、評価経路を説明し、第5章がMATLAB/Simulinkの責務分担と実装コードを示すため、課題要件を満たすうえで追加の画面キャプチャは不要と判断した。画面文字を縮小して読めなくするリスクも避けた。
