# Issue #9 snapshot provenance

| 項目 | 値 |
|---|---|
| repository | `Xpotato1024/teleop-delay-study` |
| Issue | `#10` Phase A（source: `#9`） |
| source commit | `b1aa629911b17de80032de1dd8a6c9471da63b1c` |
| source artifact directory | `results/generated/analysis/i8v1_n40_2353bb12/issue10_targeted_20260724` |
| source experiment ID | `i8v1_n40_2353bb12` |
| source input run ID | `20260723T013408166Z__0b95b1a` |
| source input SHA-256 | `E21B8B7486C89010A390CBF52BFF6286E6B217A5D911544D5102E39D87CDDEC8` |
| convergence artifact path | `results/generated/analysis/i8v1_n40_2353bb12/i9v1_i8v1_n40_2353bb12_A3E247DF0482/20260723T120651252Z__3cc0b6b/analysis_tables.mat` |
| convergence artifact SHA-256 | `157D22F59D10CA1F3972FFF7F5B5E7BAF8FFBCFE1909E5750891631F89D027F2` |
| source artifact manifest SHA-256 | `156099C172679D2E72FBE04FC1D134CC1EEEDE7CD54BCA7629DEE359B18CEED1` |
| 日本語font | `Noto Sans JP` |
| figure count | 8（PNG 8、vector PDF 8） |
| table count | 11 CSV |
| copy method | 図01/08は保存済みartifactからrendererで再生成後、4 binaryをfilesystem copy。図02–07と11 CSVは既存snapshot byteを維持。 |
| hash verification result | 図01/08のcopy対象4 fileでsource/destination SHA-256 mismatch 0。 |
| known limitations | 標準40 caseとconvergenceは再実行していない。理論候補線は実測境界または文献値ではない。boundaryは離散gridの隣接pairであり補間境界ではない。 |

追跡file単位のprovenance、size、SHA-256は[tracked_file_manifest.csv](tracked_file_manifest.csv)に記録します。同manifest自身は自己参照しません。
