import UIKit
import AVFoundation

protocol OndatoLivenessCaptureViewDelegate: AnyObject {
    func capturedImages(_ images: [UIImage])
}

class OndatoLivenessCaptureView: UIView {

    weak var delegate: OndatoLivenessCaptureViewDelegate?
    
    var cameraController: OndatoCameraController?
    
    var pictureDelegate: OndatoCameraControllerDelegate? {
        didSet {
            cameraController?.delegate = pictureDelegate
        }
    }
    
    private var images = [UIImage]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .black
        
        cameraController = OndatoCameraController()
        cameraController?.delegate = self
        
        if !cameraController!.success {
            cameraController = nil
        }
                
        self.cameraController?.changeDeviceTo(position: .front)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startCamera() {
        DispatchQueue.main.async {
            if let _ = self.layer.sublayers?.first {} else {
                self.cameraController?.addPreviewLayer(to: self)
            }
            self.cameraController?.captureSession.startRunning()
        }
    }
    
    func stopCamera(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.cameraController?.captureSession.stopRunning()
            completion?()
        }
    }
    
    func updatePreviewLayer() {
        cameraController?.videoPreviewLayer?.frame = frame
    }
    
    func captureLiveness() {
        images = []
        takeLivenessPhoto()
    }
    
    private func takeLivenessPhoto() {
        if images.count < 5 {
            cameraController?.captureImage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.takeLivenessPhoto()
            }
        } else {
            delegate?.capturedImages(images)
        }
    }
}

extension OndatoLivenessCaptureView: OndatoCameraControllerDelegate {
    func pickedImage(_ image: UIImage) {
        images.append(image)
    }
}
