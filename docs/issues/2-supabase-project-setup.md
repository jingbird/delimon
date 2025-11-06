# Issue #2: Supabaseプロジェクトのセットアップ

### 背景 / 目的
バックエンドとしてSupabase（PostgreSQL）を使用するため、Supabaseプロジェクトを作成し、クライアント接続の基盤を整備する。

- **依存**: なし
- **ラベル**: `infra`, `backend`

---

### スコープ / 作業項目

#### 1. Supabaseプロジェクトの作成
- [Supabase Dashboard](https://supabase.com/dashboard) にアクセス
- 新規プロジェクトを作成
  - プロジェクト名: `deliverymon` (または任意)
  - データベースパスワード: 強力なパスワードを生成・保存
  - リージョン: 東京（`ap-northeast-1`）を推奨

#### 2. APIキーの取得
- Settings > API から以下を取得:
  - `Project URL` (SUPABASE_URL)
  - `anon public` キー (SUPABASE_ANON_KEY)
- これらを `.env.example` にサンプルとして記載

#### 3. 環境変数の設定
- プロジェクトルートに `.env` ファイルを作成
- 以下の環境変数を設定:
  ```
  EXPO_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
  EXPO_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
  ```

#### 4. Supabaseクライアントのインストール
- `npm install @supabase/supabase-js@^2.45.0`
- `src/services/supabase/` ディレクトリを作成

#### 5. Supabaseクライアントの初期化
- `src/services/supabase/client.ts` を作成
- `createClient` を使ってSupabaseクライアントを初期化
- 環境変数から `EXPO_PUBLIC_SUPABASE_URL` と `EXPO_PUBLIC_SUPABASE_ANON_KEY` を読み込み

#### 6. 接続確認
- 簡単なクエリ（例: `SELECT 1`）でSupabaseへの接続を確認
- エラーが発生しないことを確認

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] Supabase Dashboardでプロジェクトが作成され、プロジェクトURLが取得できる
- [ ] `SUPABASE_URL`、`SUPABASE_ANON_KEY` が取得され、`.env.example` にサンプルとして記載されている
- [ ] `@supabase/supabase-js` パッケージがインストール済み（`package.json` で確認）
- [ ] `src/services/supabase/client.ts` でSupabaseクライアントが初期化されている
- [ ] 簡単なクエリ（例: `supabase.from('_test').select('*')`）で接続確認が取れる（エラーが発生しないこと）

---

### テスト観点

#### 接続テスト
- Supabaseクライアントが正しく初期化されているか
- 環境変数が正しく読み込まれているか
- ネットワーク経由でSupabaseに接続できるか

#### 検証方法
1. `src/services/supabase/client.ts` を作成し、以下のコードで接続確認:
   ```typescript
   import { createClient } from '@supabase/supabase-js';

   const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!;
   const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!;

   export const supabase = createClient(supabaseUrl, supabaseAnonKey);

   // 接続確認用の簡易テスト
   supabase.from('_test').select('*').then(({ data, error }) => {
     console.log('Supabase接続確認:', error ? 'エラー' : '成功');
   });
   ```

2. `npm start` でアプリを起動し、コンソールに「Supabase接続確認: 成功」が表示されることを確認

---

### 参考資料

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript/introduction)
- [Expo Environment Variables](https://docs.expo.dev/guides/environment-variables/)
- `docs/02_architecture_delimon.md` - アーキテクチャ設計（バックエンド構成）

---

### 実装例

#### `src/services/supabase/client.ts`
```typescript
import { createClient } from '@supabase/supabase-js';
import type { Database } from '@/types/database';

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Supabaseの環境変数が設定されていません');
}

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
  },
});
```

#### `.env.example`
```bash
# Supabase
EXPO_PUBLIC_SUPABASE_URL=your_supabase_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your_anon_key

# Google Maps API（後で追加）
EXPO_PUBLIC_GOOGLE_MAPS_API_KEY=your_google_maps_key

# Sentry（後で追加）
SENTRY_DSN=your_sentry_dsn
```

---

### 要確認事項

- Supabaseの無料枠で十分か（1,000ユーザー × 3ヶ月想定）
- データベースパスワードの安全な保管方法（1Passwordなど）
- リージョン選択（東京 vs シンガポール）の確認
