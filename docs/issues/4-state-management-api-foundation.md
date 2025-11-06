# Issue #4: 状態管理・API通信の基盤構築

### 背景 / 目的
アプリ全体で使用する状態管理（Zustand）とサーバーステート管理（TanStack Query）の基盤を構築し、以降の機能実装で一貫したデータフローを実現する。

- **依存**: #1, #2
- **ラベル**: `frontend`, `infra`

---

### スコープ / 作業項目

#### 1. パッケージのインストール
- `zustand@5.0+` をインストール
- `@tanstack/react-query@5.59+` をインストール

#### 2. TanStack Query の設定
- `src/lib/queryClient.ts` を作成
- QueryClientの設定（リトライ戦略、キャッシュ時間など）
- アプリのルートでQueryClientProviderを設定

#### 3. Zustand ストアの骨組み作成
以下のストアファイルを作成:
- `src/store/authStore.ts` - 認証状態管理
- `src/store/profileStore.ts` - プロフィール状態管理
- `src/store/characterStore.ts` - キャラクター状態管理
- `src/store/deliveryStore.ts` - 配送状態管理

各ストアには基本的な型定義と空の状態を用意

#### 4. Supabase サービス層の骨組み作成
`src/services/supabase/` 配下に以下のファイルを作成:
- `auth.ts` - 認証関連のAPI関数
- `profile.ts` - プロフィール関連のAPI関数
- `character.ts` - キャラクター関連のAPI関数
- `delivery.ts` - 配送関連のAPI関数

各ファイルには基本的な型定義と空の関数を用意

#### 5. カスタムフックの骨組み作成
`src/hooks/` 配下に以下のファイルを作成:
- `useAuth.ts` - 認証フック
- `useProfile.ts` - プロフィールフック
- `useCharacter.ts` - キャラクターフック
- `useDelivery.ts` - 配送フック

各フックにはTanStack QueryのuseQueryまたはuseMutationを使用

#### 6. 型定義の作成
`src/types/` 配下に以下のファイルを作成:
- `database.ts` - データベースの型定義（Supabaseから自動生成も検討）
- `auth.ts` - 認証関連の型定義
- `profile.ts` - プロフィール関連の型定義
- `character.ts` - キャラクター関連の型定義
- `delivery.ts` - 配送関連の型定義

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] Zustand 5.0+、TanStack Query 5.59+ がインストール済み（`package.json` で確認）
- [ ] `src/store/authStore.ts`, `characterStore.ts`, `deliveryStore.ts`, `profileStore.ts` が作成され、基本的な型定義と空の状態が含まれている
- [ ] `src/lib/queryClient.ts` でTanStack Queryクライアントが設定され、アプリのルートで使用可能
- [ ] `src/services/supabase/auth.ts` にログイン・サインアップ関数の骨組みが実装されている
- [ ] `src/hooks/useAuth.ts` で認証状態を取得できる（空の実装でもOK）

---

### テスト観点

#### ユニットテスト（将来）
- 各ストアのアクションが正しく動作するか
- TanStack Queryのキャッシュが正しく動作するか

#### 検証方法
1. `npm start` でアプリを起動
2. `src/store/authStore.ts` をインポートし、`useAuthStore()` で状態を取得できることを確認
3. `src/lib/queryClient.ts` が正しく設定されていることを確認（エラーが発生しないこと）
4. `src/hooks/useAuth.ts` を使用して、認証状態を取得できることを確認

---

### 実装例

#### `src/lib/queryClient.ts`
```typescript
import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 3, // 3回リトライ
      retryDelay: (attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000), // 指数バックオフ
      staleTime: 1000 * 60 * 5, // 5分間はキャッシュを使用
      cacheTime: 1000 * 60 * 30, // 30分間キャッシュを保持
      refetchOnWindowFocus: false, // ウィンドウフォーカス時に再取得しない
      refetchOnReconnect: true, // ネットワーク再接続時に再取得
    },
    mutations: {
      retry: 1, // 1回のみリトライ
    },
  },
});
```

#### `app/_layout.tsx`（QueryClientProviderの設定）
```typescript
import { QueryClientProvider } from '@tanstack/react-query';
import { queryClient } from '@/lib/queryClient';
import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <QueryClientProvider client={queryClient}>
      <Stack>
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
        <Stack.Screen name="(auth)" options={{ headerShown: false }} />
      </Stack>
    </QueryClientProvider>
  );
}
```

#### `src/store/authStore.ts`
```typescript
import { create } from 'zustand';
import type { User, Session } from '@supabase/supabase-js';

type AuthState = {
  user: User | null;
  session: Session | null;
  isLoading: boolean;
  setUser: (user: User | null) => void;
  setSession: (session: Session | null) => void;
  setLoading: (isLoading: boolean) => void;
};

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  session: null,
  isLoading: true,
  setUser: (user) => set({ user }),
  setSession: (session) => set({ session }),
  setLoading: (isLoading) => set({ isLoading }),
}));
```

#### `src/store/profileStore.ts`
```typescript
import { create } from 'zustand';
import type { UserProfile } from '@/types/profile';

type ProfileState = {
  profile: UserProfile | null;
  isLoading: boolean;
  hasProfile: boolean;
  setProfile: (profile: UserProfile | null) => void;
  setLoading: (isLoading: boolean) => void;
  setHasProfile: (hasProfile: boolean) => void;
};

export const useProfileStore = create<ProfileState>((set) => ({
  profile: null,
  isLoading: true,
  hasProfile: false,
  setProfile: (profile) => set({ profile }),
  setLoading: (isLoading) => set({ isLoading }),
  setHasProfile: (hasProfile) => set({ hasProfile }),
}));
```

#### `src/store/characterStore.ts`
```typescript
import { create } from 'zustand';
import type { Character } from '@/types/character';

type CharacterState = {
  character: Character | null;
  experience: number;
  level: number;
  evolutionStage: 1 | 2 | 3;
  isLoading: boolean;
  setCharacter: (character: Character | null) => void;
  updateExperience: (experience: number) => void;
  updateLevel: (level: number) => void;
  setLoading: (isLoading: boolean) => void;
};

export const useCharacterStore = create<CharacterState>((set) => ({
  character: null,
  experience: 0,
  level: 1,
  evolutionStage: 1,
  isLoading: true,
  setCharacter: (character) => set({ character }),
  updateExperience: (experience) => set({ experience }),
  updateLevel: (level) => set({ level }),
  setLoading: (isLoading) => set({ isLoading }),
}));
```

#### `src/store/deliveryStore.ts`
```typescript
import { create } from 'zustand';
import type { DeliverySession } from '@/types/delivery';

type DeliveryState = {
  isTracking: boolean;
  currentSession: DeliverySession | null;
  distance: number;
  startTime: Date | null;
  setTracking: (isTracking: boolean) => void;
  setSession: (session: DeliverySession | null) => void;
  updateDistance: (distance: number) => void;
  setStartTime: (startTime: Date | null) => void;
};

export const useDeliveryStore = create<DeliveryState>((set) => ({
  isTracking: false,
  currentSession: null,
  distance: 0,
  startTime: null,
  setTracking: (isTracking) => set({ isTracking }),
  setSession: (session) => set({ currentSession: session }),
  updateDistance: (distance) => set({ distance }),
  setStartTime: (startTime) => set({ startTime }),
}));
```

#### `src/services/supabase/auth.ts`
```typescript
import { supabase } from './client';

/**
 * メールアドレスとパスワードでログイン
 */
export async function login(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    throw error;
  }

  return data;
}

/**
 * メールアドレスとパスワードでサインアップ
 */
export async function signup(email: string, password: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  });

  if (error) {
    throw error;
  }

  return data;
}

/**
 * ログアウト
 */
export async function logout() {
  const { error } = await supabase.auth.signOut();

  if (error) {
    throw error;
  }
}

/**
 * 現在のセッションを取得
 */
export async function getSession() {
  const { data, error } = await supabase.auth.getSession();

  if (error) {
    throw error;
  }

  return data.session;
}

/**
 * 現在のユーザーを取得
 */
export async function getCurrentUser() {
  const { data, error } = await supabase.auth.getUser();

  if (error) {
    throw error;
  }

  return data.user;
}
```

#### `src/hooks/useAuth.ts`
```typescript
import { useQuery, useMutation } from '@tanstack/react-query';
import { useAuthStore } from '@/store/authStore';
import * as authService from '@/services/supabase/auth';
import { queryClient } from '@/lib/queryClient';

/**
 * 認証状態を管理するカスタムフック
 */
export function useAuth() {
  const { user, session, isLoading, setUser, setSession, setLoading } = useAuthStore();

  // セッションを取得
  const { data: sessionData } = useQuery({
    queryKey: ['session'],
    queryFn: authService.getSession,
    onSuccess: (session) => {
      setSession(session);
      setLoading(false);
    },
  });

  // ログインミューテーション
  const loginMutation = useMutation({
    mutationFn: ({ email, password }: { email: string; password: string }) =>
      authService.login(email, password),
    onSuccess: (data) => {
      setUser(data.user);
      setSession(data.session);
      queryClient.invalidateQueries(['session']);
    },
  });

  // サインアップミューテーション
  const signupMutation = useMutation({
    mutationFn: ({ email, password }: { email: string; password: string }) =>
      authService.signup(email, password),
    onSuccess: (data) => {
      setUser(data.user);
      setSession(data.session);
      queryClient.invalidateQueries(['session']);
    },
  });

  // ログアウトミューテーション
  const logoutMutation = useMutation({
    mutationFn: authService.logout,
    onSuccess: () => {
      setUser(null);
      setSession(null);
      queryClient.clear(); // 全キャッシュをクリア
    },
  });

  return {
    user,
    session,
    isLoading,
    login: loginMutation.mutate,
    signup: signupMutation.mutate,
    logout: logoutMutation.mutate,
    isLoginLoading: loginMutation.isLoading,
    isSignupLoading: signupMutation.isLoading,
  };
}
```

#### `src/types/profile.ts`
```typescript
export type UserProfile = {
  id: string;
  email: string;
  nickname: string;
  display_id: string;
  display_name: string; // "nickname#display_id"
  birth_date: string; // ISO 8601形式
  gender: 'male' | 'female' | 'prefer_not_to_say';
  occupation: 'truck_driver' | 'light_vehicle_driver' | 'food_delivery' | 'cargo_ship' | 'bus_taxi' | 'other';
  created_at: string;
  updated_at: string;
};
```

---

### 参考資料

- [TanStack Query Documentation](https://tanstack.com/query/latest/docs/react/overview)
- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- `docs/02_architecture_delimon.md` - 状態管理・データフロー
- `CLAUDE.md` - コーディング規約

---

### 要確認事項

- TanStack Queryのキャッシュ戦略（docs/02_architecture_delimon.md参照）の確認
- Zustandのdevtoolsを使用するか（開発中のデバッグ用）
- 型定義はSupabaseから自動生成するか、手動で管理するか
