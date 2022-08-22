import UIKit
import Foundation
import FaceTecSDK

typealias LivenessCheckProccesorResult = (success: Bool, result: FaceTecSessionResult?)

class LivenessCheckProcessor: NSObject, URLSessionDelegate, FaceTecFaceScanProcessorDelegate {
    private let service: FaceTecService
    private let enrollmentId: String
    private let sessionToken: String
    private let completion: (LivenessCheckProccesorResult) -> Void

    private(set) var faceScanResultCallback: FaceTecFaceScanResultCallback!
    private(set) var latestSessionResult: FaceTecSessionResult?
    private(set) var isSuccess = false

    init(presenter: UIViewController,
         enrollmentId: String,
         baseUrl: String,
         deviceKeyIdentifier: String,
         sessionToken: String,
         completion: @escaping (LivenessCheckProccesorResult) -> Void) {
        self.completion = completion
        self.enrollmentId = enrollmentId
        self.service = FaceTecService(baseUrl: baseUrl, deviceKeyIdentifier: deviceKeyIdentifier)
        self.sessionToken = sessionToken
        super.init()

        self.startSession(token: sessionToken, presenter: presenter)
    }

    private func startSession(token: String, presenter: UIViewController) {
        DispatchQueue.main.async {
            let viewController = FaceTec.sdk.createSessionVC(faceScanProcessorDelegate: self, sessionToken: token)
            viewController.modalPresentationStyle = .overFullScreen
            presenter.present(viewController, animated: true)
        }
    }

    // Required function that handles calling FaceTec Server to get result and decides how to continue.
    func processSessionWhileFaceTecSDKWaits(sessionResult: FaceTecSessionResult, faceScanResultCallback: FaceTecFaceScanResultCallback) {
        self.latestSessionResult = sessionResult
        self.faceScanResultCallback = faceScanResultCallback

        if sessionResult.status != .sessionCompletedSuccessfully || sessionResult.faceScan == nil {
            faceScanResultCallback.onFaceScanResultCancel()
            return
        }

        // Create and parse request to FaceTec Server.
        service.uploadFaceScan(
            sessionResult: sessionResult,
            enrollmentId: enrollmentId,
            urlSessionDelegate: self) { nextStep in
                switch nextStep {
                case .Succeed:
                    self.isSuccess = true
                    faceScanResultCallback.onFaceScanResultSucceed()
                case .Retry:
                    faceScanResultCallback.onFaceScanResultRetry()
                case .Cancel:
                    faceScanResultCallback.onFaceScanResultCancel()
                }
            }
    }

    // iOS way to get upload progress and update FaceTec UI.
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        faceScanResultCallback.onFaceScanUploadProgress(uploadedPercent: uploadProgress)
    }

    // The final callback FaceTec SDK calls when done with everything.
    func onFaceTecSDKCompletelyDone() {
        completion((isSuccess, latestSessionResult))
    }
}
