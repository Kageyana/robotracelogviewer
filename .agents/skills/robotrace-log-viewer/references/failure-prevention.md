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
- imuAngle_Zがあれば保存済みdeg角度を優先し、encTotalOptimalの符号付き差分と両端平均角度でXYを計算する。補正距離の負差分を0へ丸めたり逆走として一律拒否したりしない。非有限値は拒否する。
- encoderPulsePerMeterと旧列のfallbackを確認する。保存角度がない旧ログの従来gyro換算/cumtrapzも同時にテストする。角度degをrad/s入力ノブと混同しない。
- 一次、マーカー補正二次、旧13列、非有限距離の各ケースで独立XY計算と比較する。源CSVを変更しない。

## 独立したテスト状態

- ケースごとに加工スイッチ・フラグ・選択値・保存先を明示して戻す。定数列に前ケースの正規化を持ち越さない。
- ユーザー設定を期待値へ固定せず、一時コピーで対象値を設定する。実設定を上書きしない。
- 失敗入力は目的の段階とエラー識別子を確認する。NaNを与えてもmin/maxで有限値に変わる可能性があるため、実際の保存値と失敗経路を検証する。
- Y軸の全ゼロ・正規化・トレンド除去・none、失敗後データ保持、設定の部分反映防止、排他ロック時の元ファイル保持/一時CSV削除を確認する。
- MLAPP再読込で実行/編集用コード、コールバック、デザイン初期値、コンポーネント名・数・配置を検査する。自動テストのPASSを手動操作確認済みと報告しない。

## 既存変更を分けてコミットする場合

部分ステージ用パッチはGitのHEADを元に必要な節だけ合成する。Pythonのwrite_textはWindowsで改行を変換するため、パッチはwrite_bytes(patch.encode('utf-8'))等で明示的に保存する。git apply --cached --checkの成功後だけ適用し、索引の追加節以外がHEADと一致することを確認する。既存の別作業の変更を含めてAGENTS.md全体をaddしない。
