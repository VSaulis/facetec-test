export interface FacetecConfig {
    productionKeyText: string;
    deviceKeyIdentifier: string;
    faceScanEncryptionKey: string;
    sessionToken: string;
}
export declare function initialize(config: FacetecConfig): Promise<boolean>;
