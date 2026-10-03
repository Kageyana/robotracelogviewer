---
type: codex-failure
date: 2026-10-01
task: "ログビューワーの読み込み中断・Y軸範囲・選択保持の修正"
status: resolved
severity: low
tags:
  - codex/failure
---

# MATLAB検証でパス比較とドロップダウン項目の型エラーを検出

## 要約

MATLAB R2023bで変更対象メソッドを検証したところ、既存のstringパスと数値0の比較、および追加したcell内stringのItems設定が失敗した。実ログの確認では完了メッセージのcell内stringもTextAreaに拒否された。型に合わせて修正し、対象テストの成功を確認した。

## 発生した状況

- タスク: F:/Dropbox/Document/robotrace/Log/log/src/test.txt の修正。
- 実行環境: Windows、MATLAB R2023b、非表示uifigureを使った一時テストクラス。
- 前提条件: 設定CSVから取得したパスはstring。空ログ一覧では案内項目を表示する。

## 何を試したか

1. 修正対象メソッドを一時クラスへコピーし、ログ更新・削除・読み込み失敗・解析グラフのテストを実行。
2. パス判定をisequal(path,0)へ変更。
3. Itemsの案内項目をcell内stringからcell内charへ変更。
4. 同じテストを再実行。
5. 実ログ12837の正常読込と換算エラー時の中断を追加検証。setTexttareaの入力をcellstrに統一して再実行。

## 結果・エラー

```text
string と double の比較はサポートされていません。
Items は文字ベクトルのcell配列、またはstring配列である必要があります。
PASS: selection preservation, deletion fallback, load failure interruption, zero/normalized/detrended Y limits, none resets
PASS: real log 12837 loaded; late conversion failure preserves previous data and interrupts reload
```

## 原因

確認済み: rootDir == 0はstringパスに使えない。Items = {"not found files"}はcell内stringとなりUIの受入型に一致しない。

## 解決・回避策

キャンセル値0はisequalで判定する。Itemsのcell形式にはcharを入れ、ItemsDataにはcellstrで元ファイル名を保存する。
setTexttareaは入力をstring経由のcellstrへ統一してから蓄積する。実ログ12837の5593行を読み込めること、後段の角速度換算エラー時も直前のログ・時刻・速度が維持されることを確認した。

MATLABのsandbox起動では設定フォルダーアクセス拒否とApplicationService初期化失敗も発生した。一時MATLAB_PREFDIRだけでは解消せず、承認された通常環境での実行によりテストを完了した。サービス初期化失敗の詳細原因は未確定。

## 今後の予防策

- パス判定の変更時は、設定読込後のstring、フォルダー選択後のchar、キャンセル値0を確認する。
- UI一覧の変更時は、空一覧と実ファイル名のItemsData復元をMATLABで確認する。
- メッセージ表示を変更した場合は、char・string・cellが混在する入力をcellstrへ統一し、実ログの読込完了とエラー表示を確認する。
- Y軸変更時は全ゼロ、正規化、トレンド除去、none選択を確認する。
- sandboxでMATLABのサービス初期化が止まったら、今回起動したプロセスだけを終了し、通常環境で承認された検証を行う。既存ユーザーセッションは終了しない。

## 確認方法

MATLAB R2023bの-batchで、test.txtから抽出したメソッドと非表示UIを使用してassertを実行。終了コード0と上記PASSを確認。

## 関連

- 対象: F:/Dropbox/Document/robotrace/Log/log/src/test.txt
