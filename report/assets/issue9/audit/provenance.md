# Issue #9 snapshot provenance

| 項目 | 値 |
|---|---|
| repository | `Xpotato1024/teleop-delay-study` |
| Issue | `#10` Phase A（source: `#9`） |
| source commit | `3cc0b6bc383b6f614030011147f44e1849b76b3a` |
| source artifact directory | `results/generated/analysis/i8v1_n40_2353bb12/i9v1_i8v1_n40_2353bb12_A3E247DF0482/20260723T120651252Z__3cc0b6b` |
| source experiment ID | `i8v1_n40_2353bb12` |
| source input run ID | `20260723T013408166Z__0b95b1a` |
| source input SHA-256 | `E21B8B7486C89010A390CBF52BFF6286E6B217A5D911544D5102E39D87CDDEC8` |
| source artifact manifest SHA-256 | `FEDA8738168F53AF38E606173AA5A1DA5F4DD8AD552DD0C42385B1C8F0F51CB6` |
| figure count | 8（PNG 8、vector PDF 8） |
| table count | 11 CSV |
| snapshot creation commit | このsnapshotを初回追加したcommit。SHAは本fileを含むcommit自身への循環参照を避け、Git履歴で確認する。 |
| copy method | filesystem binary copy。画像・PDF・CSVの変換、再encoding、再出力なし。 |
| hash verification result | source sidecar 27 rowsのsize/hash再計算 mismatch 0。copy対象27 filesのsource/destination SHA-256 mismatch 0。 |
| known limitations | 標準40 caseとconvergenceは再実行していない。`q≈1.895`は理想正弦波の解析候補であり文献値・実測境界ではない。boundaryは離散gridの隣接pairであり補間境界ではない。 |

追跡file単位のprovenance、size、SHA-256は[`tracked_file_manifest.csv`](tracked_file_manifest.csv)に記録します。同manifest自身は自己参照しません。
