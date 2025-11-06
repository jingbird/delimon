# Issue #5: ログイン画面の実装

### 背景 / 目的
既存ユーザーがメールアドレス・パスワードでログインできる画面を実装し、Supabase Authと連携してセッション管理を行う。

- **依存**: #4
- **ラベル**: `frontend`, `auth`

---

### スコープ / 作業項目

#### 1. ログイン画面のUI作成
- `app/(auth)/login.tsx` を作成
- React Native Paperのコンポーネント（TextInput, Button）を使用
- メールアドレス入力フィールド
- パスワード入力フィールド（セキュアテキスト入力）
- ログインボタン
- 「初めての方はこちら」リンク

#### 2. バリデーション実装
- メールアドレスの形式チェック（正規表現）
- パスワードの必須チェック
- リアルタイムエラー表示（入力フィールド下）

#### 3. ログイン処理の実装
- `useAuth` フックを使用してログイン関数を呼び出し
- 成功時にホーム画面へ遷移（Expo Routerの`router.replace`を使用）
- エラー時にダイアログでエラーメッセージを表示

#### 4. エラーハンドリング
- 認証エラー（メール/パスワード不一致）: 「メールアドレスまたはパスワードが間違っています」
- ネットワークエラー: 「ネットワークに接続できません」
- その他のエラー: 「ログインに失敗しました」

#### 5. ローディング状態の実装
- ログインボタンタップ中はローディングインジケーターを表示
- ボタンを無効化して二重送信を防止

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] `app/(auth)/login.tsx` でログイン画面のUI作成が完了している
- [ ] メールアドレス・パスワードのバリデーションが実装され、リアルタイムでエラー表示される
- [ ] 「ログイン」ボタンでSupabase Authのログインが実行され、成功時にホーム画面（`(tabs)/index`）へ遷移する
- [ ] 認証エラー時に「メールアドレスまたはパスワードが間違っています」をダイアログで表示する
- [ ] 「初めての方はこちら」リンクでキャラクター選択画面（`(auth)/character-select`）へ遷移する

---

### テスト観点

#### 機能テスト
- 正しいメール・パスワードでログイン成功するか
- 間違ったメール・パスワードでエラーが表示されるか
- バリデーションエラーが正しく表示されるか
- ローディング状態が正しく表示されるか

#### UIテスト
- 入力フィールドが正しく表示されるか
- ボタンが正しく動作するか
- エラーメッセージが読みやすいか

#### 検証方法
1. Supabase Dashboardでテストユーザーを作成（`test@example.com` / `password123`）
2. アプリでログイン画面を開く
3. 正しいメール・パスワードを入力してログイン → ホーム画面へ遷移することを確認
4. 間違ったパスワードを入力 → エラーダイアログが表示されることを確認
5. 無効なメールアドレス（例: `test`）を入力 → バリデーションエラーが表示されることを確認

---

### 実装例

#### `app/(auth)/login.tsx`
```typescript
import React, { useState } from 'react';
import { View, StyleSheet, Alert } from 'react-native';
import { TextInput, Button, Text, HelperText } from 'react-native-paper';
import { useRouter } from 'expo-router';
import { useAuth } from '@/hooks/useAuth';

export default function LoginScreen() {
  const router = useRouter();
  const { login, isLoginLoading } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [emailError, setEmailError] = useState('');
  const [passwordError, setPasswordError] = useState('');

  // メールアドレスのバリデーション
  const validateEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email) {
      setEmailError('メールアドレスを入力してください');
      return false;
    }
    if (!emailRegex.test(email)) {
      setEmailError('正しいメールアドレスを入力してください');
      return false;
    }
    setEmailError('');
    return true;
  };

  // パスワードのバリデーション
  const validatePassword = (password: string): boolean => {
    if (!password) {
      setPasswordError('パスワードを入力してください');
      return false;
    }
    setPasswordError('');
    return true;
  };

  // ログイン処理
  const handleLogin = async () => {
    const isEmailValid = validateEmail(email);
    const isPasswordValid = validatePassword(password);

    if (!isEmailValid || !isPasswordValid) {
      return;
    }

    try {
      await login({ email, password });
      router.replace('/(tabs)'); // ホーム画面へ遷移
    } catch (error: any) {
      // エラーハンドリング
      if (error.message?.includes('Invalid login credentials')) {
        Alert.alert(
          'ログインエラー',
          'メールアドレスまたはパスワードが間違っています'
        );
      } else if (error.message?.includes('Network')) {
        Alert.alert('ネットワークエラー', 'ネットワークに接続できません');
      } else {
        Alert.alert('エラー', 'ログインに失敗しました');
      }
    }
  };

  return (
    <View style={styles.container}>
      <Text variant="headlineMedium" style={styles.title}>
        ログイン
      </Text>

      {/* メールアドレス入力 */}
      <TextInput
        label="メールアドレス"
        value={email}
        onChangeText={(text) => {
          setEmail(text);
          validateEmail(text);
        }}
        keyboardType="email-address"
        autoCapitalize="none"
        error={!!emailError}
        style={styles.input}
      />
      <HelperText type="error" visible={!!emailError}>
        {emailError}
      </HelperText>

      {/* パスワード入力 */}
      <TextInput
        label="パスワード"
        value={password}
        onChangeText={(text) => {
          setPassword(text);
          validatePassword(text);
        }}
        secureTextEntry
        error={!!passwordError}
        style={styles.input}
      />
      <HelperText type="error" visible={!!passwordError}>
        {passwordError}
      </HelperText>

      {/* ログインボタン */}
      <Button
        mode="contained"
        onPress={handleLogin}
        loading={isLoginLoading}
        disabled={isLoginLoading}
        style={styles.button}
      >
        ログイン
      </Button>

      {/* 新規登録リンク */}
      <Button
        mode="text"
        onPress={() => router.push('/(auth)/character-select')}
        style={styles.linkButton}
      >
        初めての方はこちら
      </Button>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    justifyContent: 'center',
  },
  title: {
    marginBottom: 30,
    textAlign: 'center',
  },
  input: {
    marginBottom: 5,
  },
  button: {
    marginTop: 20,
  },
  linkButton: {
    marginTop: 10,
  },
});
```

---

### 参考資料

- `docs/05_sitemap_delimon.md` - ログイン画面の仕様
- `docs/06_screen_transition_delimon.md` - 画面遷移フロー
- `docs/04_api_delimon.md` - ログインAPIの仕様
- [React Native Paper TextInput](https://callstack.github.io/react-native-paper/docs/components/TextInput/)
- [Expo Router Navigation](https://docs.expo.dev/router/navigating-pages/)

---

### 要確認事項

- 「パスワードを忘れた方」リンクは将来機能として除外（MVPには含まない）
- ログイン画面のデザイン（色、フォント、レイアウト）の最終確認
- エラーメッセージの文言の最終確認
