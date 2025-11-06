# Issue #7: キャラクター選択画面の実装

### 背景 / 目的
初回ユーザーが3種類から相棒キャラクターを選択する画面を実装し、選択結果をSupabase Databaseに保存する。

- **依存**: #6
- **ラベル**: `frontend`, `feature`

---

### スコープ / 作業項目

#### 1. キャラクター選択画面のUI作成
- `app/(auth)/character-select.tsx` を作成
- React Native Paperのコンポーネント（Card, Button）を使用
- 3体のキャラクターカードを縦スクロール形式で表示
- 各カードにキャラクター画像・名前（日本語）・説明を表示
- 「選ぶ」ボタンをカードごとに配置

#### 2. キャラクターマスターデータの取得
- `character_types` テーブルから進化段階1のキャラクターを取得
- ハコブー、ルートン、シールンの3体を表示
- TanStack Queryの`useQuery`でデータフェッチ

#### 3. キャラクター選択処理の実装
- 「選ぶ」ボタンタップで選択確認ダイアログを表示
- 確認後に`characters` テーブルにINSERT（`user_id`, `character_type_id`, `level=1`, `experience=0`, `evolution_stage=1`, `is_partner=true`）
- TanStack Queryの`useMutation`で実装

#### 4. 画面遷移ロジック
- 初回ユーザー（未ログイン）: ローカルストレージに選択を保存→チュートリアル画面へ遷移
- ログイン済みユーザー: DB保存→プロフィール設定画面へ遷移

#### 5. エラーハンドリング
- 既にキャラクター所持時: 「既にキャラクターを所持しています」エラー表示→ホーム画面へ遷移
- ネットワークエラー: 「ネットワークに接続できません」ダイアログ表示

#### 6. ローディング状態の実装
- キャラクターマスターデータ取得中はローディングインジケーターを表示
- 選択処理中はボタンにローディングインジケーターを表示

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] `app/(auth)/character-select.tsx` で3体のキャラクターカード表示
- [ ] 各カードにキャラクター画像・名前・説明を表示
- [ ] 「選ぶ」ボタンでキャラクター選択、charactersテーブルにINSERT
- [ ] 初回ユーザーはローカルストレージに選択保存→チュートリアル画面へ、ログイン済みはDB保存→プロフィール設定画面へ遷移
- [ ] 既にキャラクター所持時は「既にキャラクターを所持しています」エラー表示

---

### テスト観点

#### 機能テスト
- 3体のキャラクターが正しく表示されるか
- 「選ぶ」ボタンでキャラクター選択が完了するか
- 選択後に正しい画面へ遷移するか（初回ユーザーはチュートリアル、ログイン済みはプロフィール設定）
- 既にキャラクター所持時にエラーが表示されるか

#### UIテスト
- キャラクターカードが見やすく配置されているか
- 画像が正しく表示されるか
- 選択確認ダイアログが正しく表示されるか
- ローディング状態が正しく表示されるか

#### 検証方法
1. アプリでキャラクター選択画面を開く
2. 3体のキャラクター（ハコブー、ルートン、シールン）が表示されることを確認
3. ハコブーの「選ぶ」ボタンをタップ→確認ダイアログが表示されることを確認
4. 確認→選択処理が完了し、適切な画面へ遷移することを確認
5. 既にキャラクターを所持しているユーザーでアクセス→エラーメッセージが表示されることを確認

---

### 実装例

#### `app/(auth)/character-select.tsx`
```typescript
import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import { Card, Button, Text, ActivityIndicator } from 'react-native-paper';
import { useRouter } from 'expo-router';
import { useQuery, useMutation } from '@tanstack/react-query';
import { useCharacter } from '@/hooks/useCharacter';
import { useAuthStore } from '@/store/authStore';
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { CharacterType } from '@/types/character';

export default function CharacterSelectScreen() {
  const router = useRouter();
  const { user } = useAuthStore();
  const { createCharacter, isCreateLoading } = useCharacter();

  // キャラクターマスターデータを取得（進化段階1のみ）
  const { data: characterTypes, isLoading } = useQuery<CharacterType[]>({
    queryKey: ['character_types', { evolution_stage: 1 }],
    queryFn: async () => {
      // character_typesテーブルから進化段階1のキャラクターを取得
      // 実装は src/services/supabase/character.ts に記載
      return [
        {
          id: 1,
          name: 'Hakoboo',
          name_ja: 'ハコブー',
          evolution_stage: 1,
          evolves_at_level: 20,
          description: '配送の相棒。箱型の体が特徴的。',
          image_url: '/images/characters/hakoboo_1.png',
        },
        {
          id: 4,
          name: 'Rooton',
          name_ja: 'ルートン',
          evolution_stage: 1,
          evolves_at_level: 20,
          description: 'ルートを見つけるのが得意。',
          image_url: '/images/characters/rooton_1.png',
        },
        {
          id: 7,
          name: 'Sealn',
          name_ja: 'シールン',
          evolution_stage: 1,
          evolves_at_level: 20,
          description: 'シールを貼るのが得意。',
          image_url: '/images/characters/sealn_1.png',
        },
      ];
    },
  });

  // キャラクター選択処理
  const handleSelectCharacter = async (characterType: CharacterType) => {
    Alert.alert(
      'キャラクター選択',
      `${characterType.name_ja}を相棒にしますか？`,
      [
        { text: 'キャンセル', style: 'cancel' },
        {
          text: '選ぶ',
          onPress: async () => {
            try {
              if (user) {
                // ログイン済みユーザー: DBに保存
                await createCharacter({
                  user_id: user.id,
                  character_type_id: characterType.id,
                  level: 1,
                  experience: 0,
                  evolution_stage: 1,
                  is_partner: true,
                });
                router.replace('/(auth)/profile-setup'); // プロフィール設定画面へ
              } else {
                // 初回ユーザー: ローカルストレージに保存
                await AsyncStorage.setItem(
                  'selected_character_type_id',
                  characterType.id.toString()
                );
                router.replace('/tutorial'); // チュートリアル画面へ
              }
            } catch (error: any) {
              if (error.message?.includes('already exists')) {
                Alert.alert(
                  'エラー',
                  '既にキャラクターを所持しています',
                  [{ text: 'OK', onPress: () => router.replace('/(tabs)') }]
                );
              } else if (error.message?.includes('Network')) {
                Alert.alert('ネットワークエラー', 'ネットワークに接続できません');
              } else {
                Alert.alert('エラー', 'キャラクター選択に失敗しました');
              }
            }
          },
        },
      ]
    );
  };

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" />
        <Text style={styles.loadingText}>キャラクター情報を読み込み中...</Text>
      </View>
    );
  }

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text variant="headlineMedium" style={styles.title}>
        相棒を選ぼう
      </Text>
      <Text style={styles.subtitle}>
        あなたの配送を一緒に支える相棒を選んでください
      </Text>

      {characterTypes?.map((characterType) => (
        <Card key={characterType.id} style={styles.card}>
          <Card.Cover source={{ uri: characterType.image_url }} />
          <Card.Content style={styles.cardContent}>
            <Text variant="headlineSmall">{characterType.name_ja}</Text>
            <Text variant="bodyMedium" style={styles.description}>
              {characterType.description}
            </Text>
          </Card.Content>
          <Card.Actions>
            <Button
              mode="contained"
              onPress={() => handleSelectCharacter(characterType)}
              loading={isCreateLoading}
              disabled={isCreateLoading}
              style={styles.selectButton}
            >
              選ぶ
            </Button>
          </Card.Actions>
        </Card>
      ))}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    padding: 20,
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  loadingText: {
    marginTop: 10,
  },
  title: {
    marginBottom: 10,
    textAlign: 'center',
  },
  subtitle: {
    marginBottom: 30,
    textAlign: 'center',
    color: '#666',
  },
  card: {
    marginBottom: 20,
  },
  cardContent: {
    marginTop: 10,
  },
  description: {
    marginTop: 5,
    color: '#666',
  },
  selectButton: {
    flex: 1,
    marginHorizontal: 10,
  },
});
```

#### `src/hooks/useCharacter.ts`（追加実装）
```typescript
import { useMutation } from '@tanstack/react-query';
import { useCharacterStore } from '@/store/characterStore';
import * as characterService from '@/services/supabase/character';
import { queryClient } from '@/lib/queryClient';

export function useCharacter() {
  const { character, setCharacter, setLoading } = useCharacterStore();

  // キャラクター作成ミューテーション
  const createCharacterMutation = useMutation({
    mutationFn: characterService.createCharacter,
    onSuccess: (data) => {
      setCharacter(data);
      queryClient.invalidateQueries(['characters']);
    },
  });

  return {
    character,
    createCharacter: createCharacterMutation.mutate,
    isCreateLoading: createCharacterMutation.isLoading,
  };
}
```

#### `src/services/supabase/character.ts`（追加実装）
```typescript
import { supabase } from './client';
import type { Character } from '@/types/character';

/**
 * キャラクターを作成
 */
export async function createCharacter(input: {
  user_id: string;
  character_type_id: number;
  level: number;
  experience: number;
  evolution_stage: number;
  is_partner: boolean;
}): Promise<Character> {
  const { data, error } = await supabase
    .from('characters')
    .insert(input)
    .select()
    .single();

  if (error) {
    throw error;
  }

  return data;
}

/**
 * 進化段階1のキャラクタータイプを取得
 */
export async function getStarterCharacterTypes() {
  const { data, error } = await supabase
    .from('character_types')
    .select('*')
    .eq('evolution_stage', 1)
    .order('id', { ascending: true });

  if (error) {
    throw error;
  }

  return data;
}
```

---

### 参考資料

- `docs/05_sitemap_delimon.md` - キャラクター選択画面の仕様
- `docs/06_screen_transition_delimon.md` - 画面遷移フロー
- `docs/03_database_delimon.md` - charactersテーブル・character_typesテーブルの仕様
- [React Native Paper Card](https://callstack.github.io/react-native-paper/docs/components/Card/)
- [AsyncStorage](https://react-native-async-storage.github.io/async-storage/)

---

### 要確認事項

- キャラクター画像（`/images/characters/hakoboo_1.png` 等）の準備状況
- 初回ユーザーとログイン済みユーザーの画面遷移フローの最終確認
- 選択確認ダイアログの文言の最終確認
- キャラクター説明文の最終確認
