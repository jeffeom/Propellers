//
//  UIImage+Custom.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-06-21.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

@IBDesignable open class ProImageView: UIImageView {
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  @IBInspectable public var cornerRadius: CGFloat = 10.0 {
    didSet {
      layer.cornerRadius = self.cornerRadius
    }
  }
}

@IBDesignable open class ProButton: UIButton {
  public override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  @IBInspectable public var cornerRadius: CGFloat = 10.0 {
    didSet {
      layer.cornerRadius = self.cornerRadius
    }
  }
}
