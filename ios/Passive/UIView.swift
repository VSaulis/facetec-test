//
//  UIView+Constraints.swift
//  OndatoSDK2
//
//  Created by Edgar Kroman on 15/05/2019.
//  Copyright © 2019 logicants. All rights reserved.
//

import Foundation

extension UIView {

  func fillSuperview(padding: UIEdgeInsets) {
    anchor(top: superview?.topAnchor, left: superview?.leftAnchor, bottom: superview?.bottomAnchor, right: superview?.rightAnchor, padding: padding)
  }

  func fillSuperview() {
    fillSuperview(padding: .zero)
  }

  func anchor(top: NSLayoutYAxisAnchor?, left:NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,  padding: UIEdgeInsets = .zero, size: CGSize = .zero) {

    translatesAutoresizingMaskIntoConstraints = false

    if let top = top {
      topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
    }

    if let leading = left {
      leftAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
    }

    if let bottom = bottom {
      bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
    }

    if let trailing = right {
      rightAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
    }

    if size.width != 0 {
      widthAnchor.constraint(equalToConstant: size.width).isActive = true
    }

    if size.height != 0 {
      heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }
  }
}
