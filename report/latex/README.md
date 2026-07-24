# 提出用PDFの生成

## 正本

提出物の内容・組版の正本は `report/latex/final_report.tex` である。2026年7月25日に実際に提出した19ページPDFと同じ本文、式番号、図表配置、コード掲載方針を保持し、図ファイルだけをリポジトリ内の追跡済みvector PDFへ接続している。

| ファイル | 責務 |
|---|---|
| `final_report.tex` | XeLaTeXで直接処理する提出用原稿 |
| `build.ps1` | XeLaTeX 2回処理、警告検査、`report/final_report.pdf`への配置 |
| `artifact_record.md` | 提出物とリポジトリ生成物の識別情報・監査結果 |
| `../assets/issue9/figures/` | Issue #9で固定した8枚のvector図 |

`cover.tex`、`report_style.sty`、`submission_main.tex`、`upjis-haranoaji.map`は旧upLaTeX経路の履歴として残すが、最終提出版の生成には使用しない。

## 必要環境

- XeLaTeX
- `fontspec` / `xeCJK`
- Noto Serif
- Noto Sans
- Noto Serif CJK JP
- Noto Sans CJK JP
- Noto Sans Mono CJK JP

Ubuntuでは概ね次で準備できる。

```bash
sudo apt-get update
sudo apt-get install -y texlive-xetex texlive-lang-japanese fonts-noto-cjk poppler-utils
```

## Windowsでのビルド

リポジトリルートから実行する。

```powershell
& .\report\latex\build.ps1
```

処理内容:

1. `final_report.tex`をXeLaTeXで2回処理する。
2. LaTeX error、未解決参照、overfull/underfull box、警告を検査する。
3. 完成PDFを`report/final_report.pdf`へ配置する。
4. ファイルサイズとSHA-256を表示する。

## GitHub Actions

`finalize-report-pdf.yml`は最終原稿または図が変更されたときに同じXeLaTeX経路でPDFを生成し、A4・19ページ・非暗号化を検証する。生成PDFと`artifact_record.md`に差分がある場合はPR branchへ自動commitする。

## 提出版との同一性

ローカルでリポジトリ用パスへ置き換えた原稿を再ビルドし、実提出PDFと200 dpiで全19ページを比較した結果、変更ページは0、全画素差は0であった。PDFのbyte hashは生成日時等のmetadataにより異なり得るため、提出物の識別には`artifact_record.md`に記録した提出時SHA-256を使用する。
