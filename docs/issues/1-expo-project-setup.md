# Issue #1: Expoプロジェクトのセットアップ

### 背景 / 目的
デリモンアプリの開発基盤を構築するため、Expo SDK 52ベースのReact Nativeプロジェクトを初期化し、TypeScript・Expo Router・開発ツールチェーンを整備する。

- **依存**: なし
- **ラベル**: `infra`, `setup`

---

### スコープ / 作業項目

#### 1. Expoプロジェクトの初期化
- `npx create-expo-app@latest deliverymon --template blank-typescript` でプロジェクト作成
- package.jsonの確認・必要に応じて依存関係の更新

#### 2. TypeScript設定
- `tsconfig.json` の確認・調整
- `strict: true` を有効化し、型安全性を最大化
- パスエイリアス設定（`@/` → `src/`）

#### 3. Expo Router導入
- `expo-router@4.0+` をインストール
- `app/` ディレクトリを作成し、ファイルベースルーティングを設定
- `app/_layout.tsx` でルートレイアウトを作成

#### 4. Lintツール設定
- ESLint設定ファイル（`.eslintrc.js`）を作成
- Prettier設定ファイル（`.prettierrc`）を作成
- package.jsonに `lint`, `lint:fix`, `format` スクリプトを追加

#### 5. Git設定
- `.gitignore` の確認・追加
  - `.env` （環境変数ファイル）
  - `node_modules/`
  - `.expo/`
  - `dist/`
  - その他ビルド生成物

#### 6. 初回動作確認
- `npm start` でExpo開発サーバー起動
- Expo Goアプリでスマートフォンからアクセス
- Hello World画面が表示されることを確認

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] `npx create-expo-app` でプロジェクト作成が完了し、`package.json` に Expo SDK 52+ が含まれている
- [ ] TypeScript 5.3+ の設定ファイル（`tsconfig.json`）が正しく配置され、`strict: true` が有効
- [ ] Expo Router 4.0+ が導入され、`app/` ディレクトリでファイルベースルーティングが動作する
- [ ] ESLint・Prettierの設定ファイルが配置され、`npm run lint` が正常に実行できる
- [ ] `npm start` でExpo開発サーバーが起動し、Expo Goアプリからアクセス可能
- [ ] `.gitignore` に `.env`, `node_modules` 等が含まれ、機密情報が誤ってコミットされない

---

### テスト観点

#### 手動テスト
- `npm start` 実行後、Expo GoアプリでQRコードをスキャンし、アプリが起動することを確認
- `npm run lint` を実行し、構文エラーがないことを確認
- TypeScriptのビルドエラーがないことを確認（`npx tsc --noEmit`）

#### 検証方法
1. プロジェクトルートで `npm start` を実行
2. スマートフォンのExpo GoアプリでQRコードをスキャン
3. 「Welcome to Expo」のような初期画面が表示されることを確認
4. `npm run lint` でエラーが0件であることを確認
5. `npx tsc --noEmit` でTypeScriptエラーが0件であることを確認

---

### 参考資料

- [Expo Documentation](https://docs.expo.dev/)
- [Expo Router Documentation](https://docs.expo.dev/router/introduction/)
- [TypeScript Configuration](https://www.typescriptlang.org/tsconfig)
- `docs/02_architecture_delimon.md` - アーキテクチャ設計（技術スタック、ディレクトリ構造）

---

### 要確認事項

- Node.jsバージョンの統一（推奨: v18 LTS）
- パッケージマネージャーの選択（npm or yarn）
- 開発メンバー全員がExpo Goアプリをインストール済みか
