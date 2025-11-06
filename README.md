# デリモン（Delivery Monsters）

<div align="center">

**配送業務をゲーム化し、モンスター育成を通じて移動のモチベーションを高めるアプリ**

[![React Native](https://img.shields.io/badge/React%20Native-0.76-blue.svg)](https://reactnative.dev/)
[![Expo](https://img.shields.io/badge/Expo-52-black.svg)](https://expo.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.3-blue.svg)](https://www.typescriptlang.org/)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-green.svg)](https://supabase.com/)

</div>

---

## 📖 目次

- [プロジェクト概要](#プロジェクト概要)
- [主な機能（MVP）](#主な機能mvp)
- [技術スタック](#技術スタック)
- [必要な環境](#必要な環境)
- [セットアップ手順](#セットアップ手順)
- [開発コマンド](#開発コマンド)
- [プロジェクト構造](#プロジェクト構造)
- [開発フロー](#開発フロー)
- [ドキュメント](#ドキュメント)
- [ライセンス](#ライセンス)

---

## 🎮 プロジェクト概要

**デリモン（Delivery Monsters）** は、配送業務やドライブなどの日々の移動をゲーム化し、モンスター育成を通じて移動のモチベーションを高めるモバイルアプリです。

### ターゲットユーザー

**メインターゲット**:
- 運送業者・宅配業者のドライバー
- ウーバーイーツ・出前館などフードデリバリー配達員
- 年齢層: 20代〜50代

**サブターゲット**:
- 営業職など移動が多い職業の人
- タクシードライバー
- ドライブ好き、ゲーム好きな一般ユーザー

### 解決したい課題

- 配送業務の単調さ、モチベーション維持の難しさ
- 長距離移動の退屈さ
- 日々の移動距離・頑張りの可視化不足

---

## ✨ 主な機能（MVP）

### 🔐 認証機能
- メールアドレス + パスワードでのサインアップ/ログイン
- プロフィール設定（ニックネーム、生年月日、性別、業種）

### 🎓 チュートリアル機能
- 初回起動時のチュートリアル（4画面）
- キャラクター選択（3種類から1体選択）

### 🐾 キャラクター育成機能
- 相棒キャラクター表示
- レベル・経験値システム（1km = 100経験値）
- 進化機能（2段階進化: Lv.20、Lv.50）
- 進化アニメーション

### 📍 GPS計測機能
- 配送開始・終了ボタン
- リアルタイム移動距離計測
- 移動軌跡の地図表示
- バックグラウンドでの位置情報トラッキング

### 📊 図鑑・履歴機能
- 相棒キャラクターの図鑑表示
- 配送履歴の一覧表示
- 期間別統計（今週・今月・全期間）
- 走行距離グラフ

### ⚙️ 設定機能
- プロフィール編集
- 通知設定
- データ収集設定
- アカウント削除

---

## 🛠 技術スタック

### フロントエンド
- **フレームワーク**: [Expo SDK 52+](https://expo.dev/)
- **言語**: [TypeScript 5.3+](https://www.typescriptlang.org/)
- **プラットフォーム**: [React Native 0.76+](https://reactnative.dev/)
- **UI ライブラリ**: [React Native Paper 5.12+](https://callstack.github.io/react-native-paper/)
- **ナビゲーション**: [Expo Router 4.0+](https://docs.expo.dev/router/introduction/)

### バックエンド
- **サービス**: [Supabase](https://supabase.com/)
- **データベース**: PostgreSQL
- **認証**: Supabase Auth
- **API**: REST（Supabase自動生成）

### 状態管理・データ取得
- **グローバル状態管理**: [Zustand 5.0+](https://zustand-demo.pmnd.rs/)
- **サーバー状態管理**: [TanStack Query (React Query) 5.59+](https://tanstack.com/query/latest)

### その他
- **地図表示**: [react-native-maps 1.18+](https://github.com/react-native-maps/react-native-maps)
- **GPS・位置情報**: [expo-location 18.0+](https://docs.expo.dev/versions/latest/sdk/location/) + [expo-task-manager 12.0+](https://docs.expo.dev/versions/latest/sdk/task-manager/)
- **グラフ表示**: [react-native-chart-kit 6.12+](https://github.com/indiespirit/react-native-chart-kit)
- **プッシュ通知**: [expo-notifications 0.29+](https://docs.expo.dev/versions/latest/sdk/notifications/)
- **エラー監視**: [Sentry 5.33+](https://sentry.io/)

---

## 💻 必要な環境

### 必須
- **Node.js**: v18.x 以上
- **npm**: v9.x 以上（または **yarn**: v1.22.x 以上）
- **Expo CLI**: 最新版
- **Git**: 最新版

### 推奨
- **エディタ**: [Visual Studio Code](https://code.visualstudio.com/)
- **VSCode拡張機能**:
  - ESLint
  - Prettier - Code formatter
  - React Native Tools
  - TypeScript Vue Plugin (Volar)

### 実機テスト用
- **Android**: Android Studio（エミュレーター使用時）
- **iOS**: Xcode（Macのみ、エミュレーター使用時）
- **Expo Go**: スマートフォンにインストール（開発初期）

---

## 🚀 セットアップ手順

### 1. リポジトリのクローン

```bash
git clone https://github.com/yourusername/deliverymon.git
cd deliverymon
```

### 2. 依存関係のインストール

```bash
npm install
# または
yarn install
```

### 3. 環境変数の設定

`.env.example` をコピーして `.env` を作成し、必要な環境変数を設定します。

```bash
cp .env.example .env
```

`.env` ファイルを編集:

```bash
# Supabase
EXPO_PUBLIC_SUPABASE_URL=your_supabase_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your_anon_key

# Google Maps API（地図表示用）
EXPO_PUBLIC_GOOGLE_MAPS_API_KEY=your_google_maps_key

# Sentry（エラー監視）
SENTRY_DSN=your_sentry_dsn
```

**環境変数の取得方法**:
- **Supabase**: [Supabase Dashboard](https://supabase.com/dashboard) でプロジェクトを作成し、Settings > API から取得
- **Google Maps API**: [Google Cloud Console](https://console.cloud.google.com/) で Maps SDK for Android/iOS を有効化し、APIキーを取得
- **Sentry**: [Sentry.io](https://sentry.io/) でプロジェクトを作成し、DSNを取得

### 4. データベースのセットアップ

Supabase Dashboard で以下のSQLを実行し、データベーススキーマを作成します。

詳細は `docs/03_database_delimon.md` を参照してください。

```sql
-- usersテーブルの作成
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  nickname VARCHAR(20) NOT NULL,
  display_id VARCHAR(4) NOT NULL,
  birth_date DATE NOT NULL,
  gender VARCHAR(20) NOT NULL,
  occupation VARCHAR(50) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (nickname, display_id)
);

-- その他のテーブル、RLSポリシーなども設定
-- 詳細は docs/03_database_delimon.md を参照
```

### 5. 開発サーバーの起動

```bash
npm start
# または
yarn start
```

QRコードが表示されるので、スマートフォンの Expo Go アプリでスキャンしてアプリを起動します。

---

## 📱 開発コマンド

| コマンド | 説明 |
|---------|------|
| `npm start` | 開発サーバーを起動（QRコード表示） |
| `npm run android` | Androidエミュレーター/実機で起動 |
| `npm run ios` | iOSシミュレーター/実機で起動（Macのみ） |
| `npm run web` | Webブラウザで起動 |
| `npm run lint` | ESLintでコードチェック |
| `npm run lint:fix` | ESLintで自動修正 |
| `npm run format` | Prettierでコードフォーマット |
| `npm run type-check` | TypeScriptの型チェック |

### EAS Build（本番ビルド）

GPS機能のテストや本番リリース時には、EAS Buildを使用します。

```bash
# 開発用ビルド（GPS機能テスト用）
npx eas build --profile development --platform android

# 本番用ビルド
npx eas build --profile production --platform android
npx eas build --profile production --platform ios
```

詳細は [EAS Build Documentation](https://docs.expo.dev/build/introduction/) を参照してください。

---

## 📂 プロジェクト構造

```
deliverymon/
├── app/                          # Expo Router（画面）
│   ├── (auth)/                  # 認証関連画面グループ
│   │   ├── login.tsx
│   │   ├── signup.tsx
│   │   ├── profile-setup.tsx    # プロフィール設定
│   │   └── character-select.tsx
│   ├── (tabs)/                  # タブナビゲーション
│   │   ├── _layout.tsx
│   │   ├── index.tsx            # ホーム画面
│   │   ├── delivery.tsx         # 配送（地図）画面
│   │   ├── collection.tsx       # 図鑑画面
│   │   └── history.tsx          # 履歴画面
│   ├── settings/                # 設定関連
│   │   ├── index.tsx
│   │   ├── profile-edit.tsx     # プロフィール編集
│   │   ├── privacy.tsx
│   │   └── terms.tsx
│   ├── tutorial.tsx
│   ├── evolution.tsx
│   └── _layout.tsx
│
├── src/
│   ├── components/              # 再利用可能なコンポーネント
│   │   ├── common/             # 汎用コンポーネント
│   │   └── features/           # 機能固有コンポーネント
│   ├── hooks/                   # カスタムフック
│   ├── services/                # 外部サービス連携
│   │   ├── supabase/           # Supabase関連
│   │   ├── location/           # GPS・位置情報
│   │   └── notifications/      # プッシュ通知
│   ├── store/                   # Zustand（状態管理）
│   ├── utils/                   # ユーティリティ関数
│   ├── types/                   # TypeScript型定義
│   └── constants/               # 定数
│
├── assets/                      # 静的ファイル
│   ├── images/
│   ├── fonts/
│   └── sounds/
│
├── docs/                        # 設計書
│   ├── 01_requirements_delimon.md
│   ├── 02_architecture_delimon.md
│   ├── 03_database_delimon.md
│   ├── 04_api_delimon.md
│   ├── 05_sitemap_delimon.md
│   └── 06_screen_transition_delimon.md
│
├── .env                         # 環境変数（Git管理外）
├── .env.example                 # 環境変数のサンプル
├── .gitignore
├── app.json                     # Expo設定
├── eas.json                     # EAS Build設定
├── package.json
├── tsconfig.json
├── CLAUDE.md                    # Claude Code用ルール
└── README.md                    # このファイル
```

---

## 🔄 開発フロー

### ブランチ戦略

```
main          # 本番リリース用（常に安定）
└─ develop   # 開発中の最新
   └─ feature/xxx  # 機能開発ブランチ
```

### ブランチ命名規則

- `feature/auth` - 認証機能
- `feature/gps` - GPS機能
- `feature/character` - キャラクター機能
- `fix/xxx` - バグ修正

### コミットメッセージ

プロジェクトでは、日本語で統一されたコミットメッセージフォーマットを使用しています。

```
<type>: <subject>

<body>（任意）

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

**Type（接頭辞）**:
- `feat`: 新機能の追加
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更
- `refactor`: リファクタリング
- `perf`: パフォーマンス改善
- `test`: テストの追加・修正
- `chore`: ビルド、設定ファイルなどの変更

**例**:
```
feat: プロフィール設定画面を追加

初回登録時にニックネーム、生年月日、性別、業種を
入力できるプロフィール設定画面を実装。

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

詳細は `CLAUDE.md` を参照してください。

---

## 📚 ドキュメント

プロジェクトの詳細な設計書は `docs/` ディレクトリにあります。

| ドキュメント | 内容 |
|------------|------|
| [要件定義書](docs/01_requirements_delimon.md) | プロジェクトの目的、MVP機能、ユーザーストーリー |
| [アーキテクチャ設計](docs/02_architecture_delimon.md) | 技術スタック、ディレクトリ構造、状態管理 |
| [データベース設計](docs/03_database_delimon.md) | テーブル定義、RLSポリシー、マイグレーション |
| [API設計](docs/04_api_delimon.md) | エンドポイント一覧、リクエスト/レスポンス形式 |
| [サイトマップ](docs/05_sitemap_delimon.md) | 画面一覧、画面詳細、タブナビゲーション |
| [画面遷移図](docs/06_screen_transition_delimon.md) | 画面フロー、初回ユーザーフロー、テストケース |
| [Claude Code用ルール](CLAUDE.md) | コーディング規約、コミットメッセージ形式 |

### 新規参加者向け
1. まず `docs/01_requirements_delimon.md` でプロジェクト全体を把握
2. `docs/02_architecture_delimon.md` で技術スタックとアーキテクチャを理解
3. `CLAUDE.md` でコーディング規約を確認
4. 開発開始！

---

## 🧪 テスト

### MVP時点
- **手動テスト**: 実機での確認を重視
- **テスト内容**:
  - GPS計測の精度確認（実際に移動してテスト）
  - バッテリー消費の確認
  - バックグラウンド動作の確認
  - 画面遷移の確認

### 将来的なテスト（Phase 2以降）
- ユニットテスト
- 統合テスト
- E2Eテスト

---

## 🔒 セキュリティ

### 重要事項
- **Row Level Security (RLS)**: すべてのテーブルでRLSを有効化
- **環境変数**: `.env` ファイルは `.gitignore` に追加済み、Gitにコミットしない
- **個人情報保護**: プロフィール情報（生年月日、性別、業種）は非公開
- **パスワード**: Supabase Authが自動でハッシュ化

詳細は `CLAUDE.md` のセキュリティセクションを参照してください。

---

## 🎯 開発スケジュール（目安）

| フェーズ | 期間 | 内容 |
|---------|------|------|
| 要件定義・設計 | 1週間 | ✅ 完了 |
| 環境構築 | 3日 | 進行中 |
| 認証実装 | 1週間 | - |
| プロフィール設定実装 | 3日 | - |
| チュートリアル・キャラ選択 | 3日 | - |
| GPS計測機能 | 2週間 | - |
| 経験値・レベルシステム | 1週間 | - |
| 図鑑・履歴画面 | 1週間 | - |
| プッシュ通知 | 3日 | - |
| 設定機能 | 3日 | - |
| テスト・バグ修正 | 1週間 | - |
| ストア申請準備 | 3日 | - |
| **合計** | **約8.5週間** | **MVP完成まで** |

---

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 新しいブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'feat: 素晴らしい機能を追加'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

**注意**:
- コミットメッセージは日本語で記述
- `CLAUDE.md` のコーディング規約に従う
- 新機能追加時は該当する設計書も更新

---

## 📄 ライセンス

このプロジェクトは私的利用を目的としています。

---

## 📞 お問い合わせ

- **プロジェクトオーナー**: [名前]
- **Email**: [メールアドレス]
- **GitHub**: [GitHubアカウント]

---

## 🙏 謝辞

このプロジェクトは以下のオープンソースプロジェクトに支えられています：
- [React Native](https://reactnative.dev/)
- [Expo](https://expo.dev/)
- [Supabase](https://supabase.com/)
- [TanStack Query](https://tanstack.com/query/latest)
- [Zustand](https://zustand-demo.pmnd.rs/)

---

<div align="center">

**デリモン（Delivery Monsters）** - 配送をもっと楽しく！

Made with ❤️ by [Your Name]

</div>
