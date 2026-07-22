# Issue #8 完全要因実験runnerと結果保存 実装報告

## 実装内容

- `run_standard_experiment.m` をclean MATLAB session向けのroot entrypointとして追加。
- `teleopdelay.experiment` packageへstandard manifest生成、canonical case ID、manifest validation、単一case実行、逐次runner、aggregate table、metadata、atomic persistenceを追加。
- Issue #7のreference plant、evaluation window、metrics schema、Simulink loggingを変更せず再利用。
- 標準条件は `circle` と `lissajous_1_2`、`dt = fixed step = 0.005 s`、sample period `0.020 s`、time constant `0.10 s`、delay 5値、omega 4値、10 cycles、warm-up 2 cycles、solver `ode4`。

## 設計判断

case IDはloop indexではなく、manifestの全case定義fieldを固定順序と固定数値表現でcanonical化して生成します。manifest最終順はtrajectory、delay、omegaの順です。experiment IDはschema versionとcanonical case条件全体から決定論的に生成し、run IDだけがUTC timestampとGit short SHAを含みます。

case failureはcase ID、condition row、元のerror identifier/messageをaggregateへ残し、残りのcaseを継続します。失敗runはdiagnostic CSV/MATだけを保存して `teleopDelay:ExperimentIncomplete` を送出します。

complete CSV/MATは同一filesystemのtemporary directoryへ書き込み、round-trip validation後にfinal run directoryへrenameします。MATには全caseのconfig、trajectory、simulation、evaluationを保存します。生成物は `results/generated/` 以下でGit管理対象外です。

## 検証結果

環境は MATLAB R2025b Update 5 (`25.2.0.3177638`) / Simulink `25.2` です。

- focused manifest: 6/6
- focused aggregation/persistence: 3/3
- focused representative runner: 1/1
- full unit: 36/36
- full model: 15/15
- full integration: 5/5
- smoke test: 成功
- `run_project` 3形式: 成功（既存runtime contract testで確認）
- 全src MATLAB fileの `checkcode -id`: 0 messages
- `git diff --check`: 成功
- representative case（circle, omega=4.0, delay=0.20）の2回実行における全metrics最大絶対差: `0`
- standard 40 case: 40/40 success、40 rows、CSV/MAT round-trip成功
- standard case内訳: circle 20、lissajous_1_2 20、各delay 8、各omega 10
- standard metadata: success 40、failed 0、run status `complete`
- generated artifact: `results/generated/i8v1_n40_2353bb12/20260722T173019944Z__c536477/`
- CSV SHA-256: `E7D64E5F5A072ADB2F717039CF46C5DA5EF6D196807A5C63ADEAB8446A434DA9`
- MAT SHA-256: `91712EA3E4B4A8D400059C32CFA09FEE6B2876A13A114B5EA8769C2C892E186C`
- generated file size: CSV `18,483` bytes、MAT `58,803,422` bytes
- model SHA-256: plant `7F64F14BBA907D96A26CAAE622A91E6A92B7A0F915B8009F39EF1A47E3C338C6`、communication `E9EF1A331C275DC6117DE1B7B6A2786745541EC71EB3D3BA5DF9DCFE14776417`、system `8DE4EFE52DCADA1FE8202519C08C1CDC9A893307BFE59E7E4DC20718E866F5DB`
- path、current directory、model close、base workspace、tracked model hash: 成功。generated/failed temporary artifactはGit statusに現れていない。

## artifact保存契約

complete:

```text
results/generated/<experiment_id>/<run_id>/<experiment_id>__aggregate.csv
results/generated/<experiment_id>/<run_id>/<experiment_id>__results.mat
```

failed:

```text
results/generated/<experiment_id>/failed/<run_id>/<experiment_id>__diagnostic.csv
results/generated/<experiment_id>/failed/<run_id>/<experiment_id>__diagnostic.mat
```

同一条件の再実行は既存runを暗黙に上書きしません。
