"""提出直前の高速PDF最終化。

既存PDFの検証済み本文ページを保持し、問題のある表紙とPDF 7ページだけを
ReportLabで再組版して差し替える。LaTeX/MiKTeXは使用しない。

実行:
    python report/fast_finalize.py

依存:
    python -m pip install reportlab pypdf
"""
from __future__ import annotations

import hashlib
import tempfile
from pathlib import Path

from pypdf import PdfReader, PdfWriter
from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph, Table, TableStyle

REPO_ROOT = Path(__file__).resolve().parents[1]
TARGET = REPO_ROOT / "report" / "final_report.pdf"
PAGE_TO_REPLACE = 7  # 1-based PDF page number
W, H = A4

pdfmetrics.registerFont(UnicodeCIDFont("HeiseiMin-W3"))
pdfmetrics.registerFont(UnicodeCIDFont("HeiseiKakuGo-W5"))


def _cover(path: Path) -> None:
    c = canvas.Canvas(str(path), pagesize=A4)
    c.setTitle("遠隔操作ロボットの通信遅延に対する定速度予測補償の有効範囲")
    c.setAuthor("三ツ井雅翔")
    c.setFont("HeiseiMin-W3", 13)
    c.drawCentredString(W / 2, H - 48 * mm, "2026年度")
    c.setFont("HeiseiKakuGo-W5", 17)
    c.drawCentredString(W / 2, H - 59 * mm, "シミュレーション工学・演習　最終課題")
    c.setStrokeColor(colors.HexColor("#4A5568"))
    c.setLineWidth(0.7)
    c.line(28 * mm, H - 88 * mm, W - 28 * mm, H - 88 * mm)
    c.setFillColor(colors.black)
    c.setFont("HeiseiKakuGo-W5", 22)
    c.drawCentredString(W / 2, H - 112 * mm, "遠隔操作ロボットの通信遅延に対する")
    c.drawCentredString(W / 2, H - 126 * mm, "定速度予測補償の有効範囲")
    c.setFont("HeiseiMin-W3", 13)
    c.drawCentredString(W / 2, H - 143 * mm, "一次遅れ・純遅延モデルを用いた軌道追従解析")
    c.line(28 * mm, H - 156 * mm, W - 28 * mm, H - 156 * mm)

    info = Table(
        [["学年・組", "4年7組"], ["番号", "106番"], ["氏名", "三ツ井雅翔"]],
        colWidths=[35 * mm, 55 * mm],
        rowHeights=[10 * mm] * 3,
    )
    info.setStyle(TableStyle([
        ("FONTNAME", (0, 0), (-1, -1), "HeiseiMin-W3"),
        ("FONTSIZE", (0, 0), (-1, -1), 12),
        ("ALIGN", (0, 0), (0, -1), "RIGHT"),
        ("ALIGN", (1, 0), (1, -1), "LEFT"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LINEBELOW", (0, 0), (-1, -2), 0.25, colors.HexColor("#CBD5E0")),
    ]))
    tw, th = info.wrapOn(c, W, H)
    info.drawOn(c, (W - tw) / 2, 36 * mm)
    c.save()


def _program_page(path: Path) -> None:
    c = canvas.Canvas(str(path), pagesize=A4)
    left, right = 27 * mm, W - 27 * mm
    width = right - left
    y = H - 28 * mm

    c.setFont("HeiseiMin-W3", 9.5)
    c.drawString(left, H - 18 * mm, "2026年度 シミュレーション工学・演習 最終課題")
    c.drawCentredString(W / 2, 12 * mm, "6")

    body = ParagraphStyle("body", fontName="HeiseiMin-W3", fontSize=10.5, leading=16, spaceAfter=5)
    small = ParagraphStyle("small", parent=body, fontSize=9.6, leading=14)
    h1 = ParagraphStyle("h1", fontName="HeiseiKakuGo-W5", fontSize=17, leading=22, spaceAfter=8)
    h2 = ParagraphStyle("h2", fontName="HeiseiKakuGo-W5", fontSize=13, leading=17, spaceBefore=6, spaceAfter=5)
    bullet = ParagraphStyle("bullet", parent=small, leftIndent=13, firstLineIndent=-8, spaceAfter=2)
    note = ParagraphStyle(
        "note", parent=small, leftIndent=6, rightIndent=6,
        backColor=colors.HexColor("#F7FAFC"), borderColor=colors.HexColor("#CBD5E0"),
        borderWidth=0.5, borderPadding=6, spaceBefore=3, spaceAfter=5,
    )

    def put(flowable) -> None:
        nonlocal y
        _, h = flowable.wrap(width, y - 24 * mm)
        if h > y - 24 * mm:
            raise RuntimeError("replacement page overflow")
        flowable.drawOn(c, left, y - h)
        y -= h

    put(Paragraph("数値収束の確認では、代表5条件すべてで判定が維持された。性能分類に用いる許容幅は、時間刻みを半減したときの性能比の最大変化を基に、0.007883とした。", body))
    put(Paragraph("5　MATLAB / Simulink プログラム", h1))
    put(Paragraph("5.1　プログラム構成", h2))
    put(Paragraph("MATLABは、設定値の検証、固定時間格子の生成、軌道生成、実験条件の管理、Simulink実行、評価指標の計算、全条件の集約、保存および図生成を担当する。Simulinkは、通信モデルと3つの一次遅れプラントの時間応答を計算する。", body))
    put(Paragraph("主な公開入口は次の3つである。", body))
    for text in [
        '<font name="Courier">run_project</font>：単一条件の設定、軌道生成、Simulink実行および評価',
        '<font name="Courier">run_standard_experiment</font>：標準40条件の逐次実行とCSV / MAT保存',
        '<font name="Courier">run_issue9_analysis</font>：保存済み40条件から分類、境界抽出、代表条件選定および図生成',
    ]:
        put(Paragraph("・" + text, bullet))
    put(Paragraph("通信部分はModel Referenceとして分離し、送信側サンプリング、固定遅延、最新パケット選択、ZOH再構成およびCV再構成をまとめた。一次遅れプラントも別のModel Referenceとし、ZOH、CV、参照の3経路で同じモデルを共有した。", body))

    put(Paragraph("5.2　処理手順", h2))
    steps = [
        "標準条件の一覧を生成し、設定値を検証する。",
        "軌道、通信遅延、角周波数の全組合せについて処理を繰り返す。",
        "固定時間格子と解析軌道を生成する。",
        "Simulinkへの入力を作成する。",
        "参照系、ZOH系、CV系を同一条件で実行する。",
        "ウォームアップ後の評価区間を抽出する。",
        "RMSE、最大誤差、性能比、改善率、平均パケット齢を計算する。",
        "条件IDと結果を保存する。",
        "全40条件を集約し、CSVとMATへ保存する。",
        "保存結果を再読込して整合性を検証する。",
        "代表条件、性能境界、無次元量の図表を生成する。",
    ]
    rows = [[Paragraph(str(i), small), Paragraph(text, small)] for i, text in enumerate(steps, 1)]
    procedure = Table(rows, colWidths=[8 * mm, width - 8 * mm])
    procedure.setStyle(TableStyle([
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("ALIGN", (0, 0), (0, -1), "RIGHT"),
        ("LEFTPADDING", (0, 0), (-1, -1), 3),
        ("RIGHTPADDING", (0, 0), (-1, -1), 3),
        ("TOPPADDING", (0, 0), (-1, -1), 2.2),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 2.2),
        ("LINEBELOW", (0, 0), (-1, -2), 0.2, colors.HexColor("#E2E8F0")),
        ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#A0AEC0")),
    ]))
    put(procedure)
    put(Paragraph("結果ファイルには、条件、軌道、時系列、評価指標、実行環境、GitコミットおよびSHA-256を記録した。これにより、各図の条件を元の計算結果へ追跡できる。", note))
    put(Paragraph("5.3　Main Program", h2))
    put(Paragraph("標準40条件を実行するMain Programの主要部を次ページのプログラム1に示す。実験条件の作成と検証はSub Programへ分離し、Main Programは保存先の設定と実験実行を担当する。", body))
    c.save()


def main() -> None:
    if not TARGET.exists():
        raise FileNotFoundError(TARGET)
    source = PdfReader(str(TARGET))
    if len(source.pages) < PAGE_TO_REPLACE:
        raise RuntimeError(f"expected at least {PAGE_TO_REPLACE} pages, got {len(source.pages)}")

    with tempfile.TemporaryDirectory(prefix="fast-finalize-") as temp:
        temp_dir = Path(temp)
        cover_path = temp_dir / "cover.pdf"
        page_path = temp_dir / "page7.pdf"
        output_path = temp_dir / "final_report.pdf"
        _cover(cover_path)
        _program_page(page_path)

        cover = PdfReader(str(cover_path))
        replacement = PdfReader(str(page_path))
        writer = PdfWriter()
        for index, page in enumerate(source.pages):
            if index == 0:
                writer.add_page(cover.pages[0])
            elif index == PAGE_TO_REPLACE - 1:
                writer.add_page(replacement.pages[0])
            else:
                writer.add_page(page)
        writer.add_metadata({
            "/Title": "遠隔操作ロボットの通信遅延に対する定速度予測補償の有効範囲",
            "/Author": "三ツ井雅翔",
            "/Subject": "2026年度 シミュレーション工学・演習 最終課題",
            "/Creator": "report/fast_finalize.py",
        })
        with output_path.open("wb") as stream:
            writer.write(stream)
        TARGET.write_bytes(output_path.read_bytes())

    digest = hashlib.sha256(TARGET.read_bytes()).hexdigest().upper()
    print(f"PDF: {TARGET}")
    print(f"pages: {len(PdfReader(str(TARGET)).pages)}")
    print(f"bytes: {TARGET.stat().st_size}")
    print(f"SHA-256: {digest}")


if __name__ == "__main__":
    main()
