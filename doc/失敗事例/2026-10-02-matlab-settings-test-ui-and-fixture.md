---
type: codex-failure
date: 2026-10-02
task: "ログビューワーの設定復元・読込エラー表示・保存失敗対応"
status: resolved
severity: low
tags:
  - codex/failure
---

# 設定テストでスイッチ型とユーザー設定の期待値を誤った

## 要約

テスト用SwitchDirectionを通常のuiswitchで作成したため、型付きプロパティへの代入が失敗した。修正後は現在の設定CSVのdata2がencCurrentNであるのにgyroVal_Zと期待してテストが失敗した。実アプリと同じToggleSwitchを使い、テスト用コピーのdata2を明示して検証を完了した。

## 発生した状況

- タスク: src/test.txtの設定復元・保存失敗処理。
- 実行環境: MATLAB R2023b、非表示uifigure、実装から抽出した一時テストクラス。
- 前提条件: 実設定CSVをテンプレートとして一時ファイルを作成。

## 何を試したか

1. 通常のuiswitchをSwitchDirectionプロパティに設定。
2. uiswitch(fig,'toggle',...)へ修正。
3. 設定復元後にdata2=gyroVal_Zを期待してassert。
4. 実設定CSVを確認し、data2=encCurrentNであることを確認。
5. 一時fixtureのみdata2=gyroVal_Zを明示して全テストを再実行。

## 結果・エラー

```text
SwitchDirectionはmatlab.ui.control.ToggleSwitch型である必要があります。
assert(strcmp(app.Data2DropDown.Value,'gyroVal_Z')) が失敗。
PASS: valid restoration, malformed/duplicate/missing keys, invalid values and equations, no partial application, missing-column fallback, save round trip, locked-file preservation, temp cleanup, invalid destination, cancellation, close after failure
```

## 原因

確認済み: 実アプリのプロパティはToggleSwitch型だが、最初のテスト部品は通常のSwitch型だった。

確認済み: テスト開始時点のユーザー設定はdata2=encCurrentN。過去に見た設定値を期待値へ固定したため、実装の正常な復元を誤って失敗と判断した。

## 解決・回避策

- 実アプリと同じuiswitchのtoggle形式を使用した。
- ユーザー設定ファイルは変更せず、一時CSV内のテスト対象値を明示した。
- MATLAB R2023bの-batch実行で終了コード0と全対象テストのPASSを確認した。

## 今後の予防策

- 型付きUIプロパティのテストではcreateComponentsの生成コードを読み、同じ部品種類を作成する。
- 可変のユーザー設定をテストへ使う際は、復元を確認する対象値を一時コピーで明示するか、読み込んだ値を期待値に使用する。
- 設定保存のテストは一時フォルダーで実施し、実設定CSVを上書きしない。
- Windowsの排他ロックによる置換失敗では、既存ファイルの内容保持と一時CSVの削除も確認する。

## 確認方法

正常復元、不正設定全体の拒否、UIの部分反映防止、表示列欠落時の選択保持、保存読込往復、排他ロック、存在しない保存先、保存キャンセル、保存失敗後のUI削除をassertで確認。終了時の警告ダイアログは一時stubで要求の発行を検証し、実画面操作は未実施。

## 関連

- 対象: F:/Dropbox/Document/robotrace/Log/log/src/test.txt
