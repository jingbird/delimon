# Issue #28: Sentryの導入・エラー監視

### 背景 / 目的
Sentryを導入し、本番環境でのエラーを自動収集・監視できるようにして、迅速なバグ修正を可能にする。

- **依存**: 全機能実装後（#1〜#26）
- **ラベル**: `infra`, `monitoring`

---

### スコープ / 作業項目

#### 1. Sentryのセットアップ
- `@sentry/react-native@5.33+` をインストール
- Sentry.ioでプロジェクトを作成し、DSNを取得

#### 2. Sentry初期化
- `src/lib/sentry.ts` を作成
- Sentry.init() で初期化（DSN設定、environment設定）
- アプリのエントリーポイント（`app/_layout.tsx`）で初期化

#### 3. 自動エラー収集の設定
以下のエラーを自動収集:
- JavaScriptエラー（未キャッチのエラー）
- ネットワークエラー（API呼び出し失敗）
- アプリクラッシュ（ネイティブクラッシュ）

#### 4. 個人情報の除外
- `beforeSend` 関数で個人情報（メールアドレス、ニックネームなど）を除外
- IPアドレスの匿名化

#### 5. カスタムコンテキストの追加
- ユーザーID（匿名ID）をSentryに送信
- アプリバージョン、デバイス情報、OS情報を自動収集

#### 6. Sentryダッシュボードでの確認
- Sentryダッシュボードでエラーが正しく送信されることを確認
- アラート設定（重大なエラー発生時にメール通知）

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] `@sentry/react-native@5.33+` がインストール済み
- [ ] `src/lib/sentry.ts` でSentry初期化（DSN設定、environment設定）完了
- [ ] JavaScriptエラー、ネットワークエラー、アプリクラッシュを自動送信できる
- [ ] `beforeSend` 関数で個人情報（メールアドレス等）を除外できる
- [ ] Sentryダッシュボードでエラーが確認可能

---

### テスト観点

#### 手動テスト
- 意図的にエラーを発生させ、Sentryダッシュボードでエラーが確認できることを確認
- ネットワークエラーを発生させ、Sentryで記録されることを確認
- 個人情報がSentryに送信されていないことを確認
- アプリバージョン、デバイス情報、OS情報がSentryで確認できることを確認

#### 検証方法
1. アプリに意図的にエラーを挿入（例: `throw new Error('Test error')`）
2. アプリを起動し、エラーが発生することを確認
3. Sentryダッシュボードでエラーが記録されていることを確認
4. エラー詳細で個人情報が除外されていることを確認
5. デバイス情報、OS情報が正しく記録されていることを確認

---

### 参考資料

- [Sentry for React Native Documentation](https://docs.sentry.io/platforms/react-native/)
- [Sentry beforeSend](https://docs.sentry.io/platforms/javascript/configuration/filtering/#using-beforesend)

---

### 要確認事項

- Sentryの無料枠で十分か（月5,000エラーで足りるか、有料プラン検討の要否）
- アラート設定の詳細（誰にメール通知するか）
- エラーの重要度分類（Critical, High, Medium, Low）
- 個人情報の除外範囲（何を除外するか）
