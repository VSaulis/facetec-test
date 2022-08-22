import { NativeModules } from 'react-native';
const {
  Facetec
} = NativeModules;
export function initialize(config) {
  const {
    productionKeyText,
    deviceKeyIdentifier,
    faceScanEncryptionKey,
    sessionToken
  } = config;
  return Facetec.init(productionKeyText, deviceKeyIdentifier, faceScanEncryptionKey, sessionToken);
}
//# sourceMappingURL=index.js.map