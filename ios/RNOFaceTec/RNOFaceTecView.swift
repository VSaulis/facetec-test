//
//  RNOFaceTecView.swift
//  RNOFaceTec
//
//  Created by Darius Rainys on 2022-11-01.
//  Copyright © 2022 Facebook. All rights reserved.
//

import UIKit


extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

class RNOFaceTecView : UIView {
    weak var vc: UIViewController?
    
    @objc var onUpdate: RCTBubblingEventBlock? = nil {
        didSet {
            RNOUtilities.onUpdate = onUpdate
        }
    }
    @objc var color: String = "" {
        didSet {
            //self.backgroundColor = hexStringToUIColor(hexColor: color)
        }
    }
    @objc var mode: String = "" {
        didSet {
            print("mode: " + mode)
            switch mode {
            case "authenticate":
                RNOConfig.mode = .authenticate
            case "checkLiveness":
                RNOConfig.mode = .checkLiveness
            case "enroll":
                RNOConfig.mode = .enroll
            case "matchPhotoID":
                RNOConfig.mode = .matchPhotoID
            default:
                print("ReactNativeFaceTec: Chosen mode \(mode) doesn't exist")
                RNOConfig.mode = .unknown
            }
        }
    }
    @objc var vocalGuidanceMode: String = "" {
        didSet {
            print("vocalGuidanceMode: " + vocalGuidanceMode)
            switch vocalGuidanceMode {
            case "minimal":
                RNOUtilities.vocalGuidanceMode = RNOVocalGuidanceMode.minimal
            case "full":
                RNOUtilities.vocalGuidanceMode = RNOVocalGuidanceMode.full
            default:
                RNOUtilities.vocalGuidanceMode = RNOVocalGuidanceMode.off
            }
            
        }
    }
    @objc var baseURL: String = "" {
        didSet {
            print("baseURL: " + baseURL)
            RNOConfig.baseURL = baseURL
        }
    }
    @objc var deviceKeyIdentifier: String = "" {
        didSet {
            print("deviceKeyIdentifier: " + deviceKeyIdentifier)
            RNOConfig.deviceKeyIdentifier = deviceKeyIdentifier
        }
    }
    @objc var productionKeyText: String = "" {
        didSet {
            print("productionKeyText: " + productionKeyText)
            RNOConfig.productionKeyText = productionKeyText
        }
    }
    @objc var faceScanEncryptionKey: String = "" {
        didSet {
            print("faceScanEncryptionKey: " + faceScanEncryptionKey)
            RNOConfig.publicFaceScanEncryptionKey = faceScanEncryptionKey
        }
    }
    
    private var podsBundle: Bundle {
        let bundle = Bundle.main
        return Bundle(url: bundle.url(forResource: "RNOFaceTec",
                                      withExtension: "bundle")!)!
    }
    private func getImage(name imageName: String) -> UIImage {
        return UIImage.init(named: imageName, in: podsBundle, compatibleWith: nil)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if vc == nil {
            embed()
        } else {
            vc?.view.frame = bounds
        }
    }
    
    private func embed() {
        guard
            let parentVC = parentViewController else {
            return
        }
        
        let vc = RNOFaceTecViewController(bundle: podsBundle)
        parentVC.addChild(vc)
        addSubview(vc.view)
        vc.view.frame = bounds
        vc.didMove(toParent: parentVC)
        self.vc = vc
    }
    
    func hexStringToUIColor(hexColor: String) -> UIColor {
        let stringScanner = Scanner(string: hexColor)
        
        if(hexColor.hasPrefix("#")) {
            stringScanner.scanLocation = 1
        }
        var color: UInt32 = 0
        stringScanner.scanHexInt32(&color)
        
        let r = CGFloat(Int(color >> 16) & 0x000000FF)
        let g = CGFloat(Int(color >> 8) & 0x000000FF)
        let b = CGFloat(Int(color) & 0x000000FF)
        
        return UIColor(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    }
}

