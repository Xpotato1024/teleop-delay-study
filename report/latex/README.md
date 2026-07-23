# 提出用PDFの生成

## 正本と責務

提出PDFの正本はLaTeX側に統一する。`report/final_report.md`は本文作成時の参照・監査用であり、提出PDFを直接生成する正本ではない。

| ファイル | 責務 |
|---|---|
| `final_report.tex` | 提出本文の内容。ビルド時に最初の `\section{シミュレーションの目的}` から `\end{document}` 直前までを抽出する |
| `report_style.sty` | 用紙、余白、見出し、ヘッダ、図表、コード、和欧文間隔の組版規則 |
| `cover.tex` | 表紙の内容とレイアウト |
| `submission_main.tex` | 表紙・本文を組み立てる最小のentry point |
| `build.ps1` | 本文抽出、upLaTeX 2回処理、dvipdfmx出力、基本検証 |

これにより、表紙や組版設定を本文へ埋め込まず、局所的な `\hspace` 補修に依存しない。和欧文間隔はupLaTeXの `\autospacing` / `\autoxspacing`を文書全体の規則として使用する。

## 採用したテンプレート

指定された `C:\Users\miyut\Desktop\Xpotato-Apps\（参考）LaTeXテンプレート\template` を監査し、`template.tex`の基本構成を提出用原稿へ移植した。

- 文書クラス: `jarticle`相当の`ujarticle`、11pt、A4、title page
- 用紙と余白: 上35 mm、下30 mm、左右30 mm
- 日本語組版: upLaTeXのUTF-8入力、`dvipdfmx`出力
- 日本語フォント: HaranoAjiMincho-Regular / HaranoAjiGothic-Mediumを埋め込み
- 見出し: `section`、`subsection`、`subsubsection`
- 図・表・数式: `graphicx`、`booktabs`、`array`、`amsmath`
- プログラム: `listings`、行番号、枠線、長行折返し
- キャプション: 図は図下、表は表上
- ページ番号: `fancyhdr`による下中央ページ番号
- 参考文献: 本文の[1]–[5]と対応する手動リスト

元テンプレートはpLaTeXの`jarticle`とJY1フォント定義を前提としていたが、現行Windows MiKTeXの`platex.exe`は実行時DLL不足で起動できず、`uplatex`では`jarticle`のJY1定義を解決できなかった。このため、レイアウトを維持したupLaTeX互換クラス`ujarticle`と`upjis-haranoaji.map`を使用する。

## ビルド

リポジトリルートから次を実行する。

```powershell
& .\report\latex\build.ps1
```

ビルドスクリプトは次を行う。

1. `final_report.tex`から本文部分を`.generated/report_body.tex`へUTF-8 BOMなしで抽出する。
2. `submission_main.tex`をupLaTeXで2回処理する。
3. LaTeX errorとoverfull boxを検査する。
4. `dvipdfmx`で`report/final_report.pdf`を生成する。

図は`report/assets/issue9/figures/figure_01_*.pdf`から`figure_08_*.pdf`を直接読み込み、PNGから再ラスタライズしない。

必要な実行環境はMiKTeX 25.4の`uplatex`、`dvipdfmx`と、MiKTeXユーザーフォントのHaranoAjiである。

## PDF更新状態

`report_style.sty`、`cover.tex`、`submission_main.tex`または`build.ps1`を変更した場合、追跡済み`report/final_report.pdf`は再ビルド・全ページ監査が完了するまで最新成果物として扱わない。再ビルド後に`artifact_record.md`のページ数、サイズ、SHA-256、時刻、source commitを更新する。

## Simulink画面の扱い

Simulink画面のスクリーンショットは追加していない。図1が通信モデル、ZOH/CV/参照の3プラント、評価経路を説明し、第5章がMATLAB/Simulinkの責務分担と実装コードを示すため、課題要件を満たすうえで追加の画面キャプチャは不要と判断した。画面文字を縮小して読めなくするリスクも避けた。
