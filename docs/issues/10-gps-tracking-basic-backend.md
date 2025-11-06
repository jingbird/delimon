# Issue #10: GPS計測機能の基本実装（後半）

### 背景 / 目的
配送業務の移動距離を正確に計測するため、リアルタイム距離計算・バックグラウンドトラッキング・配送セッションのDB保存を実装する。

- **依存**: #9
- **ラベル**: `frontend`, `backend`, `feature`, `gps`

---

### スコープ / 作業項目

#### 1. expo-task-managerの導入
- `expo-task-manager@12.0+` をインストール
- バックグラウンドタスクの定義・登録

#### 2. バックグラウンド位置情報トラッキング
- 5秒間隔で位置情報を取得
- フォアグラウンド・バックグラウンド両方で動作
- 座標間の距離を計算して累積（Haversine公式を使用）

#### 3. 距離計算ロジック
- `src/utils/geolocation.ts` に距離計算関数を実装
- 2点間の緯度経度から距離を算出（km単位）
- 累積距離をリアルタイムで更新

#### 4. 配送セッションのDB保存
- 配送終了時に以下の情報を `delivery_sessions` テーブルにINSERT
  - 走行距離（km）
  - 所要時間（分）
  - 開始時刻・終了時刻
  - ユーザーID・キャラクターID

#### 5. バックグラウンド通知
- 配送中に通知を表示（例: 「配送中: 12.5km」）
- Androidの常駐通知として表示（タップでアプリ起動）

#### 6. GPS信号チェック
- GPS精度が低い場合に警告メッセージを表示
- 精度50m以上の場合に「GPS信号が弱いです」と警告

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] `expo-task-manager@12.0+` を導入し、バックグラウンドで位置情報取得が可能
- [ ] 5秒間隔で位置情報を取得し、座標間の距離を計算して累積できる
- [ ] 配送終了時に走行距離・所要時間を `delivery_sessions` テーブルにINSERT完了
- [ ] バックグラウンド実行中に通知「配送中: XX.Xkm」を表示
- [ ] GPS信号が弱い場合（精度50m以上）に警告メッセージを表示

---

### テスト観点

#### 手動テスト
- 配送開始後、実際に移動（徒歩・自転車・車など）して距離が正しく計測されることを確認
- アプリをバックグラウンドに切り替えても計測が継続されることを確認
- 配送終了後、Supabase Dashboardで `delivery_sessions` テーブルにレコードが追加されていることを確認
- 通知バーに「配送中」通知が表示されることを確認
- GPS信号が弱い環境（屋内など）で警告メッセージが表示されることを確認

#### 検証方法
1. 配送開始ボタンをタップ
2. 実際に500m〜1km程度移動
3. 配送画面に表示される距離がおおよそ正しいことを確認
4. アプリをバックグラウンドに切り替え、さらに移動
5. アプリを再度開き、距離が増加していることを確認
6. 配送終了ボタンをタップ
7. Supabase Dashboardで `delivery_sessions` テーブルを確認

---

### 参考資料

- [expo-location Documentation](https://docs.expo.dev/versions/latest/sdk/location/)
- [expo-task-manager Documentation](https://docs.expo.dev/versions/latest/sdk/task-manager/)
- [Haversine公式](https://en.wikipedia.org/wiki/Haversine_formula)
- `docs/03_database_delimon.md` - データベース設計（delivery_sessionsテーブル）
- `docs/04_api_delimon.md` - API設計（配送セッション作成）

---

### 要確認事項

- バックグラウンドでのバッテリー消費が許容範囲内か（1時間で5%以内が目標）
- GPS精度の閾値（50m）は適切か
- 距離計算の誤差はどの程度許容するか
- Android・iOSでバックグラウンド動作の挙動に差があるか
