---
name: robotrace-log-viewer
description: MATLAB App Designerのrobotracelogviewerを修正・検証するときに使う。src/test.txtとlogAnalysis.mlappの同期、UI・CSV・設定の回帰確認を扱う。ファームウェア書込みや一般的なログ統計には使用しない。
---

# ロボトレースログビューワーの修正・検証

対象は `F:\Dropbox\Document\robotrace\Log\log`。作業前に同リポジトリのAGENTS.mdと [再発防止手順](references/failure-prevention.md) を読む。既存の利用者変更とバックアップを確認し、依頼に必要な変更だけを行う。

## 変更手順

1. 実在するsrc/test.txt、src/logAnalysis.mlapp、必要な検証スクリプトを列挙する。Git読取は以下の対象限定指定を初回から使う。グローバルsafe.directoryは変更しない。

```powershell
git -c safe.directory=F:/Dropbox/Document/robotrace/Log/log -C F:/Dropbox/Document/robotrace/Log/log status --short
```

2. MATLAB/Pythonの実体・版と権限を確認する。この環境のMATLABはsandboxのApplicationService初期化失敗が既知なので、実行が必要な検証は最初から承認された制限外環境で行う。既存MATLABセッションを終了しない。
3. test.txtのUTF-8とクラス/UI名を保持して対象範囲を修正する。設定・テストCSVは一時コピーを使う。
4. バックアップ後、MATLABの保存APIで一意な新しい一時MLAPPへ反映する。実行コード・App Designer編集用コード・変更したデザイン初期値を同期する。mlappinstallを直接編集しない。
5. 生成成功と新ファイルの存在・ハッシュを確認してから、MATLABで読込・コンポーネント検査・起動・実コールバックを検証する。`which('logAnalysis')` が今回の一時MLAPPの絶対パスと一致することを先にassertする。
6. 検証済みファイルを本体へ反映し、SHA256一致とtest.txtとのコード一致、対象外UIの保持を確認する。
7. 自動コールバック検証と人の実マウス/キー操作を区別して報告する。手動確認が必要な項目を残す。

## 確認範囲

変更箇所に応じて実ログ・旧列ログ・マーカー補正ログ・数値名の不正CSVを使用する。読込失敗後の旧データ保持、タブ、スライダー/キー/クリック、描画、設定保存を確認する。新しい失敗はこのリポジトリのdoc/失敗事例へ記録し、このSkillの該当手順を同じ作業で更新する。
