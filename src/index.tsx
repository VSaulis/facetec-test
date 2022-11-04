import { NativeModules } from 'react-native';
const { Facetec } = NativeModules;

export interface FacetecConfig {
  productionKeyText: string;
  deviceKeyIdentifier: string;
  faceScanEncryptionKey: string;
  sessionToken: string;
}

export function initialize(config: FacetecConfig): Promise<boolean> {
  const { productionKeyText, deviceKeyIdentifier, faceScanEncryptionKey, sessionToken } = config;
  return Facetec.init(productionKeyText, deviceKeyIdentifier, faceScanEncryptionKey, sessionToken);
}
