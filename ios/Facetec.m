#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(Facetec, NSObject)

RCT_EXTERN_METHOD(initialize: (NSString)baseUrlString
                  productionKeyText: (NSString)productionKeyText
                  deviceKeyIdentifier: (NSString)deviceKeyIdentifier
                  faceScanEncryptionKey: (NSString)faceScanEncryptionKey)

RCT_EXTERN_METHOD(setCustomization: (FaceTecCustomization)customization)

RCT_EXTERN_METHOD(setLocalization: (NSString)tableName
                  bundleName: (NSString)bundleName)

RCT_EXTERN_METHOD(checkLiveness: (UIViewController)presenter
                  enrollmentId: (NSString)enrollmentId
                  completion: (RCTResponseSenderBlock)completion)

@end
