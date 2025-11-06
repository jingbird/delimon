# Issue #6: サインアップ画面の実装

### 背景 / 目的
新規ユーザー登録画面を実装し、データ収集同意を取得してSupabase Authでアカウント作成を行う。

- **依存**: #4
- **ラベル**: `frontend`, `auth`

---

### スコープ / 作業項目

#### 1. サインアップ画面のUI作成
- `app/(auth)/signup.tsx` を作成
- React Native Paperのコンポーネント（TextInput, Button, Checkbox）を使用
- メールアドレス入力フィールド
- パスワード入力フィールド（セキュアテキスト入力）
- パスワード確認フィールド（セキュアテキスト入力）
- データ収集同意チェックボックス
- 登録ボタン
- 「既にアカウントをお持ちの方」リンク

#### 2. バリデーション実装
- メールアドレスの形式チェック（正規表現）
- パスワード要件チェック（8文字以上、英数字混在）
- パスワード一致確認（パスワードとパスワード確認が一致）
- リアルタイムエラー表示（入力フィールド下）

#### 3. サインアップ処理の実装
- `useAuth` フックを使用してサインアップ関数を呼び出し
- 成功時にプロフィール設定画面へ遷移（Expo Routerの`router.replace`を使用）
- エラー時にダイアログでエラーメッセージを表示

#### 4. データ収集同意の確認
- チェックボックスがONでないと登録ボタンを無効化
- チェックボックスタップでプライバシーポリシーへのリンクを表示

#### 5. エラーハンドリング
- メールアドレス重複エラー: 「このメールアドレスは既に使用されています」
- パスワード要件未達: 「パスワードは8文字以上、英数字混在で入力してください」
- ネットワークエラー: 「ネットワークに接続できません」
- その他のエラー: 「アカウント作成に失敗しました」

#### 6. ローディング状態の実装
- 登録ボタンタップ中はローディングインジケーターを表示
- ボタンを無効化して二重送信を防止

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] `app/(auth)/signup.tsx` でサインアップ画面のUI作成が完了している
- [ ] パスワード要件チェック（8文字以上、英数字混在）をリアルタイムバリデーション
- [ ] データ収集同意チェックボックスがONでないと登録ボタンが無効
- [ ] サインアップ成功時にプロフィール設定画面へ遷移
- [ ] メールアドレス重複時に「このメールアドレスは既に使用されています」エラー表示

---

### テスト観点

#### 機能テスト
- 正しいメール・パスワードで登録成功するか
- メールアドレス重複時にエラーが表示されるか
- パスワード要件を満たさない場合にエラーが表示されるか
- パスワードとパスワード確認が一致しない場合にエラーが表示されるか
- データ収集同意チェックボックスがOFFの場合に登録ボタンが無効化されるか

#### UIテスト
- 入力フィールドが正しく表示されるか
- チェックボックスが正しく動作するか
- エラーメッセージが読みやすいか
- ローディング状態が正しく表示されるか

#### 検証方法
1. アプリでサインアップ画面を開く
2. 正しいメール・パスワードを入力→データ収集同意ON→登録→プロフィール設定画面へ遷移することを確認
3. 既に登録済みのメールアドレスを入力→エラーダイアログが表示されることを確認
4. パスワードを7文字で入力→バリデーションエラーが表示されることを確認
5. パスワードとパスワード確認が一致しない→バリデーションエラーが表示されることを確認
6. データ収集同意チェックボックスをOFF→登録ボタンが無効化されることを確認

---

### 実装例

#### `app/(auth)/signup.tsx`
```typescript
import React, { useState } from 'react';
import { View, StyleSheet, Alert, ScrollView } from 'react-native';
import { TextInput, Button, Text, HelperText, Checkbox } from 'react-native-paper';
import { useRouter } from 'expo-router';
import { useAuth } from '@/hooks/useAuth';

export default function SignupScreen() {
  const router = useRouter();
  const { signup, isSignupLoading } = useAuth();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [agreedToDataCollection, setAgreedToDataCollection] = useState(false);

  const [emailError, setEmailError] = useState('');
  const [passwordError, setPasswordError] = useState('');
  const [confirmPasswordError, setConfirmPasswordError] = useState('');

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

  // パスワードのバリデーション（8文字以上、英数字混在）
  const validatePassword = (password: string): boolean => {
    if (!password) {
      setPasswordError('パスワードを入力してください');
      return false;
    }
    if (password.length < 8) {
      setPasswordError('パスワードは8文字以上で入力してください');
      return false;
    }
    // 英数字混在チェック
    const hasLetter = /[a-zA-Z]/.test(password);
    const hasNumber = /[0-9]/.test(password);
    if (!hasLetter || !hasNumber) {
      setPasswordError('パスワードは英数字混在で入力してください');
      return false;
    }
    setPasswordError('');
    return true;
  };

  // パスワード確認のバリデーション
  const validateConfirmPassword = (confirmPassword: string): boolean => {
    if (!confirmPassword) {
      setConfirmPasswordError('パスワード（確認）を入力してください');
      return false;
    }
    if (confirmPassword !== password) {
      setConfirmPasswordError('パスワードが一致しません');
      return false;
    }
    setConfirmPasswordError('');
    return true;
  };

  // サインアップ処理
  const handleSignup = async () => {
    const isEmailValid = validateEmail(email);
    const isPasswordValid = validatePassword(password);
    const isConfirmPasswordValid = validateConfirmPassword(confirmPassword);

    if (!isEmailValid || !isPasswordValid || !isConfirmPasswordValid) {
      return;
    }

    try {
      await signup({ email, password });
      router.replace('/(auth)/profile-setup'); // プロフィール設定画面へ遷移
    } catch (error: any) {
      // エラーハンドリング
      if (error.message?.includes('User already registered')) {
        Alert.alert(
          'アカウント作成エラー',
          'このメールアドレスは既に使用されています'
        );
      } else if (error.message?.includes('Network')) {
        Alert.alert('ネットワークエラー', 'ネットワークに接続できません');
      } else {
        Alert.alert('エラー', 'アカウント作成に失敗しました');
      }
    }
  };

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Text variant="headlineMedium" style={styles.title}>
        アカウント登録
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
        label="パスワード（8文字以上、英数字混在）"
        value={password}
        onChangeText={(text) => {
          setPassword(text);
          validatePassword(text);
          // パスワード確認が既に入力されている場合は再バリデーション
          if (confirmPassword) {
            validateConfirmPassword(confirmPassword);
          }
        }}
        secureTextEntry
        error={!!passwordError}
        style={styles.input}
      />
      <HelperText type="error" visible={!!passwordError}>
        {passwordError}
      </HelperText>

      {/* パスワード確認入力 */}
      <TextInput
        label="パスワード（確認）"
        value={confirmPassword}
        onChangeText={(text) => {
          setConfirmPassword(text);
          validateConfirmPassword(text);
        }}
        secureTextEntry
        error={!!confirmPasswordError}
        style={styles.input}
      />
      <HelperText type="error" visible={!!confirmPasswordError}>
        {confirmPasswordError}
      </HelperText>

      {/* データ収集同意チェックボックス */}
      <View style={styles.checkboxContainer}>
        <Checkbox
          status={agreedToDataCollection ? 'checked' : 'unchecked'}
          onPress={() => setAgreedToDataCollection(!agreedToDataCollection)}
        />
        <Text style={styles.checkboxLabel}>
          データ収集に同意します（
          <Text
            style={styles.link}
            onPress={() => router.push('/settings/privacy')}
          >
            プライバシーポリシー
          </Text>
          ）
        </Text>
      </View>

      {/* 登録ボタン */}
      <Button
        mode="contained"
        onPress={handleSignup}
        loading={isSignupLoading}
        disabled={isSignupLoading || !agreedToDataCollection}
        style={styles.button}
      >
        登録
      </Button>

      {/* ログインリンク */}
      <Button
        mode="text"
        onPress={() => router.push('/(auth)/login')}
        style={styles.linkButton}
      >
        既にアカウントをお持ちの方
      </Button>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flexGrow: 1,
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
  checkboxContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 20,
  },
  checkboxLabel: {
    flex: 1,
    marginLeft: 8,
  },
  link: {
    color: '#0066CC',
    textDecorationLine: 'underline',
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

- `docs/05_sitemap_delimon.md` - サインアップ画面の仕様
- `docs/06_screen_transition_delimon.md` - 画面遷移フロー
- `docs/04_api_delimon.md` - サインアップAPIの仕様
- [React Native Paper Checkbox](https://callstack.github.io/react-native-paper/docs/components/Checkbox/)
- [Supabase Auth Signup](https://supabase.com/docs/reference/javascript/auth-signup)

---

### 要確認事項

- プライバシーポリシーの文面・表示方法の確認
- パスワード要件（8文字以上、英数字混在）で十分か、または記号も必須にするか
- サインアップ成功後の画面遷移先（プロフィール設定画面またはキャラクター選択画面）の確認
