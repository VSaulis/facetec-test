// Welcome to the minimized FaceTec Device SDK code to launch User Sessions and retrieve ID Scans (for further processing)!
// This file removes comment annotations, as well as networking calls,
// in an effort to demonstrate how little code is needed to get the FaceTec Device SDKs to work.

// NOTE: This example DOES NOT perform a secure Photo ID Scan.  To perform a secure Photo ID Scan, you need to actually make an API call.
// Please see the PhotoIDScanProcessor file for a complete demonstration using the FaceTec Testing API.

import UIKit
import Foundation
import FaceTecSDK

class PhotoIDScanProcessor_min_no_networking: NSObject, FaceTecIDScanProcessorDelegate {
    var fromViewController: RNOFaceTecViewController!

    init(sampleAppViewController: UIViewController, sessionToken: String) {
        super.init()
        
        // Core FaceTec Device SDK code that starts the User Session.
        let idScanViewController = FaceTec.sdk.createSessionVC(idScanProcessorDelegate: self, sessionToken: sessionToken)
        sampleAppViewController.present(idScanViewController, animated: true, completion: nil)
    }
    
    func processIDScanWhileFaceTecSDKWaits(idScanResult: FaceTecIDScanResult, idScanResultCallback: FaceTecIDScanResultCallback) {
        // Normally a User will complete a Session. This checks to see if there was a cancellation, timeout, or some other non-success case.
        if idScanResult.status != FaceTecIDScanStatus.success {
            idScanResultCallback.onIDScanResultCancel()
            return
        }
        
        // IMPORTANT: FaceTecIDScanStatus.success DOES NOT mean the ID Scan 3d-2d Matching was Successful.
        // It simply means the User completed the Session and a 3D ID Scan was created. You still need to perform the ID Scan 3d-2d Matching on your Servers.

        // These are the core parameters
        var parameters: [String : Any] = [:]
        parameters["idScan"] = idScanResult.idScanBase64
        //
        // Sending up front and back images are non-essential, but are useful for auditing purposes, and are required in order for the FaceTec Server Dashboard to render properly.
        //
        if idScanResult.frontImagesCompressedBase64?.isEmpty == false {
            parameters["idScanFrontImage"] = idScanResult.frontImagesCompressedBase64![0]
        }
        if idScanResult.backImagesCompressedBase64?.isEmpty == false {
            parameters["idScanBackImage"] = idScanResult.backImagesCompressedBase64![0]
        }

        // DEVELOPER TODOS:
        // 1.  Call your own API with the above data and pass into the Server SDK
        // 2.  If the Server SDK successfully processes the data, call onIDScanResultProceedToNextStep(scanResultBlob), passing in the generated scanResultBlob to the parameter.
        //     If onIDScanResultProceedToNextStep(scanResultBlob) returns as true, the ID Scan part of the Session was successful and onFaceTecSDKCompletelyDone() will be called next.
        //     If onIDScanResultProceedToNextStep(scanResultBlob) returns as false, the ID Scan Session is continuing to advance through the User Flow, passing back another Session Result once the next step in the User Flow is complete and ready to be processed by the Server SDK.
        // 3.  onIDScanResultCancel() is provided in case you detect issues with your own API, such as errors processing and returning the scanResultBlob.
        // 4.  onIDScanUploadProgress(yourUploadProgressFloat) is provided to control the Progress Bar.

        // idScanResultCallback.onIDScanResultProceedToNextStep(scanResultBlob)
        // idScanResultCallback.onIDScanResultCancel()
        // idScanResultCallback.onIDScanUploadProgress(yourUploadProgressFloat)
    }
    
    func onFaceTecSDKCompletelyDone() {
        // Entrypoint where FaceTec SDKs are done and you can proceed
    }
}
