//
//  OndatoProgressView.swift
//  OndatoSDK2
//
//  Created by Edgar Kroman on 13/05/2019.
//  Copyright © 2019 logicants. All rights reserved.
//

import UIKit

class OndatoProgressView: UIProgressView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressTintColor = UIColor(red: 253.0/255.0, green: 90.0/255.0, blue: 40.0/255.0, alpha: 1.0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        progressTintColor = UIColor(red: 253.0/255.0, green: 90.0/255.0, blue: 40.0/255.0, alpha: 1.0)
    }
    
}
