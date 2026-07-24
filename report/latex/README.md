# 最終レポートPDFの管理

## 成果物の区分

2026年7月25日に授業へ提出したPDFを最終提出物とする。提出物そのものの同一性は `artifact_record.md` に記録したファイル名、サイズおよびSHA-256で管理する。

リポジトリには、提出版と同じ本文、数式、図表、コードおよび参考文献を保持する再現用XeLaTeX原稿と、そのCI生成PDFを保存する。TeX環境差による改ページ変動を避けるため、リポジトリ原稿の行間は1.04へ固定している。このため、提出済みPDFとリポジトリ生成PDFは内容上対応するが、組版設定と生成metadataが異なり、byte-identicalではない。

| ファイル | 責務 |
|---|---|
| `final_report.tex` | リポジトリ内の再現用正本 |
| `build.ps1` | XeLaTeX 2回処理、警告検査、`report/final_report.pdf`への配置 |
| `artifact_record.md` | 実提出物とリポジトリ生成物の識別情報・監査記録 |
| `../final_report.pdf` | リポジトリ原稿から生成した19ページPDF |
| `../assets/issue9/figures/` | Issue #9で固定した8枚のvector図 |

`cover.tex`、`report_style.sty`、`submission_main.tex`、`upjis-haranoaji.map`は旧upLaTeX経路の履歴として残すが、最終レポートの生成には使用しない。

## 必要環境

- XeLaTeX
- `fontspec` / `xeCJK`
- Noto Serif
- Noto Sans
- Noto Serif CJK JP
- Noto Sans CJK JP
- Noto Sans Mono CJK JP

Ubuntu系では概ね次で準備できる。

```bash
sudo apt-get update
sudo apt-get install -y texlive-xetex texlive-lang-japanese fonts-noto-core fonts-noto-cjk poppler-utils
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

`.github/workflows/finalize-report-pdf.yml`はTeX Live 2025と固定したNoto CJKフォントで原稿を生成し、次を検証する。

- XeLaTeX/latexmk build成功
- warning、未解決参照、overfull/underfullなし
- A4
- 19ページ
- 非暗号化

検証後、`report/final_report.pdf`と`artifact_record.md`を更新する。

## 提出物の識別

提出済みPDFのSHA-256は次である。

```text
FC48B9D3F1B6BE87030F7A6D4F282DD46A20596130BFDAED3229F36A5F823AD4
```

提出物のページ画像、数式番号、フォント埋込み、文字化け、重なり、空白ページなどの最終監査結果は `artifact_record.md` を参照する。
