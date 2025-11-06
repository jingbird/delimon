# Issue #9: GPS計測機能の基本実装（前半）

### 背景 / 目的
expo-locationを導入し、位置情報の権限リクエスト・取得・配送開始/終了ボタンUIを実装する。

- **依存**: #4
- **ラベル**: `frontend`, `feature`, `gps`

---

### スコープ / 作業項目

#### 1. expo-locationのインストール
- `expo-location@18.0+` をインストール
- `app.json` に位置情報権限の設定を追加（iOS: NSLocationWhenInUseUsageDescription、Android: ACCESS_FINE_LOCATION）

#### 2. 配送画面のUI作成
- `app/(tabs)/delivery.tsx` を作成
- 配送開始ボタンを中央に大きく配置
- 配送中は「配送終了」ボタンに変化
- 現在の配送情報を表示（走行距離、所要時間）

#### 3. GPS権限リクエスト
- 配送開始ボタンタップで`Location.requestForegroundPermissionsAsync()`を呼び出し
- 権限が許可された場合は位置情報取得を開始
- 権限が拒否された場合は「位置情報へのアクセスを許可してください」ダイアログ表示

#### 4. 位置情報の取得
- `Location.getCurrentPositionAsync()`で現在位置を取得
- 位置情報をZustandのdeliveryStoreに保存
- 配送開始時にstart_timeを記録

#### 5. 配送状態の管理
- Zustandのdeliveryストアで配送状態（isTracking、startTime、distance）を管理
- 配送開始/終了に応じてボタンのラベル・色を変更

#### 6. エラーハンドリング
- GPS権限エラー: 「位置情報へのアクセスを許可してください。設定アプリから変更できます。」ダイアログ表示
- GPS信号エラー: 「GPS信号が弱いため、位置情報を取得できません」ダイアログ表示

---

### ゴール / 完了条件（Acceptance Criteria）

- [ ] expo-location 18.0+がインストール済み
- [ ] `app/(tabs)/delivery.tsx` で配送画面の基本UI作成（配送開始/終了ボタン）
- [ ] 配送開始ボタンタップでGPS権限リクエスト、許可されたら位置情報取得開始
- [ ] GPS権限がない場合は「位置情報へのアクセスを許可してください」ダイアログ表示
- [ ] 配送中は「配送開始」ボタンが「配送終了」ボタンに変化

---

### テスト観点

#### 機能テスト
- 配送開始ボタンタップでGPS権限リクエストが表示されるか
- GPS権限を許可した場合に位置情報が取得できるか
- GPS権限を拒否した場合にエラーダイアログが表示されるか
- 配送開始後にボタンが「配送終了」に変化するか

#### UIテスト
- 配送開始ボタンが見やすく配置されているか
- 配送中の情報（走行距離、所要時間）が表示されるか
- エラーダイアログが読みやすいか

#### 検証方法
1. アプリで配送画面を開く
2. 配送開始ボタンをタップ→GPS権限リクエストが表示されることを確認
3. 権限を許可→位置情報取得が開始され、ボタンが「配送終了」に変化することを確認
4. 権限を拒否→エラーダイアログが表示されることを確認
5. 配送中の走行距離・所要時間が表示されることを確認（Issue #10で実装）

---

### 実装例

#### `app.json`（権限設定）
```json
{
  "expo": {
    "plugins": [
      [
        "expo-location",
        {
          "locationAlwaysAndWhenInUsePermission": "デリモンは配送中の位置情報を記録するために位置情報を使用します。",
          "locationAlwaysPermission": "デリモンは配送中の位置情報を記録するために位置情報を使用します。",
          "locationWhenInUsePermission": "デリモンは配送中の位置情報を記録するために位置情報を使用します。"
        }
      ]
    ]
  }
}
```

#### `app/(tabs)/delivery.tsx`
```typescript
import React, { useState, useEffect } from 'react';
import { View, StyleSheet, Alert } from 'react-native';
import { Button, Text } from 'react-native-paper';
import * as Location from 'expo-location';
import { useDeliveryStore } from '@/store/deliveryStore';

export default function DeliveryScreen() {
  const { isTracking, startTime, distance, setTracking, setStartTime } = useDeliveryStore();
  const [elapsedTime, setElapsedTime] = useState(0);

  // 配送開始処理
  const handleStartDelivery = async () => {
    try {
      // GPS権限リクエスト
      const { status } = await Location.requestForegroundPermissionsAsync();

      if (status !== 'granted') {
        Alert.alert(
          '権限エラー',
          '位置情報へのアクセスを許可してください。設定アプリから変更できます。',
          [
            { text: 'キャンセル', style: 'cancel' },
            { text: '設定を開く', onPress: () => Location.enableNetworkProviderAsync() },
          ]
        );
        return;
      }

      // 現在位置を取得
      const location = await Location.getCurrentPositionAsync({
        accuracy: Location.Accuracy.High,
      });

      console.log('現在位置:', location.coords);

      // 配送開始
      setTracking(true);
      setStartTime(new Date());

    } catch (error: any) {
      console.error('GPS取得エラー:', error);
      Alert.alert('エラー', 'GPS信号が弱いため、位置情報を取得できません');
    }
  };

  // 配送終了処理
  const handleStopDelivery = () => {
    Alert.alert(
      '配送終了',
      '配送を終了しますか？',
      [
        { text: 'キャンセル', style: 'cancel' },
        {
          text: '終了',
          onPress: () => {
            setTracking(false);
            setStartTime(null);
            // Issue #10で配送セッションをDBに保存
          },
        },
      ]
    );
  };

  // 経過時間を計算
  useEffect(() => {
    let interval: NodeJS.Timeout;
    if (isTracking && startTime) {
      interval = setInterval(() => {
        const now = new Date();
        const elapsed = Math.floor((now.getTime() - startTime.getTime()) / 1000);
        setElapsedTime(elapsed);
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [isTracking, startTime]);

  // 秒数を時:分:秒に変換
  const formatTime = (seconds: number): string => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;
    return `${hours.toString().padStart(2, '0')}:${minutes
      .toString()
      .padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <View style={styles.container}>
      <Text variant="headlineMedium" style={styles.title}>
        配送記録
      </Text>

      {/* 配送情報 */}
      {isTracking && (
        <View style={styles.infoContainer}>
          <View style={styles.infoRow}>
            <Text variant="titleMedium">走行距離</Text>
            <Text variant="headlineSmall">{distance.toFixed(2)} km</Text>
          </View>
          <View style={styles.infoRow}>
            <Text variant="titleMedium">経過時間</Text>
            <Text variant="headlineSmall">{formatTime(elapsedTime)}</Text>
          </View>
        </View>
      )}

      {/* 配送開始/終了ボタン */}
      <Button
        mode="contained"
        onPress={isTracking ? handleStopDelivery : handleStartDelivery}
        style={[
          styles.button,
          isTracking ? styles.stopButton : styles.startButton,
        ]}
        contentStyle={styles.buttonContent}
      >
        {isTracking ? '配送終了' : '配送開始'}
      </Button>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#fff',
  },
  title: {
    marginTop: 20,
    marginBottom: 30,
    textAlign: 'center',
  },
  infoContainer: {
    backgroundColor: '#f5f5f5',
    borderRadius: 10,
    padding: 20,
    marginBottom: 40,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 15,
  },
  button: {
    marginTop: 'auto',
    marginBottom: 40,
  },
  buttonContent: {
    paddingVertical: 10,
  },
  startButton: {
    backgroundColor: '#0066CC',
  },
  stopButton: {
    backgroundColor: '#CC0000',
  },
});
```

#### `src/store/deliveryStore.ts`（既存から追加）
```typescript
// 既に Issue #4 で作成済みだが、再掲載
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

---

### 参考資料

- `docs/05_sitemap_delimon.md` - 配送画面の仕様
- `docs/02_architecture_delimon.md` - GPS計測機能の設計
- [expo-location Documentation](https://docs.expo.dev/versions/latest/sdk/location/)
- [Expo Location Permissions](https://docs.expo.dev/versions/latest/sdk/location/#permissions)

---

### 要確認事項

- GPS権限リクエストの文言の最終確認
- 配送開始/終了ボタンのデザイン（色・サイズ）の最終確認
- GPS精度の設定（High, Balanced, Low）の確認
- バックグラウンド実行時の位置情報取得方法（Issue #10で実装）
