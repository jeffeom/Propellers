//
//  GeneralTabBarItem.swift
//  Propellers
//
//  Created by 엄하은 on 2017. 11. 13..
//  Copyright © 2017년 Jeff Eom. All rights reserved.
//

import UIKit

class GeneralTabBarItem: UITabBarItem {
  override func awakeFromNib() {
    super.awakeFromNib()
    setup()
  }
  
  func setup() {
    if let image = image {
      self.image = image.withRenderingMode(.alwaysOriginal)
      self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.lightGray,
                                   NSAttributedStringKey.font: UIFont(name: "Futura-Medium", size: 11) ?? UIFont.systemFont(ofSize: 10.5)],
                                  for:.normal)
    }
    if let image = selectedImage {
      selectedImage = image.withRenderingMode(.alwaysOriginal)
      self.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor(red: 74/255,
                                                                                  green: 74/255,
                                                                                  blue: 74/255,
                                                                                  alpha: 1.0),
                                   NSAttributedStringKey.font: UIFont(name: "Futura-Medium", size: 11) ?? UIFont.systemFont(ofSize: 10.5)],
                                  for:.selected)
    }
  }
}