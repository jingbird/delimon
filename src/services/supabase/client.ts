import 'react-native-url-polyfill/auto';
import { createClient } from '@supabase/supabase-js';

// 環境変数の取得
const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY;

// 環境変数の検証
if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Supabaseの環境変数が設定されていません。.envファイルを確認してください。'
  );
}

/**
 * Supabaseクライアント
 * アプリ全体で共有されるSupabaseクライアントのインスタンス
 */
export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    // Expo環境でのストレージ設定
    storage: undefined, // デフォルトのストレージを使用（後でsecure-storeに変更）
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
