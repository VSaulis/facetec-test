import UIKit
import AVFoundation

protocol OndatoCameraControllerDelegate: AnyObject {
    
    func pickedImage(_ image: UIImage)
}

class OndatoCameraController: NSObject {
    
    var captureSession: AVCaptureSession!
    var input: AVCaptureDeviceInput!
    var output: AVCapturePhotoOutput!
    
    var position: AVCaptureDevice.Position = .front
    
    var success = false
    
    var delegate: OndatoCameraControllerDelegate?
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override init() {
        super.init()
        
        setupCamera()
    }
    
    func changeDeviceTo(position: AVCaptureDevice.Position) {
        if let camera = getCaptureDevice(position: position) {
            self.position = position
            do {
                captureSession.removeInput(input)
                
                input = try AVCaptureDeviceInput(device: camera)
                
                setSessionPreset(sessionPreset: AVCaptureSession.Preset.high)
                
                if(captureSession.canAddInput(input)) {
                    captureSession.addInput(input)

                }
            } catch let error as NSError {

            }
            
        }
    }
    
    private func setupCamera() {
        
        if let camera = getCaptureDevice(position: position) {
            do {
                captureSession = AVCaptureSession()
                input = try AVCaptureDeviceInput(device: camera)
                
                setSessionPreset(sessionPreset: AVCaptureSession.Preset.high)
                
                if(captureSession.canAddInput(input)) {
                    captureSession.addInput(input)
                    
                    output = AVCapturePhotoOutput()
                    
                    if(captureSession.canAddOutput(output)) {
                        captureSession.addOutput(output)
                    }
                    
                    success = true
                    return
                    
                }
            } catch let error as NSError {
            }
        }
        success = false
    }
    
    func getCaptureDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        for device in deviceDescoverySession.devices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func setSessionPreset(sessionPreset: AVCaptureSession.Preset) {
        if captureSession.canSetSessionPreset(sessionPreset) {
            captureSession.sessionPreset = sessionPreset;
        } else if captureSession.canSetSessionPreset(AVCaptureSession.Preset.medium) {
            captureSession.sessionPreset = AVCaptureSession.Preset.medium;
        }
    }
    
    func addPreviewLayer(to view: UIView) {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.frame = view.frame
        videoPreviewLayer?.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer!)
    }
    
    func captureImage() {
        
        #if targetEnvironment(simulator)
        #else
        let settings = AVCapturePhotoSettings()
        settings.isAutoStillImageStabilizationEnabled = true
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat: [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        if let output = output {
            output.capturePhoto(with: settings, delegate: self)
        }
        #endif
        
    }
    
}

extension OndatoCameraController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
        }
        
        guard let dataImage = photo.fileDataRepresentation() else {
            return
        }
        
        let dataProvider = CGDataProvider(data: dataImage as CFData)
        let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        
        var image: UIImage!
        
        var imageOrientation = self.position == .back ? UIImage.Orientation.right : UIImage.Orientation.leftMirrored

        image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: imageOrientation)
        
        delegate?.pickedImage(image)
    }
    
}
