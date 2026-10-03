---
type: codex-failure
date: 2026-10-01
task: "ログビューワーのスライダー・矢印キー・クリック操作修正"
status: resolved
severity: low
tags:
  - codex/failure
---

# UIAxesのCurrentPointに代入してクリックテストが失敗した

## 要約

MATLAB R2023bの非表示UIテストでCurrentPointにクリック座標を代入したが、読み取り専用のため失敗した。クリックイベントのIntersectionPointを入力として使う処理とテストへ変更し、対象テストの成功を確認した。

## 発生した状況

- タスク: src/test.txtのグラフクリックと位置更新の確認。
- 実行環境: MATLAB R2023b、非表示uifigureとUIAxes。
- 前提条件: UIAxesのCurrentPointにテスト座標を書き込めると仮定した。

## 何を試したか

1. スライダー・キー操作を確認後、UIAxes.CurrentPointにクリック座標を代入。
2. getTimeIndexにIntersectionPointがあるイベントを渡して確認する方式に変更。
3. 同じテストを再実行。

## 結果・エラー

```text
UIAxesのCurrentPointプロパティは読み取り専用のため設定できません。
PASS: slider, row indexing with duplicate times, boundaries, arrow keys, identical graph titles, variable changes, course clicks, click OFF, marker synchronization
```

終了コード0でスライダー、重複時刻の行選択、先頭・末尾の矢印キー、同じタイトルのグラフ、変数変更後のクリック、コースクリック、クリック無効化、現在地マーカーと縦線の同期を確認した。

## 原因

確認済み: UIAxes.CurrentPointは読み取り専用。書き込み可能というテスト側の仮定が誤っていた。

## 解決・回避策

実装はクリックイベントにIntersectionPointがあればその座標を使い、なければクリック元の軸のCurrentPointを読み取る。テストはIntersectionPointを含むイベントを登録済みコールバックへ渡す。test.txtにも反映済み。

## 今後の予防策

- UIイベントのテストでは読み取り専用UIプロパティを書き換えず、イベントの入力値を使用する。
- 同名グラフと変数変更後の登録済みButtonDownFcnを実際に呼び、選択行とマーカー・定数線の一致をassertで確認する。
- 本テストはコールバック入力のシミュレーション。mlappへ手動反映後の実マウス操作は別途確認する。

## 関連

- 対象: F:/Dropbox/Document/robotrace/Log/log/src/test.txt
- イベント仕様: https://uk.mathworks.com/help/matlab/ref/matlab.graphics.chart.primitive.graphplot-properties.html
