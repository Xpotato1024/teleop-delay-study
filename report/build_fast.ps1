$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$python = Get-Command python -ErrorAction Stop

try {
    & $python.Source -c "import reportlab, pypdf"
}
catch {
    & $python.Source -m pip install --user reportlab pypdf
}

& $python.Source (Join-Path $PSScriptRoot "fast_finalize.py")
if ($LASTEXITCODE -ne 0) {
    throw "fast_finalize.py failed with exit code $LASTEXITCODE"
}

Write-Output "Built: $(Join-Path $PSScriptRoot 'final_report.pdf')"
