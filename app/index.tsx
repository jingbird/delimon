import { View, Text, StyleSheet } from 'react-native';

/**
 * ホーム画面（テスト用）
 */
export default function HomeScreen() {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>デリモン - Delivery Monsters</Text>
      <Text style={styles.subText}>MVP開発中...</Text>
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
  },
});
