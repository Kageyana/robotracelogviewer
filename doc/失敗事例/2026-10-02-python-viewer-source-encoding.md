---
type: codex-failure
date: 2026-10-02
task: "ログビューワーの検証クラス作成"
status: resolved
severity: low
tags:
  - codex/failure
---

# Windows PythonでUTF-8ソースの文字コード指定を省略した

## 要約

Path.read_text()の既定文字コードがcp932の環境で、UTF-8のtest.txtを読めず検証クラス生成が停止した。encodingを明示して解決した。

## 発生した状況

- タスク: MATLAB検証クラスをPythonで生成する。
- 実行環境: Windows / Python 3.10。
- 前提条件: test.txtは日本語コメントを含むUTF-8。

## 何を試したか

1. encoding指定なしでPath.read_text()を呼び出した。

## 結果・エラー

```
UnicodeDecodeError: 'cp932' codec can't decode byte
```

## 原因

Windowsのロケール依存の既定文字コードとソースのUTF-8が一致しなかった。

## 解決・回避策

read_text(encoding='utf-8')へ変更し、検証クラスを生成できた。

## 今後の予防策

日本語ソースのPython読み書きではencodingを必ず明示する。BOMの有無が混在する入力を読む場合はutf-8-sigを選ぶ。改行を変換する場合は読込後に正規化し、書込時の形式を明示する。

## 確認方法

生成スクリプトが終了コード0になり、生成したクラスをMATLAB検証で実行できた。

## 関連

- 対象: F:/Dropbox/Document/robotrace/Log/log/src/test.txt
