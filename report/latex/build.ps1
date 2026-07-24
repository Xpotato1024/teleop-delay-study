$ErrorActionPreference = "Stop"

$latexDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$reportDirectory = Split-Path -Parent $latexDirectory
$source = Join-Path $latexDirectory "final_report.tex"
$buildDirectory = Join-Path $latexDirectory ".generated"
$outputPdf = Join-Path $reportDirectory "final_report.pdf"
$log = Join-Path $buildDirectory "final_report.log"
$builtPdf = Join-Path $buildDirectory "final_report.pdf"

$xelatex = (Get-Command xelatex -ErrorAction Stop).Source

if (-not (Test-Path -LiteralPath $source)) {
    throw "Required source was not found: $source"
}

[System.IO.Directory]::CreateDirectory($buildDirectory) | Out-Null

$previousDirectory = Get-Location
try {
    Set-Location -LiteralPath $latexDirectory

    foreach ($pass in 1..2) {
        & $xelatex `
            -interaction=nonstopmode `
            -halt-on-error `
            -file-line-error `
            -output-directory=$buildDirectory `
            final_report.tex

        if ($LASTEXITCODE -ne 0) {
            throw "XeLaTeX failed on pass $pass"
        }
    }

    if (-not (Test-Path -LiteralPath $builtPdf)) {
        throw "XeLaTeX did not produce $builtPdf"
    }
    if (Select-String -LiteralPath $log -Pattern '^!' -Quiet) {
        throw "XeLaTeX reported an error; inspect $log"
    }
    if (Select-String -LiteralPath $log -Pattern 'Overfull\s+\\[hv]box|Underfull\s+\\[hv]box|LaTeX Warning|Package .* Warning|undefined references' -Quiet) {
        throw "XeLaTeX reported a layout or reference warning; inspect $log"
    }

    Copy-Item -LiteralPath $builtPdf -Destination $outputPdf -Force
}
finally {
    Set-Location -LiteralPath $previousDirectory
}

$hash = (Get-FileHash -LiteralPath $outputPdf -Algorithm SHA256).Hash
$size = (Get-Item -LiteralPath $outputPdf).Length
Write-Output "Built: $outputPdf"
Write-Output "Bytes: $size"
Write-Output "SHA-256: $hash"
