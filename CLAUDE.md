# Claude Code プロジェクトルール - デリモン

このドキュメントは、Claude Code が「デリモン（Delivery Monsters）」プロジェクトで作業する際に従うべきルールと設定をまとめたものです。

---

## 目次

1. [基本方針](#基本方針)
2. [コミットメッセージのフォーマット](#コミットメッセージのフォーマット)
3. [コミュニケーション言語](#コミュニケーション言語)
4. [コードスタイル](#コードスタイル)
5. [設計・アーキテクチャ](#設計アーキテクチャ)
6. [セキュリティ](#セキュリティ)
7. [パフォーマンス](#パフォーマンス)
8. [ドキュメント](#ドキュメント)
9. [テスト](#テスト)
10. [重要な参照ドキュメント](#重要な参照ドキュメント)

---

## 基本方針

### プロジェクト概要
- **プロジェクト名**: デリモン（Delivery Monsters）
- **目的**: 配送業務やドライブをゲーム化し、モンスター育成を通じて移動のモチベーションを高める
- **ターゲット**: 運送業者・宅配業者のドライバー、フードデリバリー配達員、営業職など移動が多い職業の人
- **開発状況**: MVP（Phase 1）開発中

### 技術スタック
- **フロントエンド**: Expo SDK 52+, React Native 0.76+, TypeScript 5.3+
- **バックエンド**: Supabase (PostgreSQL)
- **状態管理**: Zustand 5.0+
- **API通信**: TanStack Query 5.59+
- **地図表示**: react-native-maps 1.18+
- **GPS・位置情報**: expo-location 18.0+ + expo-task-manager 12.0+
- **UI ライブラリ**: React Native Paper 5.12+
- **ナビゲーション**: Expo Router 4.0+ (ファイルベースルーティング)

### 意識すべき観点
1. **シンプルさ**: MVP開発のため、必要最小限の機能に絞る
2. **保守性**: TypeScriptの型安全性を活かし、将来の拡張を考慮した設計
3. **ユーザー体験**: 配送ドライバーが使いやすいシンプルなUI
4. **セキュリティ**: 個人情報保護、位置情報の適切な扱い
5. **パフォーマンス**: GPS計測やバックグラウンド動作の最適化
6. **設計書準拠**: docs配下の設計書に記載された仕様を必ず参照・遵守

---

## コミットメッセージのフォーマット

### 基本フォーマット

```
<type>: <subject>

<body>（任意）

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### Type（接頭辞）

| Type | 説明 | 例 |
|------|------|------|
| `feat` | 新機能の追加 | `feat: プロフィール設定画面を追加` |
| `fix` | バグ修正 | `fix: GPS計測のバグを修正` |
| `docs` | ドキュメントのみの変更 | `docs: READMEを更新` |
| `style` | コードの意味に影響しない変更（フォーマット、セミコロンなど） | `style: Lintエラーを修正` |
| `refactor` | リファクタリング（機能変更なし） | `refactor: 経験値計算ロジックをリファクタ` |
| `perf` | パフォーマンス改善 | `perf: 地図レンダリングを最適化` |
| `test` | テストの追加・修正 | `test: 配送セッションAPIのテストを追加` |
| `chore` | ビルド、設定ファイルなどの変更 | `chore: 依存関係を更新` |

### Subject（件名）の書き方
- **日本語で記述**
- **簡潔に**（50文字以内が目安）
- **命令形**を使用（「追加する」ではなく「追加」）
- **末尾にピリオドをつけない**

### Body（本文）の書き方（任意）
- **何を変更したか**より**なぜ変更したか**を重視
- 詳細な説明が必要な場合のみ記載
- 箇条書きを活用

### 例

```
feat: 配送結果画面に進化判定機能を追加

レベル20、50到達時に進化可能であることを判定し、
ユーザーに進化アニメーションを表示する機能を実装。

- 経験値計算後にレベルチェック
- 進化可能な場合は「進化できます！」バッジを表示
- 進化アニメーション画面への遷移を追加

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## コミュニケーション言語

### 基本ルール
- **回答は基本的に日本語で行う**
- コード内のコメント、ドキュメント、コミットメッセージもすべて日本語
- 変数名・関数名・型名などのコードそのものは英語

### 例外
- TypeScript/JavaScript の標準的な命名規則に従う部分（変数名、関数名など）
- 外部ライブラリのAPIやメソッド名
- 技術用語で日本語訳が不自然な場合（例: props, hooks, state）

### コメントの例

```typescript
// ✅ 良い例
/**
 * ユーザーの配送セッションを作成する
 * @param sessionData 配送セッション情報
 * @returns 作成された配送セッション
 */
async function createDeliverySession(sessionData: DeliverySessionData) {
  // GPS計測を開始
  await startLocationTracking();

  // データベースに保存
  return await supabase
    .from('delivery_sessions')
    .insert(sessionData)
    .select()
    .single();
}

// ❌ 悪い例（英語のコメント）
/**
 * Create a delivery session
 * @param sessionData Delivery session data
 * @returns Created delivery session
 */
async function createDeliverySession(sessionData: DeliverySessionData) {
  // Start GPS tracking
  await startLocationTracking();

  // Save to database
  return await supabase
    .from('delivery_sessions')
    .insert(sessionData)
    .select()
    .single();
}
```

---

## コードスタイル

### TypeScript

#### 型定義
- **型安全性を最優先**: `any`の使用は避ける
- **明示的な型定義**: 型推論に頼りすぎず、関数の引数・戻り値には明示的に型を指定
- **インターフェースより型エイリアス**: プロジェクト全体で`type`を使用（一貫性のため）

```typescript
// ✅ 良い例
type UserProfile = {
  id: string;
  nickname: string;
  display_id: string;
  birth_date: string;
  gender: 'male' | 'female' | 'prefer_not_to_say';
  occupation: string;
}

async function getProfile(userId: string): Promise<UserProfile> {
  // ...
}

// ❌ 悪い例
async function getProfile(userId) {
  // 型が不明瞭
}
```

#### 命名規則
- **camelCase**: 変数名、関数名（例: `deliverySession`, `startTracking`）
- **PascalCase**: 型名、コンポーネント名（例: `DeliverySession`, `ProfileForm`）
- **UPPER_SNAKE_CASE**: 定数（例: `MAX_LEVEL`, `DEFAULT_EXPERIENCE`）
- **わかりやすい名前**: 略語は避け、意図が明確な名前を使用

```typescript
// ✅ 良い例
const MAX_NICKNAME_LENGTH = 20;
const currentExperience = character.experience;
const isEvolutionAvailable = level >= 20;

// ❌ 悪い例
const MAX_LEN = 20; // 何のMAX_LENか不明瞭
const exp = character.experience; // expは略語
const canEvo = level >= 20; // 略語
```

#### コメント
- **複雑なロジックには必ずコメント**
- **「なぜ」を説明**: 「何をしているか」は読めばわかる、「なぜそうしているか」を説明
- **JSDoc形式**: 公開関数には必ずJSDocコメント

```typescript
// ✅ 良い例
/**
 * 経験値から現在のレベルを計算する
 * 1レベル = 1,000経験値の固定レート
 * @param experience 累計経験値
 * @returns 現在のレベル
 */
function calculateLevel(experience: number): number {
  return Math.floor(experience / 1000) + 1;
}

// ❌ 悪い例
// レベルを計算
function calculateLevel(experience: number): number {
  return Math.floor(experience / 1000) + 1;
}
```

### React Native / Expo

#### コンポーネント設計
- **単一責任の原則**: 1つのコンポーネントは1つの責務のみ
- **Propsの型定義**: すべてのPropsに型を定義
- **再利用可能な小さいコンポーネント**: `components/common/` に配置

```typescript
// ✅ 良い例
type ButtonProps = {
  onPress: () => void;
  title: string;
  disabled?: boolean;
  variant?: 'primary' | 'secondary';
}

export function Button({ onPress, title, disabled = false, variant = 'primary' }: ButtonProps) {
  // ...
}

// ❌ 悪い例（型定義なし）
export function Button({ onPress, title, disabled, variant }) {
  // ...
}
```

#### Hooks の使用
- **カスタムフックの活用**: ロジックを分離、再利用性を高める
- **命名規則**: `use` で始める（例: `useAuth`, `useProfile`, `useDelivery`）
- **依存配列の最適化**: `useEffect`, `useCallback`, `useMemo` の依存配列を適切に設定

```typescript
// ✅ 良い例
function useProfile() {
  const { data: profile, isLoading, error } = useQuery({
    queryKey: ['profile'],
    queryFn: async () => {
      const { data } = await supabase
        .from('users')
        .select('*')
        .eq('id', userId)
        .single();
      return data;
    },
  });

  return { profile, isLoading, error };
}
```

### Lint / Formatter
- **ESLint**: プロジェクトの `.eslintrc.js` に従う
- **Prettier**: 自動フォーマットを活用
- **コミット前に必ずLint**: `npm run lint` でエラーがないことを確認

---

## 設計・アーキテクチャ

### ディレクトリ構造の遵守
プロジェクトのディレクトリ構造は `docs/02_architecture_delimon.md` に定義されています。新しいファイルを作成する際は必ず以下の構造に従ってください。

```
deliverymon/
├── app/                          # Expo Router（画面）
│   ├── (auth)/                  # 認証関連画面グループ
│   ├── (tabs)/                  # タブナビゲーション
│   └── settings/                # 設定関連
├── src/
│   ├── components/              # 再利用可能なコンポーネント
│   │   ├── common/             # 汎用コンポーネント
│   │   └── features/           # 機能固有コンポーネント
│   ├── hooks/                   # カスタムフック
│   ├── services/                # 外部サービス連携
│   ├── store/                   # Zustand（状態管理）
│   ├── utils/                   # ユーティリティ関数
│   ├── types/                   # TypeScript型定義
│   └── constants/               # 定数
├── assets/                      # 静的ファイル
└── docs/                        # 設計書
```

### データフロー
1. ユーザーアクション（ボタンタップ）
2. 画面コンポーネント（`app/`）
3. カスタムフック（`hooks/`）
4. TanStack Query（API通信・キャッシュ）
5. Supabase Client（`services/supabase/`）
6. Zustand（グローバル状態更新）
7. 画面に反映（再レンダリング）

### 状態管理
- **グローバル状態**: Zustand を使用（`authStore`, `profileStore`, `characterStore`, `deliveryStore`）
- **サーバー状態**: TanStack Query を使用（API通信結果のキャッシュ）
- **ローカル状態**: `useState` を使用（UIの一時的な状態）

### API通信
- **Supabase SDK**: すべてのデータベースアクセスは `services/supabase/` 経由
- **TanStack Query**: キャッシュ戦略は `docs/02_architecture_delimon.md` の「サーバーステート管理」を参照
- **エラーハンドリング**: 必ず try-catch でエラーをキャッチし、ユーザーにわかりやすいメッセージを表示

---

## セキュリティ

### 必須事項
1. **Row Level Security (RLS)**: すべてのテーブルでRLSを有効化（`docs/03_database_delimon.md` 参照）
2. **パスワード**: 平文で保存しない、Supabase Authが自動でハッシュ化
3. **個人情報保護**:
   - プロフィール情報（生年月日、性別、業種）は非公開
   - ニックネーム（識別番号付き）のみ公開
4. **環境変数**: APIキーなどの機密情報は `.env` に保存、Gitにコミットしない
5. **HTTPS通信**: Supabaseは標準でHTTPS対応

### セキュリティチェックリスト
- [ ] ユーザー入力のバリデーション（XSS対策）
- [ ] SQLインジェクション対策（Supabase SDKを使用することで自動対策）
- [ ] 認証トークンの安全な保存（`expo-secure-store` を使用）
- [ ] 位置情報の適切な扱い（ユーザーの同意取得、データ収集設定の尊重）
- [ ] プライバシーポリシー・利用規約の明記

### 禁止事項
- ❌ `console.log` で機密情報をログ出力
- ❌ APIキーをコードに直接記述
- ❌ パスワードを平文で保存
- ❌ ユーザー入力をそのままデータベースに保存（必ずバリデーション）

---

## パフォーマンス

### 目標値（MVP時点）
- **アプリ起動**: 3秒以内
- **画面遷移**: 500ms以内
- **地図読み込み**: 2秒以内
- **API応答**: 1秒以内
- **バックグラウンドGPS**: 1時間で5%以内のバッテリー消費

### 最適化手法
1. **画像最適化**: WebP形式、適切なサイズに圧縮
2. **リスト表示**: `FlatList` で仮想化
3. **TanStack Query のキャッシュ**: 適切なキャッシュ時間を設定（`docs/02_architecture_delimon.md` 参照）
4. **GPS計測**: 位置情報取得間隔を5秒に設定、バッテリー消費を最小化
5. **不要な再レンダリング**: `React.memo`, `useMemo`, `useCallback` を活用

### パフォーマンス測定
- MVP時点では極端に遅くなければOK
- テスト時にパフォーマンスを測定し、問題があれば最適化

---

## ドキュメント

### コード内ドキュメント
- **複雑な関数**: JSDocコメントを必ず記載
- **型定義**: わかりにくい型には説明コメントを追加
- **TODO コメント**: 将来実装すべき機能には `// TODO: 〜` を記載

```typescript
// ✅ 良い例
/**
 * ニックネームに一意の識別番号を生成する
 * 既存の組み合わせと重複しないよう、データベースをチェックしながら生成
 * @param nickname ユーザーが入力したニックネーム
 * @returns 4桁の識別番号（例: "1234"）
 */
async function generateUniqueDisplayId(nickname: string): Promise<string> {
  let displayId: string;
  let exists = true;

  while (exists) {
    // 0001〜9999のランダムな4桁数字を生成
    displayId = Math.floor(Math.random() * 9999).toString().padStart(4, '0');

    // 既に存在するか確認
    const { data } = await supabase
      .from('users')
      .select('id')
      .eq('nickname', nickname)
      .eq('display_id', displayId)
      .single();

    exists = !!data;
  }

  return displayId!;
}
```

### 設計書の更新
- **新機能追加時**: 必ず `docs/` 配下の該当ドキュメントを更新
- **API変更時**: `docs/04_api_delimon.md` を更新
- **データベーススキーマ変更時**: `docs/03_database_delimon.md` を更新
- **画面追加時**: `docs/05_sitemap_delimon.md`, `docs/06_screen_transition_delimon.md` を更新

---

## テスト

### MVP時点
- **手動テスト**: 実機での確認を重視
- **テスト内容**:
  - GPS計測の精度確認（実際に移動してテスト）
  - バッテリー消費の確認
  - バックグラウンド動作の確認
  - 画面遷移の確認

### 将来的なテスト（Phase 2以降）
- **ユニットテスト**: 重要な関数にテストを追加
- **統合テスト**: API通信のテスト
- **E2Eテスト**: 主要なユーザーフローのテスト

---

## 重要な参照ドキュメント

作業前に必ず以下のドキュメントを確認してください。

| ドキュメント | パス | 内容 |
|------------|------|------|
| 要件定義書 | `docs/01_requirements_delimon.md` | プロジェクトの目的、MVP機能、ユーザーストーリー、プロフィール設定仕様 |
| アーキテクチャ設計 | `docs/02_architecture_delimon.md` | 技術スタック、ディレクトリ構造、状態管理、データフロー |
| データベース設計 | `docs/03_database_delimon.md` | テーブル定義、RLSポリシー、マイグレーション計画 |
| API設計 | `docs/04_api_delimon.md` | エンドポイント一覧、リクエスト/レスポンス形式、エラーハンドリング |
| サイトマップ | `docs/05_sitemap_delimon.md` | 画面一覧、画面詳細、タブナビゲーション |
| 画面遷移図 | `docs/06_screen_transition_delimon.md` | 画面フロー、初回ユーザーフロー、テストケース |

### 設計書の優先度
1. **最優先**: `docs/01_requirements_delimon.md`（要件定義）
2. **常に参照**: `docs/02_architecture_delimon.md`（アーキテクチャ）
3. **データベース作業時**: `docs/03_database_delimon.md`
4. **API作業時**: `docs/04_api_delimon.md`
5. **UI作業時**: `docs/05_sitemap_delimon.md`, `docs/06_screen_transition_delimon.md`

---

## まとめ

### Claude Code への期待
1. **設計書を必ず参照**: 作業前に該当する設計書を確認し、仕様に準拠
2. **日本語でコミュニケーション**: コメント、ドキュメント、コミットメッセージはすべて日本語
3. **型安全なコード**: TypeScriptの型を活用し、バグを事前に防ぐ
4. **セキュリティ意識**: 個人情報保護、認証、データ収集の同意を常に意識
5. **シンプルに保つ**: MVPのため、必要最小限の機能に絞る
6. **ユーザー体験を重視**: 配送ドライバーが使いやすいシンプルなUIを心がける

### 疑問や不明点があれば
- 設計書に記載がない場合: ユーザーに確認
- 技術的な判断が必要な場合: 選択肢を提示し、ユーザーと相談

---

**最終更新**: 2025年11月6日
**バージョン**: 1.0
