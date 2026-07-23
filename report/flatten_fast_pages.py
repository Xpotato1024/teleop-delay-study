"""PDF 1ページ目と7ページ目を画像化し、非埋込みCIDフォント依存を除去する。"""
from __future__ import annotations

import tempfile
from pathlib import Path

import pypdfium2 as pdfium
from pypdf import PdfReader, PdfWriter
from reportlab.lib.pagesizes import A4
from reportlab.pdfgen import canvas

REPO_ROOT = Path(__file__).resolve().parents[1]
TARGET = REPO_ROOT / "report" / "final_report.pdf"
PAGES_TO_FLATTEN = {0, 6}  # 0-based: cover and PDF page 7
W, H = A4


def _image_page(source: Path, target: Path, dpi: int = 300) -> None:
    doc = pdfium.PdfDocument(str(source))
    page = doc[0]
    bitmap = page.render(scale=dpi / 72.0)
    image = bitmap.to_pil().convert("RGB")
    png = target.with_suffix(".png")
    image.save(png, format="PNG", optimize=True)
    out = canvas.Canvas(str(target), pagesize=A4)
    out.drawImage(str(png), 0, 0, width=W, height=H, preserveAspectRatio=True, mask="auto")
    out.save()
    png.unlink(missing_ok=True)
    page.close()
    doc.close()


def main() -> None:
    reader = PdfReader(str(TARGET))
    with tempfile.TemporaryDirectory(prefix="flatten-fast-pages-") as temp:
        temp_dir = Path(temp)
        writer = PdfWriter()
        for index, page in enumerate(reader.pages):
            if index not in PAGES_TO_FLATTEN:
                writer.add_page(page)
                continue
            one_page = temp_dir / f"source-{index + 1}.pdf"
            one_writer = PdfWriter()
            one_writer.add_page(page)
            with one_page.open("wb") as stream:
                one_writer.write(stream)
            flattened = temp_dir / f"flat-{index + 1}.pdf"
            _image_page(one_page, flattened)
            writer.add_page(PdfReader(str(flattened)).pages[0])
        output = temp_dir / "final_report.pdf"
        with output.open("wb") as stream:
            writer.write(stream)
        TARGET.write_bytes(output.read_bytes())

    print(f"Flattened pages 1 and 7: {TARGET}")


if __name__ == "__main__":
    main()
