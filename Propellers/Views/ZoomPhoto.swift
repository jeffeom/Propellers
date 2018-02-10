//
//  ZoomPhoto.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-02-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import NYTPhotoViewer

class ZoomPhoto: NSObject, NYTPhoto {
  var image: UIImage?
  var imageData: Data?
  var placeholderImage: UIImage?
  var attributedCaptionTitle: NSAttributedString?
  var attributedCaptionSummary: NSAttributedString?
  var attributedCaptionCredit: NSAttributedString?
  
  init(image: UIImage?, placeHolder: UIImage?) {
    
    self.image = image
    self.placeholderImage = placeHolder
    super.init()
  }
}
