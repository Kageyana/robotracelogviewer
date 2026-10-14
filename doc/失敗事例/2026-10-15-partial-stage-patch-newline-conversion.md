---
type: codex-failure
date: 2026-10-15
task: Skill更新だけを既存変更から分離してコミットする
status: resolved
severity: low
tags: [codex/failure, git, encoding, skill]
---

# 部分ステージ用パッチの保存時改行変換で適用確認に失敗

## 確認した結果・原因

AGENTS.mdの既存変更を含めずSkill節だけをステージするため、Pythonのdifflibでunified diffを作った。Path.write_text()の改行指定を省略してWindowsで保存したため、LFのパッチがCRLFへ変換され、git apply --cached --checkがpatch does not applyで停止した。HEADのAGENTS.mdはLF90行、CRLF0行だった。索引更新とコミットはまだ行っていなかった。

## 対処・再発防止

GitのHEADから元テキストを取得し、追加する節だけを合成する。生成パッチはwrite_bytes(patch.encode('utf-8'))で保存し、テキストモードの改行変換を避ける。パッチ確認の成功後だけステージし、索引のAGENTS.mdから追加節を除いた内容がHEADと一致することを検証する。作業ツリー全体をaddして既存変更を巻き込まない。

## 確認方法・ステータス

修正後のgit apply --cached --checkは終了コード0。索引を変更しない事前確認でパッチを検証できたため、このパッチ保存手順はresolvedとする。コミットの結果は別途索引内容と作成コミットの対象ファイルで確認する。

## 関連

- [.agents/skills/robotrace-log-viewer/references/failure-prevention.md](../../.agents/skills/robotrace-log-viewer/references/failure-prevention.md)
