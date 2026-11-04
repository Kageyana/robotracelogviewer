---
type: codex-failure
date: 2026-10-04
task: "ログ12939のInvalidDistance修正"
status: resolved
severity: low
tags:
  - codex/failure
---

# マーカー補正による距離減少を逆走と判定して描画を中断した

## 要約

ログ12939.csvの読み込みは成功したが、calcCourseplotがencTotalOptimalの減少をInvalidDistanceとして拒否した。補正済み距離の差を符号付きで積算し、非有限値だけを拒否するよう修正した。

## 発生した状況

- 対象: src/test.txt、src/logAnalysis.mlapp。
- 環境: Windows、MATLAB R2023b。
- ログ: 12939.csv、4678行、optimalTrace=2、requestedMode=DISTANCE、emcStop=0。

## 確認できた結果

ログ行510、1463、2415、3365、4316でencTotalOptimalがそれぞれ2316、3011、3058、2645、2803パルス減少した。該当行はすべてcourseMarker=3で、左右の生エンコーダ積算値は増加していた。

## 原因

ファームウェアのControl_ApplyMarkerCorrection_pはencTotalOptimalから補正量を差し引く。courseAnalysis.cがマーカー補正時にこれを呼び出す。補正済み距離に単調増加を要求するビューワーの仮定が誤っていた。

## 対処

負の差分を保持して記録角度との区間積算を行う。差分を0へ丸めず、補正済みCSV座標の計算方式を維持する。NaN・Infによる中断は維持する。ファームウェアと元ログは変更しない。

## 再発防止策と確認方法

累積値の検証条件を決める前に、更新・リセット・位置補正のすべての書き込み元を確認する。マーカー補正を含む二次ログをテスト対象へ加え、負の差分を含む独立座標計算との一致を確認する。一次ログ・旧列ログ・非有限距離の拒否も同時に検証する。

検証スクリプト: C:/Users/Natsuki/AppData/Local/Temp/viewer-distance-20261004/stage_and_test.m。
MATLAB R2023bの実際の一時MLAPPで12939（減少5箇所）、12936（一次）、12878（旧列）を起動し、独立座標計算との一致を1e-6 mm以内で確認。12939のCSV保存座標との差はX最大0.001215 mm、Y最大0.001046 mm。スライダー・3行ホイール・1行矢印キー・回転・ショートカットのコールバックも通過。数字名NaN距離ログがInvalidDistanceで拒否されることを別実行・終了コード0で確認。構文、実行/編集用コード一致、デザイン配置保持を検証し、本体へ反映後にSHA-256一致を確認した。人による手動操作は未確認。

## 関連

- 2026-10-03-viewer-sparse-yaw-distortion.md
- robotrace_v2/Core/Src/control.c: Control_ApplyMarkerCorrection_p
- robotrace_v2/Core/Src/courseAnalysis.c: マーカー位置による補正

## 検証用CSVの名前による失敗

初回のNaNテストは`bad.csv`で作成したため、数字のログ番号だけを列挙する既存処理により選択対象にならず、InvalidDistanceのassertに失敗した。赤ランプだけでは距離検証が実行された証拠にならない。`99999.csv`へ改名し、エラー識別子まで確認するテストへ修正した。AGENTS.mdにも数字のファイル名を使う条件を追記した。
