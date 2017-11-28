//
//  UIFont+SizeOfString.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-27.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

extension UIFont {
  func sizeOfString(string: String, constrainedToWidth width: Double) -> CGSize {
    return string.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                               options: .usesLineFragmentOrigin,
                               attributes: [NSAttributedStringKey.font: self],
                               context: nil).size
  }
}
