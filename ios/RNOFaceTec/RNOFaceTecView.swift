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
    @objc var sessionToken: String = "" {
        didSet {
            print("sessionToken: " + sessionToken)
            RNOConfig.sessionToken = sessionToken
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
}

