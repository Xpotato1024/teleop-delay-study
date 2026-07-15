# 作業ガイド

## 最初に読む順序

1. `AGENTS.md`
2. `research/problem_statement.md`
3. `docs/architecture.md`
4. `skills/matlab/SKILL.md`

## 基本規約

- `main` への直接commitは禁止する。通常は branch、commit、PR、human merge の順で進める。
- 文書とコードは日本語中心とし、MATLAB識別子は英語にする。
- 数値や結果を捏造しない。乱数シード、条件、ソルバー、時間刻みを記録する。
- 研究上の判断変更は `research/log.md` に追記する。
- 生成結果は `results/`、レポート掲載図は `report/figures/` に置く。
- 実装変更時は関連文書のみ更新し、無関係な文書を広範囲に変更しない。
- MATLAB関連作業では `skills/matlab/SKILL.md` を参照する。
