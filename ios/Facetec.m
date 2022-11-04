#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Facetec, NSObject)

RCT_EXTERN_METHOD(initialize: (NSString *)productionKeyText
                  deviceKeyIdentifier: (NSString *)deviceKeyIdentifier
                  faceScanEncryptionKey: (NSString *)faceScanEncryptionKey,
                  promise: (RCTPromiseResolveBlock)promise)

RCT_EXTERN_METHOD(checkLiveness: (NSString *)sessionToken)


@end
