//
// Welcome to the annotated FaceTec Device SDK core code for performing secure Photo ID Matches!
//

import UIKit
import Foundation
import FaceTecSDK

// This is an example self-contained class to perform Photo ID Matches with the FaceTec SDK.
// You may choose to further componentize parts of this in your own Apps based on your specific requirements.
class PhotoIDMatchProcessor: NSObject, Processor, FaceTecFaceScanProcessorDelegate, FaceTecIDScanProcessorDelegate, URLSessionTaskDelegate {
    var latestNetworkRequest: URLSessionTask!
    var success = false
    var state: [AnyHashable: Any] = ["status": RNOUtilities.getStatus(status: RNOStatus.dormant), "message": "Nothing happened yet"]
    var faceScanWasSuccessful = false
    var fromViewController: RNOFaceTecViewController!
    var faceScanResultCallback: FaceTecFaceScanResultCallback!
    var idScanResultCallback: FaceTecIDScanResultCallback!
    
    init(sessionToken: String, fromViewController: RNOFaceTecViewController) {
        self.fromViewController = fromViewController
        super.init()
        
        // In v9.2.2+, configure the messages that will be displayed to the User in each of the possible cases.
        // Based on the internal processing and decision logic about how the flow gets advanced, the FaceTec SDK will use the appropriate, configured message.
        FaceTecCustomization.setIDScanUploadMessageOverrides(
            frontSideUploadStarted: "Uploading\nEncrypted\nID Scan", // Upload of ID front-side has started.
            frontSideStillUploading: "Still Uploading...\nSlow Connection", // Upload of ID front-side is still uploading to Server after an extended period of time.
            frontSideUploadCompleteAwaitingResponse: "Upload Complete", // Upload of ID front-side to the Server is complete.
            frontSideUploadCompleteAwaitingProcessing: "Processing\nID Scan", // Upload of ID front-side is complete and we are waiting for the Server to finish processing and respond.
            backSideUploadStarted: "Uploading\nEncrypted\nBack of ID", // Upload of ID back-side has started.
            backSideStillUploading: "Still Uploading...\nSlow Connection", // Upload of ID back-side is still uploading to Server after an extended period of time.
            backSideUploadCompleteAwaitingResponse: "Upload Complete", // Upload of ID back-side to Server is complete.
            backSideUploadCompleteAwaitingProcessing: "Processing\nBack of ID", // Upload of ID back-side is complete and we are waiting for the Server to finish processing and respond.
            userConfirmedInfoUploadStarted: "Uploading\nYour Confirmed Info", // Upload of User Confirmed Info has started.
            userConfirmedInfoStillUploading: "Still Uploading...\nSlow Connection", // Upload of User Confirmed Info is still uploading to Server after an extended period of time.
            userConfirmedInfoUploadCompleteAwaitingResponse: "Upload Complete", // Upload of User Confirmed Info to the Server is complete.
            userConfirmedInfoUploadCompleteAwaitingProcessing: "Processing", // Upload of User Confirmed Info is complete and we are waiting for the Server to finish processing and respond.
            nfcUploadStarted: "Uploading Encrypted\nNFC Details", // Upload of NFC Details has started.
            nfcStillUploading: "Still Uploading...\nSlow Connection", // Upload of NFC Details is still uploading to Server after an extended period of time.
            nfcUploadCompleteAwaitingResponse: "Upload Complete", // Upload of NFC Details to the Server is complete.
            nfcUploadCompleteAwaitingProcessing: "Processing\nNFC Details", // Upload of NFC Details is complete and we are waiting for the Server to finish processing and respond.
            skippedNFCUploadStarted: "Uploading Encrypted\nID Details", // Upload of ID Details has started.
            skippedNFCStillUploading: "Still Uploading...\nSlow Connection", // Upload of ID Details is still uploading to Server after an extended period of time.
            skippedNFCUploadCompleteAwaitingResponse: "Upload Complete", // Upload of ID Details to the Server is complete.
            skippedNFCUploadCompleteAwaitingProcessing: "Processing\nID Details" // Upload of ID Details is complete and we are waiting for the Server to finish processing and respond.
        );
        
        //
        // Part 1:  Starting the FaceTec Session
        //
        // Required parameters:
        // - delegate:
        // - faceScanProcessorDelegate: A class that implements FaceTecFaceScanProcessor, which handles the FaceScan when the User completes a Session.  In this example, "self" implements the class.
        // - sessionToken:  A valid Session Token you just created by calling your API to get a Session Token from the Server SDK.
        //
        let idScanViewController = FaceTec.sdk.createSessionVC(faceScanProcessorDelegate: self, idScanProcessorDelegate: self, sessionToken: sessionToken)
        
        // In your code, you will be presenting from a UIViewController elsewhere. You may choose to augment this class to pass that UIViewController in.
        // In our example code here, to keep the code in this class simple, we will just get the Sample App's UIViewController statically.
        fromViewController.present(idScanViewController, animated: true, completion: nil)
    }
    
    //
    // Part 2: Handling the Result of a FaceScan
    //
    func processSessionWhileFaceTecSDKWaits(sessionResult: FaceTecSessionResult, faceScanResultCallback: FaceTecFaceScanResultCallback) {
        //
        // DEVELOPER NOTE:  These properties are for demonstration purposes only so the Sample App can get information about what is happening in the processor.
        // In the code in your own App, you can pass around signals, flags, intermediates, and results however you would like.
        //
        fromViewController.setLatestSessionResult(sessionResult: sessionResult)
        
        //
        // DEVELOPER NOTE:  A reference to the callback is stored as a class variable so that we can have access to it while performing the Upload and updating progress.
        //
        self.faceScanResultCallback = faceScanResultCallback
        
        //
        // Part 3: Handles early exit scenarios where there is no FaceScan to handle -- i.e. User Cancellation, Timeouts, etc.
        //
        if sessionResult.status != FaceTecSessionStatus.sessionCompletedSuccessfully {
            if latestNetworkRequest != nil {
                latestNetworkRequest.cancel()
            }
            
            state["status"] = RNOUtilities.getStatus(status: RNOStatus.cancelled)
            state["message"] = "Early exit encoutnered"
            faceScanResultCallback.onFaceScanResultCancel()
            return
        }
        
        //
        // Part 4:  Get essential data off the FaceTecSessionResult
        //
        var parameters: [String : Any] = [:]
        parameters["faceScan"] = sessionResult.faceScanBase64
        parameters["auditTrailImage"] = sessionResult.auditTrailCompressedBase64![0]
        parameters["lowQualityAuditTrailImage"] = sessionResult.lowQualityAuditTrailCompressedBase64![0]
        parameters["externalDatabaseRefID"] = fromViewController.getLatestExternalDatabaseRefID()
        
        //
        // Part 5:  Make the Networking Call to Your Servers.  Below is just example code, you are free to customize based on how your own API works.
        //
        let request = NSMutableURLRequest(url: NSURL(string: RNOConfig.baseURL + "/enrollment-3d")! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions(rawValue: 0))
        request.addValue(RNOConfig.deviceKeyIdentifier, forHTTPHeaderField: "X-Device-Key")
        request.addValue(FaceTec.sdk.createFaceTecAPIUserAgentString(sessionResult.sessionId), forHTTPHeaderField: "User-Agent")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        latestNetworkRequest = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            //
            // Part 6:  In our Sample, we evaluate a boolean response and treat true as was successfully processed and should proceed to next step,
            // and handle all other responses by cancelling out.
            // You may have different paradigms in your own API and are free to customize based on these.
            //
            
            guard let data = data else {
                // CASE:  UNEXPECTED response from API. Our Sample Code keys off a wasProcessed boolean on the root of the JSON object --> You define your own API contracts with yourself and may choose to do something different here based on the error.
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.failed)
                self.state["message"] = "Unexpected response from API"
                faceScanResultCallback.onFaceScanResultCancel()
                return
            }
            
            guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else {
                // CASE:  UNEXPECTED response from API.  Our Sample Code keys off a wasProcessed boolean on the root of the JSON object --> You define your own API contracts with yourself and may choose to do something different here based on the error.
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.failed)
                self.state["message"] = "Unexpected response from API"
                faceScanResultCallback.onFaceScanResultCancel()
                return
            }
            
            guard let scanResultBlob = responseJSON["scanResultBlob"] as? String,
                  let wasProcessed = responseJSON["wasProcessed"] as? Bool else {
                // CASE:  UNEXPECTED response from API.  Our Sample Code keys off a wasProcessed boolean on the root of the JSON object --> You define your own API contracts with yourself and may choose to do something different here based on the error.
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.failed)
                self.state["message"] = "Unexpected response from API"
                faceScanResultCallback.onFaceScanResultCancel()
                return;
            }
            
            // In v9.2.0+, we key off a new property called wasProcessed to determine if we successfully processed the Session result on the Server.
            // Device SDK UI flow is now driven by the proceedToNextStep function, which should receive the scanResultBlob from the Server SDK response.
            if wasProcessed == true {
                
                // Demonstrates dynamically setting the Success Screen Message.
                FaceTecCustomization.setOverrideResultScreenSuccessMessage("Liveness\nConfirmed")
                
                self.state["faceScanBase64"] = sessionResult.faceScanBase64
                self.state["auditImagesBase64"] = sessionResult.auditTrailCompressedBase64
                self.state["lowQualityAuditTrailImagesBase64"] = sessionResult.lowQualityAuditTrailCompressedBase64
                self.state["externalDatabaseRefID"] = self.fromViewController.getLatestExternalDatabaseRefID()
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.succeeded)
                self.state["message"] = "Ready for the next steps"
                
                // In v9.2.0+, simply pass in scanResultBlob to the proceedToNextStep function to advance the User flow.
                // scanResultBlob is a proprietary, encrypted blob that controls the logic for what happens next for the User.
                self.faceScanWasSuccessful = faceScanResultCallback.onFaceScanGoToNextStep(scanResultBlob: scanResultBlob)
            }
            else {
                // CASE:  UNEXPECTED response from API.  Our Sample Code keys off a wasProcessed boolean on the root of the JSON object --> You define your own API contracts with yourself and may choose to do something different here based on the error.
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.failed)
                self.state["message"] = "Unexpected response from API"
                faceScanResultCallback.onFaceScanResultCancel()
                return;
            }
        })
        
        //
        // Part 8:  Actually send the request.
        //
        latestNetworkRequest.resume()
        
        //
        // Part 9:  For better UX, update the User if the upload is taking a while.  You are free to customize and enhance this behavior to your liking.
        //
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            if self.latestNetworkRequest.state == .completed { return }
            
            let uploadMessage:NSMutableAttributedString = NSMutableAttributedString.init(string: "Still Uploading...")
            faceScanResultCallback.onFaceScanUploadMessageOverride(uploadMessageOverride: uploadMessage)
        }
    }
    
    //
    // Part 10: Handling the Result of a FaceScan
    //
    func processIDScanWhileFaceTecSDKWaits(idScanResult: FaceTecIDScanResult, idScanResultCallback: FaceTecIDScanResultCallback) {
        //
        // DEVELOPER NOTE:  These properties are for demonstration purposes only so the Sample App can get information about what is happening in the processor.
        // In the code in your own App, you can pass around signals, flags, intermediates, and results however you would like.
        //
        fromViewController.setLatestIDScanResult(idScanResult: idScanResult)
        
        //
        // DEVELOPER NOTE:  A reference to the callback is stored as a class variable so that we can have access to it while performing the Upload and updating progress.
        //
        self.idScanResultCallback = idScanResultCallback
        
        //
        // Part 11: Handles early exit scenarios where there is no IDScan to handle -- i.e. User Cancellation, Timeouts, etc.
        //
        if idScanResult.status != FaceTecIDScanStatus.success {
            if latestNetworkRequest != nil {
                latestNetworkRequest.cancel()
            }
            state["status"] = RNOUtilities.getStatus(status: RNOStatus.cancelled)
            state["message"] = "Early exit encoutnered"
            idScanResultCallback.onIDScanResultCancel()
            return
        }
        
        // IMPORTANT:  FaceTecSDK.FaceTecIDScanStatus.Success DOES NOT mean the IDScan 3d-2d Matching was Successful.
        // It simply means the User completed the Session and a 3D FaceScan was created. You still need to perform the IDScan 3d-2d Matching on your Servers.
        
        //
        // minMatchLevel allows Developers to specify a Match Level that they would like to target in order for success to be true in the response.
        // minMatchLevel cannot be set to 0.
        // minMatchLevel setting does not affect underlying Algorithm behavior.
        let minMatchLevel = 3
        
        //
        // Part 12:  Get essential data off the FaceTecSessionResult
        //
        var parameters: [String : Any] = [:]
        parameters["idScan"] = idScanResult.idScanBase64
        if idScanResult.frontImagesCompressedBase64?.isEmpty == false {
            parameters["idScanFrontImage"] = idScanResult.frontImagesCompressedBase64![0]
        }
        if idScanResult.backImagesCompressedBase64?.isEmpty == false {
            parameters["idScanBackImage"] = idScanResult.backImagesCompressedBase64![0]
        }
        parameters["minMatchLevel"] = minMatchLevel
        parameters["externalDatabaseRefID"] = fromViewController.getLatestExternalDatabaseRefID()
        
        //
        // Part 13:  Make the Networking Call to Your Servers.  Below is just example code, you are free to customize based on how your own API works.
        //
        let request = NSMutableURLRequest(url: NSURL(string: RNOConfig.baseURL + "/match-3d-2d-idscan")! as URL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions(rawValue: 0))
        request.addValue(RNOConfig.deviceKeyIdentifier, forHTTPHeaderField: "X-Device-Key")
        request.addValue(FaceTec.sdk.createFaceTecAPIUserAgentString((idScanResult.sessionId)!), forHTTPHeaderField: "User-Agent")
        
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        latestNetworkRequest = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            //
            // Part 14:  In our Sample, we evaluate a boolean response and treat true as was successfully processed and should proceed to next step,
            // and handle all other responses by cancelling out.
            // You may have different paradigms in your own API and are free to customize based on these.
            //
            
            guard let data = data else {
                // CASE:  UNEXPECTED response from API. Our Sample Code keys off a wasProcessed boolean on the root of the JSON object --> You define your own API contracts with yourself and may choose to do something different here based on the error.
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.failed)
                self.state["message"] = "Unexpected response from API"
                idScanResultCallback.onIDScanResultCancel()
                return
            }
            
            guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] else {
                // CASE:  UNEXPECTED response from API.  Our Sample Code keys off a wasProcessed boolean on the root of the JSON object --> You define your own API contracts with yourself and may choose to do something different here based on the error.
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.failed)
                self.state["message"] = "Unexpected response from API"
                idScanResultCallback.onIDScanResultCancel()
                return
            }
            
            guard let scanResultBlob = responseJSON["scanResultBlob"] as? String,
                  let wasProcessed = responseJSON["wasProcessed"] as? Bool else {
                // CASE:  UNEXPECTED response from API.  Our Sample Code keys off a wasProcessed boolean on the root of the JSON object --> You define your own API contracts with yourself and may choose to do something different here based on the error.
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.failed)
                self.state["message"] = "Unexpected response from API"
                idScanResultCallback.onIDScanResultCancel()
                return
            }
            
            // In v9.2.0+, we key off a new property called wasProcessed to determine if we successfully processed the Session result on the Server.
            // Device SDK UI flow is now driven by the proceedToNextStep function, which should receive the scanResultBlob from the Server SDK response.
            if wasProcessed == true {
                
                // In v9.2.0+, configure the messages that will be displayed to the User in each of the possible cases.
                // Based on the internal processing and decision logic about how the flow gets advanced, the FaceTec SDK will use the appropriate, configured message.
                // Please note that this programmatic API overrides these same Strings that can also be set via our standard, non-programmatic Text Customization & Localization APIs.
                FaceTecCustomization.setIDScanResultScreenMessageOverrides(
                    successFrontSide: "ID Scan Complete", // Successful scan of ID front-side (ID Types with no back-side).
                    successFrontSideBackNext: "Front of ID\nScanned", // Successful scan of ID front-side (ID Types that do have a back-side).
                    successFrontSideNFCNext: "Front of ID\nScanned", // Successful scan of ID front-side (ID Types that do have NFC but do not have a back-side).
                    successBackSide: "ID Scan Complete", // Successful scan of the ID back-side (ID Types that do not have NFC).
                    successBackSideNFCNext: "Back of ID\nScanned", // Successful scan of the ID back-side (ID Types that do have NFC).
                    successUserConfirmation: "ID Verification\nComplete", // Successful upload of final IDScan containing User-Confirmed ID Text.
                    successNFC: "ID Scan Complete", // Successful upload of the scanned NFC chip information.
                    retryFaceDidNotMatch: "Face Didn’t Match\nHighly Enough", // Case where a Retry is needed because the Face on the Photo ID did not Match the User's Face highly enough.
                    retryIDNotFullyVisible: "ID Document\nNot Fully Visible", // Case where a Retry is needed because a Full ID was not detected with high enough confidence.
                    retryOCRResultsNotGoodEnough: "ID Text Not Legible", // Case where a Retry is needed because the OCR did not produce good enough results and the User should Retry with a better capture.
                    retryIDTypeNotSupported: "ID Type Mismatch\nPlease Try Again", // Case where there is likely no OCR Template installed for the document the User is attempting to scan.
                    skipOrErrorNFC: "ID Details\nUploaded" // Case where NFC Scan was skipped due to the user's interaction or an unexpected error.
                )
                
                self.state["idScan"] = idScanResult.idScanBase64
                if idScanResult.frontImagesCompressedBase64?.isEmpty == false {
                    self.state["idScanFrontImage"] = idScanResult.frontImagesCompressedBase64![0]
                }
                if idScanResult.backImagesCompressedBase64?.isEmpty == false {
                    self.state["idScanBackImage"] = idScanResult.backImagesCompressedBase64![0]
                }
                self.state["minMatchLevel"] = minMatchLevel
                self.state["externalDatabaseRefID"] = self.fromViewController.getLatestExternalDatabaseRefID()
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.succeeded)
                self.state["message"] = "Ready for the next steps"
                
                // In v9.2.0+, simply pass in scanResultBlob to the proceedToNextStep function to advance the User flow.
                // scanResultBlob is a proprietary, encrypted blob that controls the logic for what happens next for the User.
                // Cases:
                //   1.  User must re-scan the same side of the ID that they just tried.
                //   2.  User succeeded in scanning the Front Side of the ID, there is no Back Side, and the User is now sent to the User OCR Confirmation UI.
                //   3.  User succeeded in scanning the Front Side of the ID, there is a Back Side, and the User is sent to the Auto-Capture UI for the Back Side of their ID.
                //   4.  User succeeded in scanning the Back Side of the ID, and the User is now sent to the User OCR Confirmation UI.
                //   5.  The entire process is complete.  This occurs after sending up the final IDScan that contains the User OCR Data.
                self.success = idScanResultCallback.onIDScanResultProceedToNextStep(scanResultBlob: scanResultBlob)
            }
            else {
                // CASE:  UNEXPECTED response from API.  Our Sample Code keys off a wasProcessed boolean on the root of the JSON object --> You define your own API contracts with yourself and may choose to do something different here based on the error.
                self.state["status"] = RNOUtilities.getStatus(status: RNOStatus.failed)
                self.state["message"] = "Unexpected response from API"
                idScanResultCallback.onIDScanResultCancel()
            }
        })
        
        //
        // Part 15:  Actually send the request.
        //
        latestNetworkRequest.resume()
    }
    
    //
    // URLSessionTaskDelegate function to get progress while performing the upload to update the UX.
    //
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress: Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        if idScanResultCallback != nil {
            idScanResultCallback.onIDScanUploadProgress(uploadedPercent: uploadProgress)
        }
        else {
            faceScanResultCallback.onFaceScanUploadProgress(uploadedPercent: uploadProgress)
        }
    }
    
    //
    //  This function gets called after the FaceTec SDK is completely done.  There are no parameters because you have already been passed all data in the processSessionWhileFaceTecSDKWaits function and have already handled all of your own results.
    //
    func onFaceTecSDKCompletelyDone() {
        //
        // DEVELOPER NOTE:  onFaceTecSDKCompletelyDone() is called after the Session has completed or you signal the FaceTec SDK with cancel().
        // Calling a custom function on the Sample App Controller is done for demonstration purposes to show you that here is where you get control back from the FaceTec SDK.
        //
        
        // In your code, you will handle what to do after the Photo ID Scan is successful here.
        // In our example code here, to keep the code in this class simple, we will call a static method on another class to update the Sample App UI.
        self.fromViewController.onComplete()
    }
    
    func isSuccess() -> Bool {
        return success
    }
    
    func getLastState() -> [AnyHashable: Any] {
        return state;
    }
}
