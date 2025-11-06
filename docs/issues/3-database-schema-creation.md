# Issue #3: データベーススキーマの作成

### 背景 / 目的
デリモンアプリで必要な全テーブル（users, characters, character_types, delivery_sessions）を作成し、Row Level Security（RLS）ポリシーを設定して、データベースの基盤を整備する。

- **依存**: #2
- **ラベル**: `backend`, `database`

---

### スコープ / 作業項目

#### 1. テーブルの作成
以下のテーブルをSupabase Dashboardで作成:
- `users` - ユーザー情報（プロフィール含む）
- `characters` - ユーザーが所持するキャラクター
- `character_types` - キャラクターのマスターデータ
- `delivery_sessions` - 配送履歴

#### 2. RLSポリシーの設定
各テーブルにRow Level Security（RLS）を有効化し、以下のポリシーを設定:
- ユーザーは自分のデータのみアクセス可能
- `character_types` は全ユーザーが閲覧可能（マスターデータ）

#### 3. トリガーの設定
- `users` テーブルの `updated_at` カラムを自動更新するトリガーを作成
- `characters` テーブルの `updated_at` カラムを自動更新するトリガーを作成

#### 4. ビューの作成
- `user_stats_view` - ユーザーの統計情報を集約
- `public_user_profile_view` - 公開プロフィール情報（ニックネーム#識別番号のみ）

#### 5. マスターデータの投入
- `character_types` テーブルに9体分のキャラクターデータを投入
  - ハコブー系: ハコブー（Lv.1-19）、ハコドン（Lv.20-49）、ハコジュウ（Lv.50+）
  - ルートン系: ルートン、ルートドン、ルートクン
  - シールン系: シールン、シールドン、シールグランド

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] `users`, `characters`, `character_types`, `delivery_sessions` テーブルがSupabase Dashboardで確認できる
- [ ] 各テーブルにRLSポリシーが設定され、`auth.uid()` で自分のデータのみアクセス可能
- [ ] `character_types` テーブルに9体分のマスターデータが投入済み（ハコブー系3体、ルートン系3体、シールン系3体）
- [ ] `users` テーブルの `updated_at` 自動更新トリガーが動作する
- [ ] `user_stats_view`, `public_user_profile_view` が作成され、SQLクエリでデータ取得可能

---

### テスト観点

#### データベーステスト
- テーブルが正しく作成されているか
- RLSポリシーが正しく動作するか（他ユーザーのデータにアクセスできないか）
- トリガーが正しく動作するか（`updated_at` が自動更新されるか）
- ビューからデータを取得できるか

#### 検証方法
1. Supabase Dashboard > SQL Editor で以下のクエリを実行:
   ```sql
   SELECT * FROM users;
   SELECT * FROM characters;
   SELECT * FROM character_types;
   SELECT * FROM delivery_sessions;
   SELECT * FROM user_stats_view;
   SELECT * FROM public_user_profile_view;
   ```

2. RLSポリシーの確認:
   - テストユーザーAでログイン
   - テストユーザーBのデータにアクセスを試みる
   - アクセスが拒否されることを確認

3. トリガーの確認:
   ```sql
   UPDATE users SET nickname = 'テスト' WHERE id = 'test-user-id';
   SELECT updated_at FROM users WHERE id = 'test-user-id';
   -- updated_atが現在時刻に更新されていることを確認
   ```

---

### 実装SQL

#### 1. usersテーブル
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  nickname VARCHAR(20) NOT NULL CHECK (char_length(nickname) BETWEEN 2 AND 20),
  display_id VARCHAR(4) NOT NULL CHECK (display_id ~ '^\d{4}$'),
  birth_date DATE NOT NULL,
  gender VARCHAR(20) NOT NULL CHECK (gender IN ('male', 'female', 'prefer_not_to_say')),
  occupation VARCHAR(50) NOT NULL CHECK (occupation IN ('truck_driver', 'light_vehicle_driver', 'food_delivery', 'cargo_ship', 'bus_taxi', 'other')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (nickname, display_id)
);

-- RLSポリシー
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own data"
ON users FOR SELECT
USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE
USING (auth.uid() = id);
```

#### 2. charactersテーブル
```sql
CREATE TABLE characters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  character_type_id INT NOT NULL REFERENCES character_types(id),
  level INT NOT NULL DEFAULT 1 CHECK (level >= 1),
  experience INT NOT NULL DEFAULT 0 CHECK (experience >= 0),
  evolution_stage INT NOT NULL DEFAULT 1 CHECK (evolution_stage IN (1, 2, 3)),
  is_partner BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (user_id, character_type_id)
);

CREATE INDEX idx_characters_user_id ON characters(user_id);
CREATE INDEX idx_characters_is_partner ON characters(is_partner);

-- RLSポリシー
ALTER TABLE characters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own characters"
ON characters FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own characters"
ON characters FOR UPDATE
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own characters"
ON characters FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

#### 3. character_typesテーブル
```sql
CREATE TABLE character_types (
  id INT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  name_ja VARCHAR(50) NOT NULL,
  evolution_stage INT NOT NULL CHECK (evolution_stage IN (1, 2, 3)),
  evolves_at_level INT CHECK (evolves_at_level IS NULL OR evolves_at_level > 0),
  description TEXT NOT NULL,
  image_url VARCHAR(255) NOT NULL
);

-- RLSポリシー（全ユーザーが閲覧可能）
ALTER TABLE character_types ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All users can view character types"
ON character_types FOR SELECT
TO authenticated
USING (true);

-- マスターデータ投入
-- ハコブー系統
INSERT INTO character_types (id, name, name_ja, evolution_stage, evolves_at_level, description, image_url) VALUES
(1, 'Hakoboo', 'ハコブー', 1, 20, '配送の相棒。箱型の体が特徴的。', '/images/characters/hakoboo_1.png'),
(2, 'Hakodon', 'ハコドン', 2, 50, 'ハコブーの進化形。より大きな荷物を運べる。', '/images/characters/hakoboo_2.png'),
(3, 'Hakojuu', 'ハコジュウ', 3, NULL, 'ハコブーの最終進化。どんな荷物でも運べる。', '/images/characters/hakoboo_3.png');

-- ルートン系統
INSERT INTO character_types (id, name, name_ja, evolution_stage, evolves_at_level, description, image_url) VALUES
(4, 'Rooton', 'ルートン', 1, 20, 'ルートを見つけるのが得意。', '/images/characters/rooton_1.png'),
(5, 'Rootodon', 'ルートドン', 2, 50, 'ルートンの進化形。最短ルートを見つける。', '/images/characters/rooton_2.png'),
(6, 'Rootokun', 'ルートクン', 3, NULL, 'ルートンの最終進化。全てのルートを知る。', '/images/characters/rooton_3.png');

-- シールン系統
INSERT INTO character_types (id, name, name_ja, evolution_stage, evolves_at_level, description, image_url) VALUES
(7, 'Sealn', 'シールン', 1, 20, 'シールを貼るのが得意。', '/images/characters/sealn_1.png'),
(8, 'Sealdon', 'シールドン', 2, 50, 'シールンの進化形。どんなシールも貼れる。', '/images/characters/sealn_2.png'),
(9, 'Sealgrand', 'シールグランド', 3, NULL, 'シールンの最終進化。伝説のシール職人。', '/images/characters/sealn_3.png');
```

#### 4. delivery_sessionsテーブル
```sql
CREATE TABLE delivery_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL CHECK (end_time > start_time),
  distance_km FLOAT NOT NULL CHECK (distance_km >= 0),
  duration_seconds INT NOT NULL CHECK (duration_seconds > 0),
  experience_gained INT NOT NULL CHECK (experience_gained >= 0),
  level_before INT NOT NULL CHECK (level_before >= 1),
  level_after INT NOT NULL CHECK (level_after >= level_before),
  evolved BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_delivery_sessions_user_id ON delivery_sessions(user_id);
CREATE INDEX idx_delivery_sessions_created_at ON delivery_sessions(created_at);

-- RLSポリシー
ALTER TABLE delivery_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own delivery sessions"
ON delivery_sessions FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own delivery sessions"
ON delivery_sessions FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

#### 5. トリガー
```sql
-- updated_at自動更新関数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- usersテーブルのトリガー
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- charactersテーブルのトリガー
CREATE TRIGGER update_characters_updated_at BEFORE UPDATE ON characters
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

#### 6. ビュー
```sql
-- ユーザー統計ビュー
CREATE OR REPLACE VIEW user_stats_view AS
SELECT
  u.id AS user_id,
  u.nickname,
  u.display_id,
  u.email,
  u.birth_date,
  u.gender,
  u.occupation,
  c.level,
  c.experience,
  c.evolution_stage,
  COUNT(ds.id) AS total_deliveries,
  COALESCE(SUM(ds.distance_km), 0) AS total_distance_km,
  COALESCE(SUM(ds.duration_seconds), 0) AS total_duration_seconds,
  COALESCE(SUM(ds.experience_gained), 0) AS total_experience_gained,
  COALESCE(SUM(CASE WHEN ds.created_at >= date_trunc('week', CURRENT_DATE) THEN ds.distance_km ELSE 0 END), 0) AS week_distance_km,
  COALESCE(SUM(CASE WHEN ds.created_at >= date_trunc('month', CURRENT_DATE) THEN ds.distance_km ELSE 0 END), 0) AS month_distance_km,
  COALESCE(SUM(CASE WHEN ds.created_at >= CURRENT_DATE THEN ds.distance_km ELSE 0 END), 0) AS today_distance_km,
  COALESCE(COUNT(CASE WHEN ds.created_at >= CURRENT_DATE THEN 1 END), 0) AS today_deliveries
FROM users u
LEFT JOIN characters c ON u.id = c.user_id AND c.is_partner = true
LEFT JOIN delivery_sessions ds ON u.id = ds.user_id
GROUP BY u.id, u.nickname, u.display_id, u.email, u.birth_date, u.gender, u.occupation, c.level, c.experience, c.evolution_stage;

-- 公開プロフィールビュー
CREATE OR REPLACE VIEW public_user_profile_view AS
SELECT
  u.id AS user_id,
  u.nickname || '#' || u.display_id AS display_name,
  u.nickname,
  u.display_id,
  c.level,
  c.evolution_stage,
  ct.name_ja AS character_name,
  ct.image_url AS character_image_url,
  COUNT(ds.id) AS total_deliveries,
  COALESCE(SUM(ds.distance_km), 0) AS total_distance_km
FROM users u
LEFT JOIN characters c ON u.id = c.user_id AND c.is_partner = true
LEFT JOIN character_types ct ON c.character_type_id = ct.id
LEFT JOIN delivery_sessions ds ON u.id = ds.user_id
GROUP BY u.id, u.nickname, u.display_id, c.level, c.evolution_stage, ct.name_ja, ct.image_url;
```

---

### 参考資料

- `docs/03_database_delimon.md` - データベース設計書（完全なDDL定義）
- [Supabase Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [PostgreSQL Triggers](https://www.postgresql.org/docs/current/sql-createtrigger.html)

---

### 要確認事項

- キャラクター画像（`image_url`）は後で実際の画像ファイルに置き換える必要がある
- マスターデータ（キャラクター名、説明文）の最終確認
- データベースパスワードの安全な管理方法の確認
