---
type: codex-failure
date: 2026-10-02
task: "ログビューワーの時間・換算式検証と初期値修正"
status: resolved
severity: low
tags:
  - codex/failure
---

# MATLABの不正時間テストでNaN行が空行になった

## 要約

NaNを含むテストCSVが正常と判定されたが、生成ファイルでは対象行全体が空行になっていた。composeでNaNを明示的な文字列にし、時間異常の拒否を確認した。また、DataLinesをdetectImportOptionsの引数に渡すとR2023bで失敗したため、返されたオプションのプロパティへ設定した。

## 発生した状況

- タスク: src/test.txtの換算式・時間検証。
- 実行環境: MATLAB R2023b、非表示UIと一時CSV。
- 前提条件: 実ログ先頭3データ行から重複・逆行・負数・Inf・NaNの時間ケースを作成。

## 何を試したか

1. string(NaN)で列値を置換し、joinとwritelinesでCSVを作成。
2. NaNケースが受理されたため、読込値と生成ファイルを確認。
3. compose('%g',value)でNaN文字列を明示して再生成。
4. DataLinesをオプションプロパティへ設定し、実ログ・異常CSV・換算式テストを再実行。

## 結果・エラー

```text
NaNケース: CSVの対象行が空行。読込時刻は5,15の2行のみ。
MATLAB:textio:textio:UnknownParameter: DataLines
PASS: real log 12837, current defaults, whitespace/sign/exponent syntax, invalid syntax and columns, zero division and overflow, duplicate/reversed/negative/nonfinite time, finite differences, failure data preservation
```

短いCSVのメタ情報をそのまま表示した際はTextAreaの型エラーも発生した。テスト側のメタ情報を列数に合わせた文字列だけに統一して回避し、正常ケースも検証した。汎用的なメタ情報表示への対応は今回の変更範囲外。

## 原因

確認済み: NaNケースの生成ファイルは対象行が空行だった。string変換・結合・出力の連鎖でmissingが空行として保存されたため、テストはNaN値を実際に入力できていなかった。

確認済み: R2023bのdetectImportOptionsはDataLinesの名前付き引数を拒否した。返されたDelimitedTextImportOptionsのDataLinesプロパティは設定できた。

## 解決・回避策

- 不正値をCSVへ保存するテストではcomposeでNaN/Infを明示的な文字列にする。
- detectImportOptionsでVariableNamesLine=2を指定し、返されたオプションのDataLines=[3 Inf]を設定してreadtableへ渡す。test.txtへ反映済み。
- 異常ケースではfalseだけでなくInvalidTimeまたはInvalidColumnのエラー識別子も確認する。

## 今後の予防策

- NaN/InfのテストCSVを作る場合は、保存後の行数と当該フィールドを確認してから読込テストを実行する。
- メタ情報と数値本体の列数・型が異なる短いfixtureでは、検証対象以外の表示エラーと区別するためメタ情報を明示的なテキストへ揃える。
- 読込オプションを変更した場合はMATLABの使用バージョンで実行し、実ログ12837と短い異常CSVの両方を確認する。

## 確認方法

MATLAB R2023bの-batch実行で終了コード0と上記PASSを確認。実ログ5593行、各種換算式、異常時間、既知の5ms差分速度、差分オーバーフロー、失敗時の前データ保持をassertで検証した。

## 関連

- 対象: F:/Dropbox/Document/robotrace/Log/log/src/test.txt
