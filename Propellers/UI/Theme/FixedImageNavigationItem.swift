//
//  FixedImageNavigationItem.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-27.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

class FixedImageNavigationItem: UINavigationItem {
    private let fixedImage: UIImage = #imageLiteral(resourceName: "logoWhite10")
    private let imageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 37, height: 33))
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      let tView = imageView
      tView.contentMode = .scaleAspectFit
      tView.image = fixedImage
      self.titleView = tView
    }
}
