import Foundation
import FaceTecSDK

@objc(Facetec)
class Facetec: NSObject {
    @objc func initialize(productionKeyText: String,
                    deviceKeyIdentifier: String,
                    faceScanEncryptionKey: String,
                    promise: RCTPromiseResolveBlock) {
        FaceTec.sdk.initializeInProductionMode(
            productionKeyText: productionKeyText,
            deviceKeyIdentifier: deviceKeyIdentifier,
            faceScanEncryptionKey: faceScanEncryptionKey) { success in
                promise(FaceTec.sdk.description(for: FaceTec.sdk.getStatus()))
            }
    }

    @objc func checkLiveness(sessionToken: String) {
        let presentedViewController = RCTPresentedViewController()
        let sessionViewController = FaceTec.sdk.createSessionVC(faceScanProcessorDelegate: nil, sessionToken: sessionToken)
        presentedViewController.present(sessionViewController, animated: true)

    }
}
