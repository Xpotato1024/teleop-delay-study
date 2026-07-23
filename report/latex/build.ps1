$ErrorActionPreference = "Stop"

$latexDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$texBin = "C:\Program Files\MiKTeX\miktex\bin\x64"
$uplatex = Join-Path $texBin "uplatex.exe"
$dvipdfmx = Join-Path $texBin "dvipdfmx.exe"

$contentSource = Join-Path $latexDirectory "final_report.tex"
$mainSource = Join-Path $latexDirectory "submission_main.tex"
$styleSource = Join-Path $latexDirectory "report_style.sty"
$coverSource = Join-Path $latexDirectory "cover.tex"
$generatedDirectory = Join-Path $latexDirectory ".generated"
$generatedBody = Join-Path $generatedDirectory "report_body.tex"
$dvi = Join-Path $latexDirectory "submission_main.dvi"
$log = Join-Path $latexDirectory "submission_main.log"
$pdf = Join-Path (Split-Path -Parent $latexDirectory) "final_report.pdf"
$fontMap = Join-Path $latexDirectory "upjis-haranoaji.map"

foreach ($requiredFile in @(
    $uplatex,
    $dvipdfmx,
    $contentSource,
    $mainSource,
    $styleSource,
    $coverSource,
    $fontMap
)) {
    if (-not (Test-Path -LiteralPath $requiredFile)) {
        throw "Required build input was not found: $requiredFile"
    }
}

# final_report.texから本文だけを決定的に抽出する。
# 表紙と組版設定はcover.tex / report_style.styを唯一の正本とする。
$sourceText = [System.IO.File]::ReadAllText($contentSource)
$bodyStartMarker = "\section{シミュレーションの目的}"
$documentEndMarker = "\end{document}"
$bodyStart = $sourceText.IndexOf($bodyStartMarker, [System.StringComparison]::Ordinal)
$bodyEnd = $sourceText.LastIndexOf($documentEndMarker, [System.StringComparison]::Ordinal)

if ($bodyStart -lt 0) {
    throw "Body start marker was not found in $contentSource"
}
if ($bodyEnd -le $bodyStart) {
    throw "Document end marker was not found after the body start marker"
}
if ($sourceText.IndexOf($bodyStartMarker, $bodyStart + $bodyStartMarker.Length, [System.StringComparison]::Ordinal) -ge 0) {
    throw "Body start marker appears more than once"
}

$bodyText = $sourceText.Substring($bodyStart, $bodyEnd - $bodyStart).TrimEnd() + [Environment]::NewLine
[System.IO.Directory]::CreateDirectory($generatedDirectory) | Out-Null
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($generatedBody, $bodyText, $utf8WithoutBom)

$previousDirectory = Get-Location
try {
    Set-Location -LiteralPath $latexDirectory

    & $uplatex -interaction=nonstopmode -halt-on-error -file-line-error submission_main.tex
    if (-not (Test-Path -LiteralPath $dvi)) {
        throw "uplatex did not produce submission_main.dvi"
    }

    & $uplatex -interaction=nonstopmode -halt-on-error -file-line-error submission_main.tex
    if (-not (Test-Path -LiteralPath $dvi)) {
        throw "uplatex did not produce submission_main.dvi on the second pass"
    }

    if (Select-String -LiteralPath $log -Pattern "^!" -Quiet) {
        throw "LaTeX reported an error; inspect $log"
    }
    if (Select-String -LiteralPath $log -Pattern 'Overfull\s+\\[hv]box' -Quiet) {
        throw "LaTeX reported an overfull box; inspect $log"
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
Write-Output "Main: $mainSource"
Write-Output "Body: $generatedBody"
