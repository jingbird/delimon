# デリモン - エラー対処ログ

このファイルは実装中に発生したエラーと対処法を記録します。

---

## エラー記録フォーマット

```
### [YYYY-MM-DD HH:MM] エラー概要

**発生箇所**: ファイル名:行番号 または 作業内容

**エラーメッセージ**:
```
エラーメッセージをここに記載
```

**原因**: エラーの原因

**試した対処法**:
1. 対処法1 → 結果（成功/失敗）
2. 対処法2 → 結果（成功/失敗）

**解決方法**: 最終的に解決した方法

**参考資料**: 参考にしたURL、ドキュメントなど

---
```

---

## エラー履歴

### [2025-11-06] Expoプロジェクト作成時のファイル競合

**発生箇所**: Issue #1 - Expoプロジェクトの初期化

**エラーメッセージ**:
```
The directory delimon has files that might be overwritten:
  CLAUDE.md
  DEVELOPMENT_LOG.md
  ERROR_LOG.md
  README.md
  create-issues-14-30.ps1
  create-issues-simple.ps1
  create-issues.ps1
```

**原因**: 既存のファイルがあるディレクトリにExpoプロジェクトを作成しようとしたため

**試した対処法**:
1. `npx create-expo-app@latest . --template blank-typescript` → 失敗（既存ファイル競合）
2. 既存ファイルを一時ディレクトリに退避 → 成功

**解決方法**:
既存ファイルを `../delimon_backup/` に退避後、Expoプロジェクトを作成。
その後、退避したファイルを戻し、.gitignoreとREADME.mdをマージした。

**参考資料**: create-expo-appの制限により、既存ファイルがあるディレクトリには直接作成できない

---

### [2025-11-06] Expo Router依存関係インストール時のReactバージョン競合

**発生箇所**: Issue #1 - Expo Routerの導入

**エラーメッセージ**:
```
Could not resolve dependency:
peer react@"^19.2.0" from react-dom@19.2.0
Conflicting peer dependency: react@19.2.0
現在のReact: 19.1.0
```

**原因**: react-dom@19.2.0がReact^19.2.0を要求するが、プロジェクトにはReact 19.1.0がインストールされている

**試した対処法**:
1. `npx expo install expo-linking expo-constants react-native-safe-area-context react-native-screens` → 失敗（バージョン競合）
2. `npm install react@19.2.0 @types/react@19.2.0` → 成功

**解決方法**:
React を19.1.0から19.2.0にアップデートすることで解決。
その後、Expo Routerの依存関係を正常にインストールできた。

**参考資料**: Expo Routerが最新のReactバージョンを要求するため、React 19.2.0へのアップデートが必要

---
