-- デリモン - 初期スキーマ作成
-- 作成日: 2025-11-07

-- ==========================================
-- 1. 共通関数: 更新日時自動更新
-- ==========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- ==========================================
-- 2. character_types テーブル（キャラクタータイプ）
-- ==========================================

CREATE TABLE character_types (
  id INT PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  name_ja VARCHAR(50) NOT NULL,
  evolution_stage INT NOT NULL CHECK (evolution_stage IN (1, 2, 3)),
  evolves_at_level INT CHECK (evolves_at_level IS NULL OR evolves_at_level > 0),
  description TEXT NOT NULL,
  image_url VARCHAR(255) NOT NULL
);

-- RLS有効化（マスターデータなので全ユーザーが閲覧可能）
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

-- ==========================================
-- 3. users テーブル（プロフィール情報）
-- ==========================================
-- 注意: email, password は auth.users テーブルで管理される
-- このテーブルはプロフィール情報のみを保存

CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname VARCHAR(20) NOT NULL CHECK (char_length(nickname) BETWEEN 2 AND 20),
  display_id VARCHAR(4) NOT NULL CHECK (display_id ~ '^\d{4}$'),
  birth_date DATE NOT NULL,
  gender VARCHAR(20) NOT NULL CHECK (gender IN ('male', 'female', 'prefer_not_to_say')),
  occupation VARCHAR(50) NOT NULL CHECK (occupation IN ('truck_driver', 'light_vehicle_driver', 'food_delivery', 'cargo_ship', 'bus_taxi', 'other')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  UNIQUE (nickname, display_id)
);

-- 更新日時自動更新トリガー
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS有効化
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 自分のユーザー情報のみ閲覧可能
CREATE POLICY "Users can view their own data"
ON users FOR SELECT
USING (auth.uid() = id);

-- 自分のユーザー情報のみ更新可能（プロフィール編集用）
CREATE POLICY "Users can update their own profile"
ON users FOR UPDATE
USING (auth.uid() = id);

-- 自分のプロフィールを作成可能（初回登録時）
CREATE POLICY "Users can create their own profile"
ON users FOR INSERT
WITH CHECK (auth.uid() = id);

-- ==========================================
-- 4. characters テーブル（キャラクター）
-- ==========================================

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

-- インデックス
CREATE INDEX idx_characters_user_id ON characters(user_id);
CREATE INDEX idx_characters_is_partner ON characters(is_partner);

-- 更新日時自動更新トリガー
CREATE TRIGGER update_characters_updated_at BEFORE UPDATE ON characters
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- RLS有効化
ALTER TABLE characters ENABLE ROW LEVEL SECURITY;

-- 自分のキャラクターのみ閲覧可能
CREATE POLICY "Users can view their own characters"
ON characters FOR SELECT
USING (auth.uid() = user_id);

-- 自分のキャラクターのみ更新可能
CREATE POLICY "Users can update their own characters"
ON characters FOR UPDATE
USING (auth.uid() = user_id);

-- 自分のキャラクターのみ作成可能
CREATE POLICY "Users can create their own characters"
ON characters FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- 5. delivery_sessions テーブル（配送履歴）
-- ==========================================

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

-- インデックス
CREATE INDEX idx_delivery_sessions_user_id ON delivery_sessions(user_id);
CREATE INDEX idx_delivery_sessions_created_at ON delivery_sessions(created_at);

-- RLS有効化
ALTER TABLE delivery_sessions ENABLE ROW LEVEL SECURITY;

-- 自分の配送履歴のみ閲覧可能
CREATE POLICY "Users can view their own delivery sessions"
ON delivery_sessions FOR SELECT
USING (auth.uid() = user_id);

-- 自分の配送履歴のみ作成可能
CREATE POLICY "Users can create their own delivery sessions"
ON delivery_sessions FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- ==========================================
-- 完了
-- ==========================================
