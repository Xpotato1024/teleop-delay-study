# 生成結果

標準実験の生成物は、リポジトリrootで次を実行すると保存されます。

```matlab
result = run_standard_experiment();
```

保存先は `results/generated/<experiment_id>/<run_id>/` です。CSVとMATは同一run directoryへatomicに保存され、保存後に再読込検証されます。同じ条件を再実行した場合は別の `run_id` が割り当てられ、既存runを暗黙に上書きしません。

`results/generated/` 以下は生成物としてGit管理対象外です。完全runにはaggregate CSVと全case時系列を含むMATが保存され、失敗runは `failed/` 以下へdiagnostic CSV/MATとして保存されます。
