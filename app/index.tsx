import { View, Text, StyleSheet } from 'react-native';
import { useEffect, useState } from 'react';
import { supabase } from '@/services/supabase';

/**
 * ホーム画面（テスト用）
 */
export default function HomeScreen() {
  const [connectionStatus, setConnectionStatus] = useState<string>('接続確認中...');

  useEffect(() => {
    // Supabase接続確認
    const checkConnection = async () => {
      try {
        const { error } = await supabase.from('_test').select('*').limit(1);

        if (error && error.code === '42P01') {
          // テーブルが存在しない場合（正常）
          setConnectionStatus('✅ Supabase接続成功！');
        } else if (error) {
          setConnectionStatus(`❌ エラー: ${error.message}`);
        } else {
          setConnectionStatus('✅ Supabase接続成功！');
        }
      } catch (err) {
        setConnectionStatus(`❌ 接続失敗: ${err}`);
      }
    };

    checkConnection();
  }, []);

  return (
    <View style={styles.container}>
      <Text style={styles.text}>デリモン - Delivery Monsters</Text>
      <Text style={styles.subText}>MVP開発中...</Text>
      <Text style={styles.status}>{connectionStatus}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  text: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  subText: {
    fontSize: 16,
    color: '#666',
    marginBottom: 24,
  },
  status: {
    fontSize: 14,
    color: '#333',
    fontWeight: '600',
  },
});
