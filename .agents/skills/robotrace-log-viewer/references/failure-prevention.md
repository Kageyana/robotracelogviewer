# 13件の失敗から維持する確認

## パス・権限・保存対象

- ファイルやディレクトリはTest-Path -LiteralPathで存在確認してから読む。rgは実在ディレクトリ＋-gを使い、パス引数にワイルドカードやBash波括弧を入れない。
- .git/.agentsがreadのみなら、その更新は初回からrequire_escalatedを使う。ソースのwrite許可から保護領域のwriteを推測しない。承認拒否を別手段で迂回しない。
- MATLABはGet-Commandで実体と版を確認する。既定設定フォルダだけでなくApplicationServiceの制限もあるため、MATLAB_PREFDIR変更だけで直るとは仮定しない。開始したPIDだけを管理する。
- Pythonの日本語ソースはencoding='utf-8'（BOM混在はutf-8-sig）、標準出力もUTF-8。MLAPPコード同期はCRLF/LFだけ正規化して比較し、stripで内容差を消さない。
- 同名logAnalysis.mを実行フォルダへ置かない。生成失敗後に前回の一時MLAPPをテストしない。生成→検証→本体反映は終了コード確認付きの逐次処理とする。

## MATLAB R2023bの型・UI契約

- フォルダ選択キャンセル0はisequal(path,0)で判定し、string/charパスとの==比較をしない。
- DropDown Itemsはstring配列かcharのcell配列、ItemsDataは元ファイル名と対応させる。TextAreaは混在入力をstring経由のcellstrへ揃える。
- テストUIはcreateComponentsと同じ部品型を使う。型付きToggleSwitchへ通常Switchを代入しない。
- UIAxes.CurrentPointは読取専用。クリックテストはIntersectionPointを持つイベントを登録済みButtonDownFcnへ渡し、実装は必要ならクリック元CurrentPointを読む。
- 新規UIAxesのDesignTimePropertiesはispropで確認し、無いときは当該MATLAB版のApp Designer初期化手順に沿いaddprop後にモデル/CodeNameを設定する。実行コードだけで追加済みとしない。
- 同名グラフ・変数変更後のクリック、click OFF、行選択と現在地/縦線同期、先頭末尾境界を確認する。

## CSV・軌跡

- 空メタ情報行と行自体の欠落を区別する。空メタはstrings(0,1)、空列名は拒否する。空文字をtextscanへ渡さない。
- detectImportOptionsのDataLines名前付き引数をR2023bへ渡さず、返されたoptions.DataLines=[3 Inf]へ設定する。使用版で実行確認する。
- 数値fixtureは99999.csv等のASCII数字名にする。NaN/Infはcompose('%g',value)等で明示文字列にし、保存後の行数と当該フィールドを読む。赤ランプだけで目的の検証到達としない。
- 2026-10-17のユーザー指示以降、XYの距離・速度はSettingタブの速度換算式を正とする。diff有効時は式を累積距離[mm]として直接使い、diff無効時は速度[mm/s]を時間[s]で積分する。encTotalOptimalやencoderPulsePerMeterを暗黙に使わない。imuAngle_Zがあれば保存済みdeg角度と区間両端平均角度を使う。選択した累積距離の負差分は保持し、非有限値は拒否する。
- 生左右平均・補正済み距離・速度直接入力を切り替え、換算式の倍率変更がXYと表示速度の両方へ反映されること、累積距離入力を微分後に再積分しないこと、diff状態の設定保存/再読込と旧設定false既定を確認する。保存角度がない旧ログのgyro換算とdiff無効時の従来cumtrapzもテストする。角度degをrad/s入力ノブと混同しない。
- 一次、マーカー補正二次、旧13列、非有限距離の各ケースで独立XY計算と比較する。源CSVを変更しない。

## 独立したテスト状態

- ケースごとに加工スイッチ・フラグ・選択値・保存先を明示して戻す。定数列に前ケースの正規化を持ち越さない。
- ユーザー設定を期待値へ固定せず、一時コピーで対象値を設定する。実設定を上書きしない。
- 失敗入力は目的の段階とエラー識別子を確認する。NaNを与えてもmin/maxで有限値に変わる可能性があるため、実際の保存値と失敗経路を検証する。
- Y軸の全ゼロ・正規化・トレンド除去・none、失敗後データ保持、設定の部分反映防止、排他ロック時の元ファイル保持/一時CSV削除を確認する。
- MLAPP再読込で実行/編集用コード、コールバック、デザイン初期値、コンポーネント名・数・配置を検査する。自動テストのPASSを手動操作確認済みと報告しない。

## 既存変更を分けてコミットする場合

部分ステージ用パッチはGitのHEADを元に必要な節だけ合成する。Pythonのwrite_textはWindowsで改行を変換するため、パッチはwrite_bytes(patch.encode('utf-8'))等で明示的に保存する。git apply --cached --checkの成功後だけ適用し、索引の追加節以外がHEADと一致することを確認する。既存の別作業の変更を含めてAGENTS.md全体をaddしない。

## 同期前に生成領域の差がある場合

- 既存test.txtとMLAPPはApp Designerの生成領域・宣言/コールバック順が異なる場合がある。全体不一致時に上書きへ進まず、XML独立読出しと関数単位差分で編集処理が同じか確認する。未解決の処理差では停止する。生成後は実行コード全体・編集用コードの一致とUI名/配置/初期値保持を必須とする。詳細は[2026-10-17事例](../../../../doc/失敗事例/2026-10-17-mlapp-generated-code-baseline.md)を参照する。

## MLAPP本体の置換が共有違反で停止した場合

- 元本体を削除せず、バックアップ・検証済み成果物・残存一時ファイルのSHA256を照合する。Windows Restart Managerの読取API等で使用状態を確認し、利用者の既存プロセスを終了しない。一時ファイルの再利用は検証済みハッシュ一致時に限る。WinError32だけ短い有限回数で再試行し、各回で元本体の変更を検査する。成功後も本体のハッシュとXMLコード一致を検証する。詳細は[2026-10-17共有違反事例](../../../../doc/失敗事例/2026-10-17-mlapp-publish-sharing-violation.md)を参照する。
