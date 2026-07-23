$ErrorActionPreference = "Stop"

$latexDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$texBin = "C:\Program Files\MiKTeX\miktex\bin\x64"
$uplatex = Join-Path $texBin "uplatex.exe"
$dvipdfmx = Join-Path $texBin "dvipdfmx.exe"
$source = Join-Path $latexDirectory "final_report.tex"
$dvi = Join-Path $latexDirectory "final_report.dvi"
$pdf = Join-Path (Split-Path -Parent $latexDirectory) "final_report.pdf"
$fontMap = Join-Path $latexDirectory "upjis-haranoaji.map"

foreach ($requiredFile in @($uplatex, $dvipdfmx, $source, $fontMap)) {
    if (-not (Test-Path -LiteralPath $requiredFile)) {
        throw "Required build input was not found: $requiredFile"
    }
}

$previousDirectory = Get-Location
try {
    Set-Location -LiteralPath $latexDirectory
    & $uplatex -interaction=nonstopmode -halt-on-error -file-line-error final_report.tex
    if (-not (Test-Path -LiteralPath $dvi)) {
        throw "uplatex did not produce final_report.dvi"
    }

    & $uplatex -interaction=nonstopmode -halt-on-error -file-line-error final_report.tex
    if (-not (Test-Path -LiteralPath $dvi)) {
        throw "uplatex did not produce final_report.dvi on the second pass"
    }
    if (Select-String -LiteralPath (Join-Path $latexDirectory "final_report.log") -Pattern "^!" -Quiet) {
        throw "LaTeX reported an error; inspect report/latex/final_report.log"
    }
    if (Select-String -LiteralPath (Join-Path $latexDirectory "final_report.log") -Pattern 'Overfull\\[hv]box' -Quiet) {
        throw "LaTeX reported an overfull box; inspect report/latex/final_report.log"
    }

    & $dvipdfmx -f $fontMap -o $pdf $dvi
    if (-not (Test-Path -LiteralPath $pdf)) {
        throw "dvipdfmx did not produce $pdf"
    }
}
finally {
    Set-Location -LiteralPath $previousDirectory
}

Write-Output "Built: $pdf"
