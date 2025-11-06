# Issue #29: パフォーマンス最適化

### 背景 / 目的
アプリ全体のパフォーマンスを測定し、画面遷移・レンダリング・キャッシュを最適化してユーザー体験を向上させる。

- **依存**: 全機能実装後（#1〜#26）
- **ラベル**: `frontend`, `perf`

---

### スコープ / 作業項目

#### 1. 画面遷移の最適化
- 画面遷移時間を測定（React Navigation Performance Monitoring）
- 遷移が500ms以内になるように最適化
- 重い処理をバックグラウンドに移動

#### 2. TanStack Queryのキャッシュ最適化
- `docs/02_architecture_delimon.md` のキャッシュ戦略に準拠
- キャッシュ時間を適切に設定:
  - プロフィール情報: 5分
  - キャラクター情報: 1分
  - 配送履歴: 30秒
  - 図鑑情報: 10分

#### 3. 履歴画面のリスト仮想化
- FlatListで大量のデータをスムーズにスクロール
- `initialNumToRender`, `maxToRenderPerBatch`, `windowSize` を最適化

#### 4. 不要な再レンダリングの削減
- React.memo, useMemo, useCallbackを活用
- React DevTools Profilerで再レンダリングを測定

#### 5. 画像の最適化
- キャラクター画像を適切なサイズに圧縮（各画像100KB以下）
- WebP形式への変換（React Native 0.76+はWebPサポート）
- react-native-fast-imageの導入検討

#### 6. バンドルサイズの最適化
- 使用していないライブラリを削除
- tree-shakingの活用

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] 画面遷移が500ms以内（ホーム→配送、ホーム→図鑑等）
- [ ] TanStack Queryのキャッシュ設定を最適化（`docs/02_architecture_delimon.md` のキャッシュ戦略に準拠）
- [ ] 履歴画面のリストをFlatListで仮想化し、スムーズにスクロールできる
- [ ] 不要な再レンダリングを`React.memo`, `useMemo`, `useCallback`で削減
- [ ] キャラクター画像を適切なサイズに圧縮（各画像100KB以下）

---

### テスト観点

#### 手動テスト
- 画面遷移時間を測定し、500ms以内であることを確認
- 履歴画面で大量のデータ（100件以上）をスムーズにスクロールできることを確認
- React DevTools Profilerで不要な再レンダリングがないことを確認
- キャラクター画像のファイルサイズを確認（100KB以下）
- アプリの起動時間を測定し、3秒以内であることを確認

#### 検証方法
1. React DevTools Profilerでアプリを起動
2. 画面遷移時間を測定（ホーム→配送、配送→履歴など）
3. 履歴画面で100件以上のデータをスクロール
4. React DevTools Profilerで再レンダリング回数を確認
5. キャラクター画像のファイルサイズを確認

---

### 参考資料

- `docs/02_architecture_delimon.md` - アーキテクチャ設計（キャッシュ戦略）
- [React Native Performance](https://reactnative.dev/docs/performance)
- [TanStack Query Caching](https://tanstack.com/query/latest/docs/react/guides/caching)
- [FlatList Performance](https://reactnative.dev/docs/optimizing-flatlist-configuration)

---

### 要確認事項

- パフォーマンス目標値の確認（画面遷移500ms以内は適切か）
- 画像圧縮の程度（画質とファイルサイズのバランス）
- react-native-fast-imageの導入要否
- Phase 1でどこまで最適化するか（MVPリリース前に必須か、リリース後でも可か）
