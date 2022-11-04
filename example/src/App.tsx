import React, { FC } from 'react';
import {StyleSheet, View, Text, Button} from 'react-native';
import { FacetecConfig, initialize } from 'react-native-facetec';

const productionKeyText =
  "appId      = *\n" +
  "expiryDate = 2022-09-10\n" +
  "key        = 003046022100cfbc723dcdf7deb47114fe76b1855c9d065cbfdacc5f0da60d16093a7535ab6a02210085fb25a20e0638ddd1b1a1ae1c53e485812c7ace466c07d59041e2a1aa145e5f\n";

const config: FacetecConfig = {
  productionKeyText,
  deviceKeyIdentifier: 'dMV5Lvfy6LFjIQKBREZ5X3Od2RjjxMzd',
  faceScanEncryptionKey:
    '-----BEGIN PUBLIC KEY-----\n' +
    'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAz/j9KaaGdu6mTWRT9Z2n\n' +
    'Ob7/+b048nX5yRCVR6W1QyEHgLRlNN6PUqWHCL+XBBmzfc559dGt4wRQKogVB6PV\n' +
    'na4WV9imc82yvjHNYholZnDu60Ta890s03dO8I6F1wT6Kj52bDKFz5krP6SvvIen\n' +
    'HIdZu7UQwDYayN0wXitwuBcCJA6gUBxFVUkciXijV3L8jc3uspaCPTxKd0z5jGaT\n' +
    'mLdn7ue0PvYwwHqCWvQC6p4ij9xxlERnyPAi8YteeyUJHceLwFchiiFud0s7lPhC\n' +
    'BYs3JMEbdJBgcCEPUG/wA5hBnXzYNI3zMALmjsb9oG2R10g+zjWSzw2bdyJ7HB32\n' +
    'rQIDAQAB\n' +
    '-----END PUBLIC KEY-----',
  sessionToken: '8xY9v1ouXNnFFAu4V8NuqQjexvMwkyrQLkcg9icCNWNxSHN5ym32bwu',
};

const App: FC = () => {

  const start = () => {
    console.log('config', config);
    initialize(config).then(console.log).catch(console.error);
  }

  return (
    <View style={styles.container}>
      <Button title="Start" onPress={start}/>
      <Text>I am running</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default App;
