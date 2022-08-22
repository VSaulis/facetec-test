import Foundation
import FaceTecSDK

@objc(RCTFacetecModule)
class RCTFacetecModule: NSObject {
    private var baseUrlString: String = ""
    private var deviceKeyIdentifier: String = ""

    private var processor: LivenessCheckProcessor?

    @objc func initialize(baseUrlString: String,
                          productionKeyText: String,
                          deviceKeyIdentifier: String,
                          faceScanEncryptionKey: String) {
        self.baseUrlString = baseUrlString
        self.deviceKeyIdentifier = deviceKeyIdentifier

        FaceTec.sdk.initializeInProductionMode(
            productionKeyText: productionKeyText,
            deviceKeyIdentifier: deviceKeyIdentifier,
            faceScanEncryptionKey: faceScanEncryptionKey)
    }

    @objc func setCustomization(_ customization: FaceTecCustomization) {
        FaceTec.sdk.setCustomization(customization)
    }

    @objc func setLocalization(tableName: String, bundleName: String) {
        if let bundlePath = Bundle.main.path(forResource: bundleName, ofType: "bundle"),
           let bundle = Bundle(path: bundlePath) {
            FaceTec.sdk.configureLocalization(withTable: tableName, bundle: bundle)
        }
    }

    @objc func checkLiveness(active: Bool,
                             presenter: UIViewController,
                             enrollmentId: String,
                             baseUrl: String,
                             sessionToken: String,
                             completion: @escaping RCTResponseSenderBlock) {
        if active {
            activeLivenessCheck(presenter: presenter, enrollmentId: enrollmentId, baseUrl: baseUrl, sessionToken: sessionToken, completion: completion)
        } else {
            passiveLivenessCheck(presenter: presenter, completion: completion)
        }
    }

    private func activeLivenessCheck(presenter: UIViewController, enrollmentId: String, baseUrl: String, sessionToken: String, completion: @escaping RCTResponseSenderBlock) {
        processor = LivenessCheckProcessor(
            presenter: presenter,
            enrollmentId: enrollmentId,
            baseUrl: baseUrl,
            deviceKeyIdentifier: deviceKeyIdentifier,
            sessionToken: sessionToken,
            completion: { result in
                if result.result?.status == .sessionCompletedSuccessfully {
                    completion(result.result?.auditTrailCompressedBase64)
                    return
                }

                // Something went wrong
                completion(nil)
            })
    }

    private func passiveLivenessCheck(presenter: UIViewController, completion: @escaping RCTResponseSenderBlock) {
        let viewController = OndatoLivenessViewController()
        viewController.completion = { [weak self] images in
            completion(images)
        }

        presenter.present(viewController, animated: true)
    }
}
