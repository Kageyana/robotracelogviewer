---
type: codex-failure
date: 2026-10-03
task: "test.txtからMLAPPへの反映"
status: resolved
severity: low
tags:
  - codex/failure
---

# MLAPP起動テストが同名の検証用Mファイルに遮られた

## 要約

構文確認用logAnalysis.mをテストスクリプトと同じフォルダに置いたため、MLAPPをaddpathしても同名Mファイルが優先された。Mファイルを別フォルダへ隔離し、whichで実行対象をassertしてMLAPPの起動確認をやり直した。

## 発生した状況

- タスク: 更新コードをlogAnalysis.mlappへ反映し実行する。
- 実行環境: Windows / MATLAB R2023b -batch。
- 前提条件: runのスクリプト所在フォルダに同名Mファイルが存在し、MLAPPは別のstagedフォルダにある。

## 何を試したか

1. stagedフォルダをaddpathし、logAnalysisを起動した。
2. アイコン画像の警告から解決先を確認した。

## 結果・エラー

同じフォルダにあるrotate.jpg / expand.jpgが見つからない警告が出た。実行対象が構文確認用Mファイルだったため、最初のPASSはMLAPPの起動証明として扱えなかった。

## 原因

確認済み: MATLABはカレントフォルダの同名Mファイルをパス上のMLAPPより優先した。

## 解決・回避策

構文確認用Mファイルをchecked-codeフォルダへ移動。which('logAnalysis')がstaged/logAnalysis.mlappと一致するassertを起動前に追加して再実行した。

## 今後の予防策

MLAPP検証では、同名Mファイルを実行フォルダへ置かない。起動前にwhichの絶対パスをassertする。画像警告を単なる不足として処理せず、アプリ本体の解決先を確認する。

## 確認方法

実際のMLAPPで5593行実ログ、初期値、タブ、スライダー、回転、ショートカット、フラグ、解析、フォルダ初期位置、再読込、一時設定保存を確認。終了コード0。App Designerのデシリアライズとコンポーネント検証も警告なしで成功。検証済みファイルと本ファイルのSHA-256一致を確認。

## 関連

- 対象: F:/Dropbox/Document/robotrace/Log/log/src/logAnalysis.mlapp
