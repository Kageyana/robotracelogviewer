---
type: codex-failure
date: 2026-10-01
task: "MATLABログビューワーのコードレビュー"
status: resolved
severity: low
tags:
  - codex/failure
---

# ログビューワーのGit状態確認が所有者チェックで拒否された

## 要約

ログビューワーのリポジトリで git status が dubious ownership により失敗した。対象パスをコマンド単位で safe.directory に指定すると確認できた。

## 発生した状況

- タスク: src/test.txt の静的レビューと既存変更の確認。
- 実行環境: Windows PowerShell、Codex sandbox。
- 前提条件: リポジトリ所有者と実行ユーザーが異なる。

## 何を試したか

1. git -C F:/Dropbox/Document/robotrace/Log/log status --short を実行。
2. git -c safe.directory=F:/Dropbox/Document/robotrace/Log/log -C F:/Dropbox/Document/robotrace/Log/log status --short を実行。

## 結果・エラー

```text
fatal: detected dubious ownership in repository
```

初回は終了コード1。2回目は終了コード0で既存変更を取得できた。

## 原因

Gitのエラー出力で、リポジトリ所有者とsandbox実行ユーザーの不一致を確認した。

## 解決・回避策

ユーザーが明示した対象リポジトリだけを -c safe.directory で指定する。グローバル設定は変更しない。

## 今後の予防策

このログビューワーでGitの読み取りを行う際は、上記のコマンド単位の指定を使用する。終了コード0と状態出力を確認してから既存変更の有無を判断する。

## 関連

- 対象: F:/Dropbox/Document/robotrace/Log/log/src/test.txt
