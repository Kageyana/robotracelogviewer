---
type: codex-failure
date: 2026-10-03
task: "ログビューワーへの5行ラインセンサー画像追加"
status: resolved
severity: low
tags:
  - codex/failure
---

# 新規UIAxesにはApp Designerの動的プロパティがない

## 要約

MATLABで作成したUIAxesへDesignTimePropertiesを直接代入したため、MLAPP反映用の一時ファイル生成が停止した。App Designerの実装に合わせてaddpropで追加した後、DesignTimePropertiesモデルを設定して解決した。

## 発生した状況

- タスク: LineSensorAxesを実行コードとデザイン情報へ追加する。
- 実行環境: Windows / MATLAB R2023b。
- 前提条件: uiaxesで新しく生成した軸。既存のデザイン側UIAxesと異なりDesignTimePropertiesは存在しない。

## 何を試したか

1. 新規UIAxesにDesignTimePropertiesを直接代入した。
2. 生成処理の完了前に実行テストを開始したため、古い一時MLAPPを検証してしまった。

## 結果・エラー

```
UIAxesのプロパティDesignTimePropertiesが認識されない
logAnalysisのプロパティLineSensorAxesが認識されない
```

## 原因

確認済み: DesignTimePropertiesは通常のUIAxesの固定プロパティではなく、App Designerが動的に追加する。生成失敗時に既存の一時MLAPPが残っていた。

## 解決・回避策

addprop(sensorAxes,'DesignTimeProperties')の後にappdesigner.internal.model.DesignTimePropertiesを設定し、CodeNameをLineSensorAxesにした。生成成功とコード・コンポーネント検証の終了コード0を確認してから起動テストを再実行した。

## 今後の予防策

新規デザインコンポーネントを追加する際はispropでDesignTimePropertiesの有無を確認し、App Designerの初期化手順に合わせる。一時MLAPPの生成と起動テストは逐次実行し、生成失敗時には古いファイルを検証しない。起動前にwhichと追加プロパティの存在を確認する。

## 確認方法

MATLAB R2023bで実行コード・編集用コード・新規軸の配置を再読込検証。実際のMLAPPで5行×10列の値、0白/4096黒、選択連動、拡大配置を確認。端点・短いログ・不正値・列欠落の検証もPASS。App Designerのデシリアライズとコンポーネント検証が警告なしで成功し、終了コード0。出力した画面で配置を目視確認した。

## 関連

- 対象: F:/Dropbox/Document/robotrace/Log/log/src/logAnalysis.mlapp
- MATLAB参照: appdesigner.internal.controller.DesignTimeController.addDesignTimeProperties
