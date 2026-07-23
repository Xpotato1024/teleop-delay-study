$ErrorActionPreference = "Stop"
$python = Get-Command python -ErrorAction Stop

try {
    & $python.Source -c "import reportlab, pypdf, pypdfium2"
}
catch {
    & $python.Source -m pip install --user reportlab pypdf pypdfium2
}

& $python.Source (Join-Path $PSScriptRoot "fast_finalize.py")
if ($LASTEXITCODE -ne 0) {
    throw "fast_finalize.py failed with exit code $LASTEXITCODE"
}

& $python.Source (Join-Path $PSScriptRoot "flatten_fast_pages.py")
if ($LASTEXITCODE -ne 0) {
    throw "flatten_fast_pages.py failed with exit code $LASTEXITCODE"
}

Write-Output "Built: $(Join-Path $PSScriptRoot 'final_report.pdf')"
