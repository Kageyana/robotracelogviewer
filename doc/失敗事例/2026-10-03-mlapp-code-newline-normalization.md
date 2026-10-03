---
type: codex-failure
date: 2026-10-03
task: "MLAPP反映後のコード一致検証"
status: resolved
severity: low
tags:
  - codex/failure
---

# MLAPP保存時の改行変換でコード一致assertが失敗した

## 要約

CRLFのtest.txtとMLAPPから読み出したLFのコードを直接比較し、コード内容が同じなのに一致検証が失敗した。改行をLFへ正規化して比較し、独立したXML読み出しでも内容一致を確認した。

## 発生した状況

- タスク: MATLAB FileWriterで反映したMLAPPのコード一致確認。
- 実行環境: MATLAB R2023b / Windows。
- 前提条件: test.txtはUTF-8 CRLF、MLAPPにはXML文書としてコードが保存される。

## 何を試したか

1. readMATLABCodeTextの戻り値とfileread(test.txt)をisequalで直接比較した。

## 結果・エラー

```
Executable code mismatch
```

## 原因

確認済み: 実行コードは同じだが、保存とXML読み込みで改行がLFへ正規化された。

## 解決・回避策

CRLFをLFへ置換して比較。PythonでMLAPPのmatlab/document.xmlを読み、test.txtの正規化済み内容と一致することも確認した。

## 今後の予防策

コード同期の一致検証では、改行のみを正規化して比較する。strip等で空白やコード内容まで消さない。編集用コード、コールバック、デザイン初期値は別途一致検証する。

## 確認方法

MATLABの再読込でコード一致、編集用コード一致、3つの初期値と全コンポーネント名・数・位置の保持を確認。終了コード0。最終MLAPPのXMLコードもtest.txtと一致。

## 関連

- 対象: F:/Dropbox/Document/robotrace/Log/log/src/test.txt
