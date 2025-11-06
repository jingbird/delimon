# Issue #12: 経験値・レベルシステムの実装

### 背景 / 目的
配送終了時に走行距離から経験値を計算し、キャラクターのレベルアップを判定・更新する仕組みを実装する。

- **依存**: #10
- **ラベル**: `backend`, `feature`

---

### スコープ / 作業項目

#### 1. 経験値計算ロジックの実装
- `src/utils/calculate.ts` を作成
- `calculateExperience(distance: number): number` 関数を実装（1km = 100経験値）
- `calculateLevel(experience: number): number` 関数を実装（1レベル = 1,000経験値）

#### 2. レベルアップ判定ロジック
- 配送終了時に現在の経験値と新しい経験値を比較
- レベルアップ回数を計算（複数レベルアップも考慮）
- レベルアップの有無を返す

#### 3. キャラクター情報の更新
- 配送終了時に `characters` テーブルの `experience`, `level` をUPDATE
- Supabase SDKを使用してトランザクション処理

#### 4. レベルアップエフェクト
- ホーム画面でレベルアップ時に光のエフェクトを表示
- React Native Reanimatedを使用してアニメーション実装

#### 5. 複数レベルアップ対応
- 一度に複数レベルアップする場合も正しく処理
- レベルアップ回数を配送結果画面に表示

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] `src/utils/calculate.ts` に経験値計算関数（1km=100経験値）を実装完了
- [ ] レベルアップ判定ロジック（1レベル=1,000経験値）を実装完了
- [ ] 配送終了時にキャラクターの経験値・レベルをUPDATE完了
- [ ] レベルアップ時にホーム画面で光のエフェクト表示
- [ ] レベルアップ回数が複数回の場合も正しく処理できる

---

### テスト観点

#### 手動テスト
- 10km配送（1,000経験値）でレベル1→2になることを確認
- 50km配送（5,000経験値）でレベル1→6になることを確認（複数レベルアップ）
- ホーム画面でレベルアップエフェクトが表示されることを確認
- Supabase Dashboardで `characters` テーブルの経験値・レベルが更新されていることを確認

#### ユニットテスト（将来的）
```typescript
describe('calculateExperience', () => {
  it('1kmで100経験値を返す', () => {
    expect(calculateExperience(1)).toBe(100);
  });
  it('10kmで1,000経験値を返す', () => {
    expect(calculateExperience(10)).toBe(1000);
  });
});

describe('calculateLevel', () => {
  it('0経験値でレベル1', () => {
    expect(calculateLevel(0)).toBe(1);
  });
  it('1,000経験値でレベル2', () => {
    expect(calculateLevel(1000)).toBe(2);
  });
  it('5,000経験値でレベル6', () => {
    expect(calculateLevel(5000)).toBe(6);
  });
});
```

---

### 参考資料

- `docs/01_requirements_delimon.md` - 要件定義（経験値・レベルシステム）
- `docs/03_database_delimon.md` - データベース設計（charactersテーブル）
- `docs/04_api_delimon.md` - API設計（キャラクター情報更新）

---

### 要確認事項

- 経験値計算式（1km = 100経験値）は適切か
- レベルアップ必要経験値（1レベル = 1,000経験値）は適切か
- レベル上限は設定するか（Phase 1では無制限でOK）
- レベルアップエフェクトのデザイン
