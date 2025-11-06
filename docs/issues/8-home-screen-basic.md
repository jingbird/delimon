# Issue #8: ホーム画面の基本実装

### 背景 / 目的
タブナビゲーションを設定し、相棒キャラクターのレベル・経験値を表示するホーム画面を作成する。

- **依存**: #7
- **ラベル**: `frontend`, `feature`

---

### スコープ / 作業項目

#### 1. タブナビゲーションの設定
- `app/(tabs)/_layout.tsx` を作成
- Expo Routerのタブ機能を使用してタブナビゲーションを実装
- 4つのタブ（ホーム・配送・図鑑・履歴）を設定
- 各タブにアイコンとラベルを表示

#### 2. ホーム画面のUI作成
- `app/(tabs)/index.tsx` を作成
- キャラクター画像を中央に大きく表示
- キャラクター名（日本語）を表示
- レベルを表示（例: Lv.5）
- 経験値バーを表示（現在の経験値 / 次のレベルまでの経験値）
- 右上に設定ボタンを配置

#### 3. キャラクター情報の取得
- TanStack Queryの`useQuery`でキャラクター情報を取得
- `characters` テーブルから相棒キャラクター（`is_partner=true`）を取得
- キャラクタータイプ情報も`character_types`テーブルから取得（LEFT JOIN）

#### 4. 経験値バーの実装
- React Native Paperの`ProgressBar`を使用
- 現在の経験値をパーセンテージで表示（例: 500 / 1000 = 50%）
- 経験値バーの下に「500 / 1000 経験値」のようにテキスト表示

#### 5. Pull-to-Refreshの実装
- React Nativeの`RefreshControl`を使用
- 下にスワイプしてキャラクター情報を再取得
- ローディング中はリフレッシュインジケーターを表示

#### 6. 設定ボタンの配置
- 右上に設定アイコンボタンを配置
- タップ時は仮で何もしない（将来的に設定画面へ遷移）

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] `app/(tabs)/_layout.tsx` でタブナビゲーション（ホーム・配送・図鑑・履歴）設定完了
- [ ] `app/(tabs)/index.tsx` でキャラクター画像・名前・レベル・経験値バーを表示
- [ ] 経験値バーが現在の経験値/次のレベルまでの経験値を視覚的に表示
- [ ] 右上に設定ボタンを配置（タップ時は仮で何もしない）
- [ ] Pull-to-refreshでキャラクター情報を再取得

---

### テスト観点

#### 機能テスト
- タブナビゲーションが正しく動作するか（ホーム・配送・図鑑・履歴の切り替え）
- キャラクター情報が正しく表示されるか（画像・名前・レベル・経験値）
- 経験値バーが正しく計算されて表示されるか
- Pull-to-refreshでデータが再取得されるか

#### UIテスト
- キャラクター画像が中央に大きく表示されるか
- 経験値バーが見やすく配置されているか
- タブアイコンが適切に表示されるか
- 設定ボタンが右上に配置されているか

#### 検証方法
1. アプリでホーム画面を開く
2. キャラクター画像・名前・レベル・経験値バーが表示されることを確認
3. 経験値バーが現在の経験値を視覚的に表示していることを確認
4. 下にスワイプしてPull-to-refreshが動作することを確認
5. タブナビゲーションで配送・図鑑・履歴画面へ切り替えできることを確認（仮画面でOK）
6. 右上の設定ボタンをタップ→何も起きないことを確認（仮実装）

---

### 実装例

#### `app/(tabs)/_layout.tsx`
```typescript
import React from 'react';
import { Tabs } from 'expo-router';
import { MaterialCommunityIcons } from '@expo/vector-icons';

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: '#0066CC',
        tabBarInactiveTintColor: '#666',
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'ホーム',
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="home" color={color} size={size} />
          ),
        }}
      />
      <Tabs.Screen
        name="delivery"
        options={{
          title: '配送',
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="truck" color={color} size={size} />
          ),
        }}
      />
      <Tabs.Screen
        name="collection"
        options={{
          title: '図鑑',
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="book-open" color={color} size={size} />
          ),
        }}
      />
      <Tabs.Screen
        name="history"
        options={{
          title: '履歴',
          tabBarIcon: ({ color, size }) => (
            <MaterialCommunityIcons name="history" color={color} size={size} />
          ),
        }}
      />
    </Tabs>
  );
}
```

#### `app/(tabs)/index.tsx`
```typescript
import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, RefreshControl, Image } from 'react-native';
import { Text, ProgressBar, IconButton } from 'react-native-paper';
import { useQuery } from '@tanstack/react-query';
import { useAuthStore } from '@/store/authStore';
import * as characterService from '@/services/supabase/character';

export default function HomeScreen() {
  const { user } = useAuthStore();
  const [refreshing, setRefreshing] = useState(false);

  // 相棒キャラクター情報を取得
  const {
    data: character,
    isLoading,
    refetch,
  } = useQuery({
    queryKey: ['partner_character', user?.id],
    queryFn: () => characterService.getPartnerCharacter(user!.id),
    enabled: !!user,
  });

  // Pull-to-refresh処理
  const onRefresh = async () => {
    setRefreshing(true);
    await refetch();
    setRefreshing(false);
  };

  // 次のレベルまでの必要経験値を計算（1レベル=1,000経験値）
  const experienceForNextLevel = character ? character.level * 1000 : 1000;
  const currentExperience = character?.experience || 0;
  const experienceProgress = currentExperience / experienceForNextLevel;

  if (isLoading) {
    return (
      <View style={styles.loadingContainer}>
        <Text>キャラクター情報を読み込み中...</Text>
      </View>
    );
  }

  return (
    <ScrollView
      contentContainerStyle={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      {/* 設定ボタン */}
      <View style={styles.headerContainer}>
        <IconButton
          icon="cog"
          size={24}
          onPress={() => {
            // 仮実装: 何もしない
            console.log('設定ボタンがタップされました');
          }}
          style={styles.settingsButton}
        />
      </View>

      {/* キャラクター画像 */}
      <View style={styles.characterContainer}>
        {character?.character_type?.image_url && (
          <Image
            source={{ uri: character.character_type.image_url }}
            style={styles.characterImage}
            resizeMode="contain"
          />
        )}
      </View>

      {/* キャラクター情報 */}
      <View style={styles.infoContainer}>
        <Text variant="headlineLarge" style={styles.characterName}>
          {character?.character_type?.name_ja || 'キャラクター名'}
        </Text>
        <Text variant="titleMedium" style={styles.level}>
          Lv.{character?.level || 1}
        </Text>

        {/* 経験値バー */}
        <View style={styles.experienceContainer}>
          <Text variant="bodyMedium" style={styles.experienceLabel}>
            経験値
          </Text>
          <ProgressBar
            progress={experienceProgress}
            color="#0066CC"
            style={styles.progressBar}
          />
          <Text variant="bodySmall" style={styles.experienceText}>
            {currentExperience} / {experienceForNextLevel}
          </Text>
        </View>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
    padding: 20,
    backgroundColor: '#fff',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  headerContainer: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    marginBottom: 20,
  },
  settingsButton: {
    margin: 0,
  },
  characterContainer: {
    alignItems: 'center',
    marginVertical: 40,
  },
  characterImage: {
    width: 250,
    height: 250,
  },
  infoContainer: {
    alignItems: 'center',
  },
  characterName: {
    marginBottom: 10,
    fontWeight: 'bold',
  },
  level: {
    marginBottom: 30,
    color: '#666',
  },
  experienceContainer: {
    width: '100%',
    marginTop: 20,
  },
  experienceLabel: {
    marginBottom: 8,
    color: '#666',
  },
  progressBar: {
    height: 12,
    borderRadius: 6,
  },
  experienceText: {
    marginTop: 8,
    textAlign: 'center',
    color: '#666',
  },
});
```

#### `src/services/supabase/character.ts`（追加実装）
```typescript
import { supabase } from './client';
import type { Character } from '@/types/character';

/**
 * 相棒キャラクターを取得（キャラクタータイプ情報も含む）
 */
export async function getPartnerCharacter(userId: string): Promise<Character> {
  const { data, error } = await supabase
    .from('characters')
    .select(`
      *,
      character_type:character_types (*)
    `)
    .eq('user_id', userId)
    .eq('is_partner', true)
    .single();

  if (error) {
    throw error;
  }

  return data;
}
```

#### `src/types/character.ts`（追加型定義）
```typescript
export type CharacterType = {
  id: number;
  name: string;
  name_ja: string;
  evolution_stage: 1 | 2 | 3;
  evolves_at_level: number | null;
  description: string;
  image_url: string;
};

export type Character = {
  id: string;
  user_id: string;
  character_type_id: number;
  level: number;
  experience: number;
  evolution_stage: 1 | 2 | 3;
  is_partner: boolean;
  created_at: string;
  updated_at: string;
  character_type?: CharacterType;
};
```

---

### 参考資料

- `docs/05_sitemap_delimon.md` - ホーム画面の仕様
- `docs/02_architecture_delimon.md` - タブナビゲーションの設計
- [Expo Router Tabs](https://docs.expo.dev/router/advanced/tabs/)
- [React Native Paper ProgressBar](https://callstack.github.io/react-native-paper/docs/components/ProgressBar/)
- [React Native RefreshControl](https://reactnative.dev/docs/refreshcontrol)

---

### 要確認事項

- キャラクター画像のサイズ・アスペクト比の確認
- 経験値バーのデザイン（色・形状）の最終確認
- タブアイコンの選択の最終確認
- レベルアップに必要な経験値の計算式（1レベル=1,000経験値）の確認
