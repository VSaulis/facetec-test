// Demonstrates calling the FaceTec Managed Testing API and/or FaceTec Server

import UIKit
import Foundation
import FaceTecSDK

enum LivenessNextStep {
    case Succeed
    case Retry
    case Cancel
}

class FaceTecService {

    let baseUrl: String
    let deviceKeyIdentifier: String

    init(baseUrl: String, deviceKeyIdentifier: String) {
        self.baseUrl = baseUrl
        self.deviceKeyIdentifier = deviceKeyIdentifier
    }

    func uploadFaceScan(sessionResult: FaceTecSessionResult,
                        enrollmentId: String,
                        urlSessionDelegate: URLSessionDelegate,
                        completion: @escaping (LivenessNextStep) -> ()) {

        guard let url = URL(string: baseUrl + "/enrollment-3d") else {
            completion(.Cancel)
            return
        }

        var parameters = getCommonParameters(sessionResult: sessionResult)
        parameters["externalDatabaseRefID"] = enrollmentId

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions(rawValue: 0))

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(deviceKeyIdentifier, forHTTPHeaderField: "X-Device-Key")
        request.addValue(FaceTec.sdk.createFaceTecAPIUserAgentString(sessionResult.sessionId), forHTTPHeaderField: "User-Agent")

        let urlSession = URLSession(configuration: .default, delegate: urlSessionDelegate, delegateQueue:  .main)
        let dataTask = urlSession.dataTask(with: request as URLRequest) { (data, response, error) in
            completion(self.handleResponse(data: data, response: response, error: error))
        }

        dataTask.resume()
    }

    private func handleResponse(data: Data?, response: URLResponse?, error: Error?) -> LivenessNextStep {
        if let data = data,
           let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject] {
            return parseLivenessResponse(response: json)
        }

        return parseLivenessResponse(response: [:])
    }

    private func getCommonParameters(sessionResult: FaceTecSessionResult) -> [String : Any] {
        var parameters: [String : Any] = [:]
        parameters["faceScan"] = sessionResult.faceScanBase64
        parameters["auditTrailImage"] = sessionResult.auditTrailCompressedBase64![0]
        parameters["lowQualityAuditTrailImage"] = sessionResult.lowQualityAuditTrailCompressedBase64![0]

        return parameters
    }

    private func parseLivenessResponse(response: [String: AnyObject]) -> LivenessNextStep {
        guard let success = response["success"] as? Bool else {
            return .Cancel
        }

        if success {
            return .Succeed
        } else {
            return .Retry
        }
    }
}
