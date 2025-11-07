import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { useEffect, useState } from 'react';
import { supabase } from '@/services/supabase';

type CharacterType = {
  id: number;
  name: string;
  name_ja: string;
  evolution_stage: number;
};

/**
 * ホーム画面（テスト用）
 */
export default function HomeScreen() {
  const [connectionStatus, setConnectionStatus] = useState<string>('接続確認中...');
  const [characters, setCharacters] = useState<CharacterType[]>([]);

  useEffect(() => {
    // Supabase接続確認 + character_typesテーブルからデータ取得
    const checkConnection = async () => {
      try {
        // character_typesテーブルから全データ取得
        const { data, error } = await supabase
          .from('character_types')
          .select('id, name, name_ja, evolution_stage')
          .order('id');

        if (error) {
          setConnectionStatus(`❌ エラー: ${error.message}`);
        } else {
          setConnectionStatus(`✅ Supabase接続成功！（${data.length}体のキャラクター取得）`);
          setCharacters(data);
        }
      } catch (err) {
        setConnectionStatus(`❌ 接続失敗: ${err}`);
      }
    };

    checkConnection();
  }, []);

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <Text style={styles.text}>デリモン - Delivery Monsters</Text>
      <Text style={styles.subText}>MVP開発中...</Text>
      <Text style={styles.status}>{connectionStatus}</Text>

      {characters.length > 0 && (
        <View style={styles.characterList}>
          <Text style={styles.listTitle}>キャラクター一覧:</Text>
          {characters.map((char) => (
            <View key={char.id} style={styles.characterItem}>
              <Text style={styles.characterText}>
                {char.id}. {char.name_ja} ({char.name}) - Stage {char.evolution_stage}
              </Text>
            </View>
          ))}
        </View>
      )}
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  content: {
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
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
    marginBottom: 24,
  },
  characterList: {
    width: '100%',
    marginTop: 20,
  },
  listTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  characterItem: {
    backgroundColor: '#f5f5f5',
    padding: 12,
    marginBottom: 8,
    borderRadius: 8,
  },
  characterText: {
    fontSize: 14,
    color: '#333',
  },
});
