//
//  OndatoFilledButton.swift
//  OndatoSDK2
//
//  Created by Edgar Kroman on 13/05/2019.
//  Copyright © 2019 logicants. All rights reserved.
//

import UIKit

enum OndatoButtonStyle: String {
    case simple
    case filled
    case borderedCaptureBig
    case borderedCaptureSmall
    case borderedBasic
}

class OndatoButton: UIButton {
    
    var cameraImageView: UIImageView = {
      let imageView = UIImageView(image: UIImage(named: "ic_camera"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.white
        return imageView
    }()
    
    var style = OndatoButtonStyle.filled
    
    init(_ style: OndatoButtonStyle) {
        super.init(frame: .zero)
        
        switch style {
        case .simple:
            break
        case .filled:
            self.backgroundColor = UIColor(red: 253.0/255.0, green: 90.0/255.0, blue: 40.0/255.0, alpha: 1.0)
            self.setTitleColor(UIColor.white, for: .normal)
        case .borderedBasic:
            self.titleLabel?.lineBreakMode = .byWordWrapping
            
            self.backgroundColor = .clear
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 2
            self.setTitleColor(UIColor.white, for: .normal)
            self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        case .borderedCaptureBig,
             .borderedCaptureSmall:
            
            self.titleLabel?.lineBreakMode = .byWordWrapping
            
            self.backgroundColor = .clear
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 2
            self.setTitleColor(UIColor.white, for: .normal)
            if style == .borderedCaptureSmall {
                self.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 36)
            }
            
            addSubview(cameraImageView)
            cameraImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            cameraImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -24).isActive = true
            cameraImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
            cameraImageView.heightAnchor.constraint(equalTo: cameraImageView.widthAnchor).isActive = true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = frame.height/2.0
        
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
