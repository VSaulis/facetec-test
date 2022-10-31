import React, { useEffect, useState } from 'react';
import { StyleSheet, View, Pressable, Text } from 'react-native';
import {
  FacetecViewConfig,
  FacetecView,
  FacetecState,
} from 'react-native-facetec';

const productionKeyText =
  'appId      = *\n' +
  'expiryDate = 2022-09-10\n' +
  'key        = 003046022100cfbc723dcdf7deb47114fe76b1855c9d065cbfdacc5f0da60d16093a7535ab6a02210085fb25a20e0638ddd1b1a1ae1c53e485812c7ace466c07d59041e2a1aa145e5f\n';

const CONFIGURATION: FacetecViewConfig = {
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
  baseURL: 'https://api.facetec.com',
};

export default function App() {
  const [show, setShow] = useState(false);
  const [state, setState] = useState<FacetecState>();

  useEffect(() => {
    const { status, load } = state || {};

    if (status) {
      switch (status) {
        case 'Succeeded':
          // do something
          console.log('Succeeded');
          console.log(JSON.stringify(load, null, 2));
          setShow(false);
          break;
        case 'Failed':
          // do something
          console.log('Failed');
          setShow(false);
          break;
        default:
          console.log(JSON.stringify(state, null, 2));
          // do something
          break;
      }
    }
  }, [state]);

  return (
    <View style={styles.container}>
      <Pressable style={styles.button} onPress={() => setShow(!show)}>
        <Text style={styles.buttonText}>Start</Text>
      </Pressable>
      <FacetecView
        vocalGuidanceMode="full"
        onStateUpdate={setState}
        mode="enroll"
        show={show}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'white',
  },
  button: {
    justifyContent: 'center',
    alignContent: 'center',
    marginVertical: 20,
    backgroundColor: 'orange',
    borderRadius: 10,
    padding: 15,
  },
  buttonText: {
    fontSize: 24,
    fontWeight: 'bold',
  },
});
