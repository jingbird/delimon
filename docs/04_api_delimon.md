# デリモン - API設計書（プロフィール設定追加版）

**バージョン**: 1.1  
**最終更新日**: 2025年11月6日  
**作成者**: [名前]  
**ステータス**: 設計中

---

## 変更履歴

| 日付 | バージョン | 変更内容 | 担当者 |
|------|-----------|---------|--------|
| 2025-11-06 | 1.1 | プロフィール関連API（取得・更新）を追加 | [名前] |
| 2025-11-06 | 1.0 | 初版作成 | [名前] |

---

## 1. 概要

本ドキュメントは、デリモンアプリのAPI設計を定義します。

**APIベースURL**: Supabase自動生成  
**認証方式**: Supabase Auth（JWT）  
**データ形式**: JSON

---

## 2. API一覧

| # | エンドポイント | メソッド | 認証 | 説明 |
|---|---------------|---------|------|------|
| **認証** |
| 1 | `/auth/signup` | POST | 不要 | サインアップ |
| 2 | `/auth/login` | POST | 不要 | ログイン |
| 3 | `/auth/logout` | POST | 必要 | ログアウト |
| **プロフィール** ⭐NEW |
| 4 | `/users/profile` | GET | 必要 | プロフィール取得 |
| 5 | `/users/profile` | PUT | 必要 | プロフィール更新 |
| 6 | `/users/profile/check-nickname` | POST | 不要 | ニックネーム重複チェック |
| **キャラクター** |
| 7 | `/characters` | GET | 必要 | 所持キャラクター一覧取得 |
| 8 | `/characters` | POST | 必要 | キャラクター作成（初回選択） |
| 9 | `/characters/{id}` | GET | 必要 | キャラクター詳細取得 |
| 10 | `/characters/{id}` | PUT | 必要 | キャラクター更新（経験値・レベル） |
| 11 | `/character-types` | GET | 必要 | キャラクタータイプ一覧取得 |
| **配送** |
| 12 | `/delivery-sessions` | POST | 必要 | 配送セッション作成 |
| 13 | `/delivery-sessions` | GET | 必要 | 配送履歴取得 |
| 14 | `/delivery-sessions/{id}` | GET | 必要 | 配送セッション詳細取得 |
| **統計** |
| 15 | `/stats/user` | GET | 必要 | ユーザー統計取得 |

---

## 3. 認証API

### 3.1 サインアップ

**エンドポイント**: `POST /auth/signup`

**説明**: 新規ユーザー登録

**リクエストボディ**:
```json
{
  "email": "tanaka@example.com",
  "password": "password123"
}
```

**レスポンス（成功）**: `201 Created`
```json
{
  "user": {
    "id": "00000000-0000-0000-0000-000000000001",
    "email": "tanaka@example.com",
    "created_at": "2025-11-06T10:00:00Z"
  },
  "session": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "...",
    "expires_at": 1699272000
  }
}
```

**レスポンス（エラー）**: `400 Bad Request`
```json
{
  "error": {
    "message": "このメールアドレスは既に使用されています",
    "code": "email_already_exists"
  }
}
```

**注意**: サインアップ後、**プロフィール設定が必須** ⭐NEW

---

### 3.2 ログイン

**エンドポイント**: `POST /auth/login`

**説明**: 既存ユーザーのログイン

**リクエストボディ**:
```json
{
  "email": "tanaka@example.com",
  "password": "password123"
}
```

**レスポンス（成功）**: `200 OK`
```json
{
  "user": {
    "id": "00000000-0000-0000-0000-000000000001",
    "email": "tanaka@example.com"
  },
  "session": {
    "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refresh_token": "...",
    "expires_at": 1699272000
  }
}
```

**レスポンス（エラー）**: `401 Unauthorized`
```json
{
  "error": {
    "message": "メールアドレスまたはパスワードが間違っています",
    "code": "invalid_credentials"
  }
}
```

---

### 3.3 ログアウト

**エンドポイント**: `POST /auth/logout`

**説明**: ログアウト

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**レスポンス（成功）**: `200 OK`
```json
{
  "message": "ログアウトしました"
}
```

---

## 4. プロフィールAPI ⭐NEW

### 4.1 プロフィール取得

**エンドポイント**: `GET /users/profile`

**説明**: 自分のプロフィール情報を取得

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**レスポンス（成功）**: `200 OK`
```json
{
  "id": "00000000-0000-0000-0000-000000000001",
  "email": "tanaka@example.com",
  "nickname": "たなか",
  "display_id": "1234",
  "display_name": "たなか#1234",
  "birth_date": "1990-06-25",
  "gender": "male",
  "occupation": "truck_driver",
  "created_at": "2025-11-06T10:00:00Z",
  "updated_at": "2025-11-06T10:00:00Z"
}
```

**レスポンス（プロフィール未設定）**: `404 Not Found`
```json
{
  "error": {
    "message": "プロフィールが設定されていません",
    "code": "profile_not_set",
    "requires_profile_setup": true
  }
}
```

**使用例**:
- ログイン後、プロフィール設定済みかチェック
- 設定メニューでプロフィール表示
- ホーム画面でニックネーム表示

---

### 4.2 プロフィール更新

**エンドポイント**: `PUT /users/profile`

**説明**: プロフィール情報を更新（初回設定 or 編集）

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**リクエストボディ**:
```json
{
  "nickname": "たなか",
  "birth_date": "1990-06-25",
  "gender": "male",
  "occupation": "truck_driver"
}
```

**注意**:
- `display_id`は自動生成されるため、リクエストに含めない
- 初回設定時のみ`display_id`が自動付与される
- 2回目以降の更新では`display_id`は変更されない

**レスポンス（成功・初回設定）**: `201 Created`
```json
{
  "id": "00000000-0000-0000-0000-000000000001",
  "email": "tanaka@example.com",
  "nickname": "たなか",
  "display_id": "1234",
  "display_name": "たなか#1234",
  "birth_date": "1990-06-25",
  "gender": "male",
  "occupation": "truck_driver",
  "created_at": "2025-11-06T10:00:00Z",
  "updated_at": "2025-11-06T10:05:00Z"
}
```

**レスポンス（成功・編集）**: `200 OK`
```json
{
  "id": "00000000-0000-0000-0000-000000000001",
  "email": "tanaka@example.com",
  "nickname": "Tanaka",
  "display_id": "1234",
  "display_name": "Tanaka#1234",
  "birth_date": "1990-06-25",
  "gender": "male",
  "occupation": "light_vehicle_driver",
  "created_at": "2025-11-06T10:00:00Z",
  "updated_at": "2025-11-07T15:30:00Z"
}
```

**レスポンス（エラー・バリデーション）**: `400 Bad Request`
```json
{
  "error": {
    "message": "入力内容に誤りがあります",
    "code": "validation_error",
    "details": [
      {
        "field": "nickname",
        "message": "ニックネームは2〜20文字で入力してください"
      },
      {
        "field": "birth_date",
        "message": "有効な日付を入力してください"
      }
    ]
  }
}
```

**レスポンス（エラー・重複）**: `409 Conflict`
```json
{
  "error": {
    "message": "このニックネームと識別番号の組み合わせは既に使用されています",
    "code": "nickname_display_id_conflict"
  }
}
```

**バリデーションルール**:
- `nickname`: 2〜20文字、日本語・英数字・アンダーバー・ハイフンのみ
- `birth_date`: YYYY-MM-DD形式、1900-01-01〜2025-12-31
- `gender`: "male", "female", "prefer_not_to_say" のいずれか
- `occupation`: "truck_driver", "light_vehicle_driver", "food_delivery", "cargo_ship", "bus_taxi", "other" のいずれか

---

### 4.3 ニックネーム重複チェック

**エンドポイント**: `POST /users/profile/check-nickname`

**説明**: ニックネームと識別番号の組み合わせが利用可能かチェック

**リクエストボディ**:
```json
{
  "nickname": "たなか",
  "display_id": "1234"
}
```

**レスポンス（利用可能）**: `200 OK`
```json
{
  "available": true,
  "message": "このニックネームは利用可能です"
}
```

**レスポンス（既に使用中）**: `200 OK`
```json
{
  "available": false,
  "message": "このニックネームと識別番号の組み合わせは既に使用されています"
}
```

**使用例**:
- プロフィール設定時に、サーバー側で`display_id`を自動生成する前にチェック
- 通常はアプリ側で使用せず、サーバー内部での重複チェックに使用

---

## 5. キャラクターAPI

### 5.1 所持キャラクター一覧取得

**エンドポイント**: `GET /characters`

**説明**: ユーザーが所持するキャラクター一覧を取得（MVPでは1体のみ）

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**レスポンス（成功）**: `200 OK`
```json
{
  "characters": [
    {
      "id": "00000000-0000-0000-0000-000000000010",
      "user_id": "00000000-0000-0000-0000-000000000001",
      "character_type_id": 2,
      "level": 25,
      "experience": 500,
      "evolution_stage": 2,
      "is_partner": true,
      "character_type": {
        "id": 2,
        "name": "Hakodon",
        "name_ja": "ハコドン",
        "evolution_stage": 2,
        "evolves_at_level": 50,
        "description": "ハコブーの進化形。より大きな荷物を運べる。",
        "image_url": "/images/characters/hakoboo_2.png"
      },
      "created_at": "2025-11-06T10:00:00Z",
      "updated_at": "2025-11-06T15:30:00Z"
    }
  ]
}
```

---

### 5.2 キャラクター作成（初回選択）

**エンドポイント**: `POST /characters`

**説明**: 初回キャラクター選択時にキャラクターを作成

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**リクエストボディ**:
```json
{
  "character_type_id": 1,
  "is_partner": true
}
```

**レスポンス（成功）**: `201 Created`
```json
{
  "id": "00000000-0000-0000-0000-000000000010",
  "user_id": "00000000-0000-0000-0000-000000000001",
  "character_type_id": 1,
  "level": 1,
  "experience": 0,
  "evolution_stage": 1,
  "is_partner": true,
  "character_type": {
    "id": 1,
    "name": "Hakoboo",
    "name_ja": "ハコブー",
    "evolution_stage": 1,
    "evolves_at_level": 20,
    "description": "配送の相棒。箱型の体が特徴的。",
    "image_url": "/images/characters/hakoboo_1.png"
  },
  "created_at": "2025-11-06T10:00:00Z",
  "updated_at": "2025-11-06T10:00:00Z"
}
```

**レスポンス（エラー・既に所持）**: `409 Conflict`
```json
{
  "error": {
    "message": "既にキャラクターを所持しています",
    "code": "character_already_exists"
  }
}
```

---

### 5.3 キャラクター詳細取得

**エンドポイント**: `GET /characters/{id}`

**説明**: キャラクターの詳細情報を取得

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**レスポンス（成功）**: `200 OK`
```json
{
  "id": "00000000-0000-0000-0000-000000000010",
  "user_id": "00000000-0000-0000-0000-000000000001",
  "character_type_id": 2,
  "level": 25,
  "experience": 500,
  "next_level_experience": 1000,
  "total_experience": 25500,
  "evolution_stage": 2,
  "can_evolve": false,
  "next_evolution_level": 50,
  "is_partner": true,
  "character_type": {
    "id": 2,
    "name": "Hakodon",
    "name_ja": "ハコドン",
    "evolution_stage": 2,
    "evolves_at_level": 50,
    "description": "ハコブーの進化形。より大きな荷物を運べる。",
    "image_url": "/images/characters/hakoboo_2.png"
  },
  "created_at": "2025-11-06T10:00:00Z",
  "updated_at": "2025-11-06T15:30:00Z"
}
```

**計算項目の説明**:
- `next_level_experience`: 次のレベルまでに必要な経験値（常に1000）
- `total_experience`: 累計獲得経験値 = (level - 1) × 1000 + experience
- `can_evolve`: 進化可能かどうか（level >= evolves_at_level）
- `next_evolution_level`: 次の進化レベル（最終進化の場合はnull）

---

### 5.4 キャラクター更新（経験値・レベル）

**エンドポイント**: `PUT /characters/{id}`

**説明**: キャラクターの経験値・レベルを更新（配送終了時）

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**リクエストボディ**:
```json
{
  "experience_gained": 4550,
  "level_before": 20,
  "level_after": 24
}
```

**レスポンス（成功）**: `200 OK`
```json
{
  "id": "00000000-0000-0000-0000-000000000010",
  "user_id": "00000000-0000-0000-0000-000000000001",
  "character_type_id": 2,
  "level": 24,
  "experience": 550,
  "evolution_stage": 2,
  "leveled_up": true,
  "evolved": false,
  "character_type": {
    "id": 2,
    "name": "Hakodon",
    "name_ja": "ハコドン",
    "evolution_stage": 2,
    "evolves_at_level": 50,
    "description": "ハコブーの進化形。より大きな荷物を運べる。",
    "image_url": "/images/characters/hakoboo_2.png"
  },
  "updated_at": "2025-11-06T16:00:00Z"
}
```

**レスポンス（進化した場合）**: `200 OK`
```json
{
  "id": "00000000-0000-0000-0000-000000000010",
  "user_id": "00000000-0000-0000-0000-000000000001",
  "character_type_id": 3,
  "level": 50,
  "experience": 0,
  "evolution_stage": 3,
  "leveled_up": true,
  "evolved": true,
  "old_character_type": {
    "id": 2,
    "name": "Hakodon",
    "name_ja": "ハコドン"
  },
  "character_type": {
    "id": 3,
    "name": "Hakojuu",
    "name_ja": "ハコジュウ",
    "evolution_stage": 3,
    "evolves_at_level": null,
    "description": "ハコブーの最終進化。どんな荷物でも運べる。",
    "image_url": "/images/characters/hakoboo_3.png"
  },
  "updated_at": "2025-11-07T10:00:00Z"
}
```

**計算ロジック**:
```
新しい経験値 = 現在の経験値 + 獲得経験値
レベルアップ回数 = floor(新しい経験値 / 1000)
新しいレベル = 現在のレベル + レベルアップ回数
余剰経験値 = 新しい経験値 % 1000
```

---

### 5.5 キャラクタータイプ一覧取得

**エンドポイント**: `GET /character-types`

**説明**: 全キャラクタータイプ（図鑑用）を取得

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**レスポンス（成功）**: `200 OK`
```json
{
  "character_types": [
    {
      "id": 1,
      "name": "Hakoboo",
      "name_ja": "ハコブー",
      "evolution_stage": 1,
      "evolves_at_level": 20,
      "description": "配送の相棒。箱型の体が特徴的。",
      "image_url": "/images/characters/hakoboo_1.png"
    },
    {
      "id": 2,
      "name": "Hakodon",
      "name_ja": "ハコドン",
      "evolution_stage": 2,
      "evolves_at_level": 50,
      "description": "ハコブーの進化形。より大きな荷物を運べる。",
      "image_url": "/images/characters/hakoboo_2.png"
    },
    // ... 全9種類
  ]
}
```

---

## 6. 配送API

### 6.1 配送セッション作成

**エンドポイント**: `POST /delivery-sessions`

**説明**: 配送終了時にセッション情報を保存

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**リクエストボディ**:
```json
{
  "start_time": "2025-11-06T08:00:00Z",
  "end_time": "2025-11-06T12:30:00Z",
  "distance_km": 45.5,
  "duration_seconds": 16200,
  "experience_gained": 4550,
  "level_before": 20,
  "level_after": 24,
  "evolved": false
}
```

**レスポンス（成功）**: `201 Created`
```json
{
  "id": "00000000-0000-0000-0000-000000000020",
  "user_id": "00000000-0000-0000-0000-000000000001",
  "start_time": "2025-11-06T08:00:00Z",
  "end_time": "2025-11-06T12:30:00Z",
  "distance_km": 45.5,
  "duration_seconds": 16200,
  "experience_gained": 4550,
  "level_before": 20,
  "level_after": 24,
  "evolved": false,
  "created_at": "2025-11-06T12:30:00Z"
}
```

**計算項目の自動計算**:
- `distance_km`と`duration_seconds`から平均速度を算出可能
- `experience_gained = distance_km × 100`

---

### 6.2 配送履歴取得

**エンドポイント**: `GET /delivery-sessions`

**説明**: ユーザーの配送履歴を取得

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**クエリパラメータ**:
- `period`: 期間フィルター（`week`, `month`, `all`）デフォルト: `all`
- `limit`: 取得件数（デフォルト: 50、最大: 100）
- `offset`: オフセット（ページネーション用）

**リクエスト例**:
```
GET /delivery-sessions?period=week&limit=20&offset=0
```

**レスポンス（成功）**: `200 OK`
```json
{
  "delivery_sessions": [
    {
      "id": "00000000-0000-0000-0000-000000000020",
      "user_id": "00000000-0000-0000-0000-000000000001",
      "start_time": "2025-11-06T08:00:00Z",
      "end_time": "2025-11-06T12:30:00Z",
      "distance_km": 45.5,
      "duration_seconds": 16200,
      "experience_gained": 4550,
      "level_before": 20,
      "level_after": 24,
      "evolved": false,
      "created_at": "2025-11-06T12:30:00Z"
    },
    // ... 他のセッション
  ],
  "summary": {
    "total_count": 45,
    "total_distance_km": 1250.5,
    "total_duration_seconds": 810000,
    "total_experience_gained": 125050,
    "average_distance_km": 27.8,
    "average_duration_seconds": 18000
  },
  "pagination": {
    "limit": 20,
    "offset": 0,
    "has_more": true
  }
}
```

---

### 6.3 配送セッション詳細取得

**エンドポイント**: `GET /delivery-sessions/{id}`

**説明**: 特定の配送セッションの詳細を取得

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**レスポンス（成功）**: `200 OK`
```json
{
  "id": "00000000-0000-0000-0000-000000000020",
  "user_id": "00000000-0000-0000-0000-000000000001",
  "start_time": "2025-11-06T08:00:00Z",
  "end_time": "2025-11-06T12:30:00Z",
  "distance_km": 45.5,
  "duration_seconds": 16200,
  "experience_gained": 4550,
  "level_before": 20,
  "level_after": 24,
  "evolved": false,
  "average_speed_kmh": 10.1,
  "created_at": "2025-11-06T12:30:00Z"
}
```

**計算項目**:
- `average_speed_kmh = (distance_km / duration_seconds) × 3600`

---

## 7. 統計API

### 7.1 ユーザー統計取得

**エンドポイント**: `GET /stats/user`

**説明**: ユーザーの統計情報を取得

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

**レスポンス（成功）**: `200 OK`
```json
{
  "user": {
    "id": "00000000-0000-0000-0000-000000000001",
    "nickname": "たなか",
    "display_id": "1234",
    "display_name": "たなか#1234"
  },
  "character": {
    "level": 25,
    "experience": 500,
    "evolution_stage": 2,
    "character_name": "ハコドン"
  },
  "total_stats": {
    "total_deliveries": 45,
    "total_distance_km": 1250.5,
    "total_duration_seconds": 810000,
    "total_experience_gained": 125050
  },
  "today_stats": {
    "deliveries": 2,
    "distance_km": 55.3,
    "duration_seconds": 19800,
    "experience_gained": 5530
  },
  "week_stats": {
    "deliveries": 12,
    "distance_km": 350.8,
    "duration_seconds": 129600,
    "experience_gained": 35080
  },
  "month_stats": {
    "deliveries": 45,
    "distance_km": 1250.5,
    "duration_seconds": 810000,
    "experience_gained": 125050
  }
}
```

---

## 8. エラーレスポンス

### 8.1 共通エラーコード

| HTTPステータス | エラーコード | 説明 |
|--------------|------------|------|
| 400 | `bad_request` | 不正なリクエスト |
| 400 | `validation_error` | バリデーションエラー |
| 401 | `unauthorized` | 認証が必要 |
| 401 | `invalid_token` | 無効なトークン |
| 403 | `forbidden` | アクセス権限なし |
| 404 | `not_found` | リソースが見つからない |
| **404** | **`profile_not_set`** | **プロフィール未設定** ⭐NEW |
| 409 | `conflict` | リソースの競合 |
| **409** | **`nickname_display_id_conflict`** | **ニックネーム重複** ⭐NEW |
| 500 | `internal_server_error` | サーバーエラー |

### 8.2 エラーレスポンスの構造

```json
{
  "error": {
    "message": "エラーメッセージ（ユーザー向け）",
    "code": "error_code",
    "details": [
      {
        "field": "フィールド名",
        "message": "詳細メッセージ"
      }
    ]
  }
}
```

---

## 9. 認証・認可

### 9.1 認証方式

**Supabase Auth（JWT）**を使用。

**リクエストヘッダー**:
```
Authorization: Bearer {access_token}
```

### 9.2 トークンの有効期限

- **アクセストークン**: 1時間
- **リフレッシュトークン**: 30日

### 9.3 トークンのリフレッシュ

Supabase SDKが自動的にリフレッシュを処理。

---

## 10. レート制限

### 10.1 制限値

**無料プラン（Supabase）**:
- **リクエスト数**: 500リクエスト/秒
- **データベースコネクション**: 60接続

**MVP想定（1,000ユーザー）**:
- 十分余裕あり

### 10.2 レート制限時のレスポンス

**HTTPステータス**: `429 Too Many Requests`

```json
{
  "error": {
    "message": "リクエスト回数が制限を超えました",
    "code": "rate_limit_exceeded",
    "retry_after": 60
  }
}
```

---

## 11. ページネーション

### 11.1 ページネーション方式

**オフセットベース**を使用。

**クエリパラメータ**:
- `limit`: 取得件数（デフォルト: 20、最大: 100）
- `offset`: オフセット

**例**:
```
GET /delivery-sessions?limit=20&offset=40
```

### 11.2 レスポンスの構造

```json
{
  "data": [...],
  "pagination": {
    "limit": 20,
    "offset": 40,
    "total": 150,
    "has_more": true
  }
}
```

---

## 12. 実装例（TypeScript）

### 12.1 プロフィール取得 ⭐NEW

```typescript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function getProfile() {
  const { data: user } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }
  
  const { data, error } = await supabase
    .from('users')
    .select('id, email, nickname, display_id, birth_date, gender, occupation, created_at, updated_at')
    .eq('id', user.id)
    .single();
  
  if (error) {
    if (error.code === 'PGRST116') {
      throw new Error('Profile not set');
    }
    throw error;
  }
  
  return {
    ...data,
    display_name: `${data.nickname}#${data.display_id}`
  };
}
```

### 12.2 プロフィール更新 ⭐NEW

```typescript
async function updateProfile(profileData: {
  nickname: string;
  birth_date: string;
  gender: 'male' | 'female' | 'prefer_not_to_say';
  occupation: string;
}) {
  const { data: user } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }
  
  // プロフィール既存チェック
  const { data: existingProfile } = await supabase
    .from('users')
    .select('nickname, display_id')
    .eq('id', user.id)
    .single();
  
  let display_id: string;
  
  if (!existingProfile || !existingProfile.display_id) {
    // 初回設定: display_idを生成
    display_id = await generateUniqueDisplayId(profileData.nickname);
  } else {
    // 編集: 既存のdisplay_idを維持
    display_id = existingProfile.display_id;
  }
  
  // プロフィール更新
  const { data, error } = await supabase
    .from('users')
    .update({
      nickname: profileData.nickname,
      display_id: display_id,
      birth_date: profileData.birth_date,
      gender: profileData.gender,
      occupation: profileData.occupation,
      updated_at: new Date().toISOString()
    })
    .eq('id', user.id)
    .select()
    .single();
  
  if (error) {
    if (error.code === '23505') {
      throw new Error('Nickname and display_id combination already exists');
    }
    throw error;
  }
  
  return {
    ...data,
    display_name: `${data.nickname}#${data.display_id}`
  };
}

async function generateUniqueDisplayId(nickname: string): Promise<string> {
  let displayId: string;
  let exists = true;
  
  while (exists) {
    displayId = Math.floor(Math.random() * 9999).toString().padStart(4, '0');
    
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

### 12.3 配送セッション作成

```typescript
async function createDeliverySession(sessionData: {
  start_time: string;
  end_time: string;
  distance_km: number;
  duration_seconds: number;
  experience_gained: number;
  level_before: number;
  level_after: number;
  evolved: boolean;
}) {
  const { data: user } = await supabase.auth.getUser();
  
  if (!user) {
    throw new Error('Unauthorized');
  }
  
  const { data, error } = await supabase
    .from('delivery_sessions')
    .insert({
      user_id: user.id,
      ...sessionData
    })
    .select()
    .single();
  
  if (error) {
    throw error;
  }
  
  return data;
}
```

---

## 13. テスト

### 13.1 APIテストケース

**プロフィール関連** ⭐NEW:
- [ ] プロフィール取得（正常）
- [ ] プロフィール取得（未設定）
- [ ] プロフィール更新（初回設定、正常）
- [ ] プロフィール更新（編集、正常）
- [ ] プロフィール更新（バリデーションエラー）
- [ ] プロフィール更新（ニックネーム重複）
- [ ] ニックネーム重複チェック（利用可能）
- [ ] ニックネーム重複チェック（既に使用中）

**認証**:
- [ ] サインアップ（正常）
- [ ] サインアップ（メール重複エラー）
- [ ] ログイン（正常）
- [ ] ログイン（認証エラー）
- [ ] ログアウト（正常）

**キャラクター**:
- [ ] キャラクター一覧取得（正常）
- [ ] キャラクター作成（正常）
- [ ] キャラクター作成（既に所持エラー）
- [ ] キャラクター更新（経験値・レベル）
- [ ] キャラクター更新（進化）

**配送**:
- [ ] 配送セッション作成（正常）
- [ ] 配送履歴取得（全期間）
- [ ] 配送履歴取得（今週）
- [ ] 配送履歴取得（今月）
- [ ] 配送セッション詳細取得（正常）

**統計**:
- [ ] ユーザー統計取得（正常）

---

## 14. まとめ

### 14.1 主要な変更点（v1.1） ⭐NEW

1. **プロフィール関連APIの追加**
   - `GET /users/profile`: プロフィール取得
   - `PUT /users/profile`: プロフィール更新
   - `POST /users/profile/check-nickname`: ニックネーム重複チェック

2. **新しいエラーコード**
   - `profile_not_set`: プロフィール未設定
   - `nickname_display_id_conflict`: ニックネーム重複

3. **ユーザー統計APIの更新**
   - レスポンスにニックネーム・識別番号を追加

4. **実装例の追加**
   - プロフィール取得・更新のTypeScriptコード例
   - `display_id`自動生成ロジック

### 14.2 次のステップ

1. ✅ API設計書の承認（本ドキュメント）
2. フロントエンド実装（プロフィール設定画面）
3. バックエンド実装（Supabase関数）
4. APIテスト
5. 統合テスト

---

以上
