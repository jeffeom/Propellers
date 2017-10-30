//
//  String+Uppercase.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-30.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import Foundation

extension String {
  var first: String {
    return String(characters.prefix(1))
  }
  var last: String {
    return String(characters.suffix(1))
  }
  var uppercaseFirst: String {
    return first.uppercased() + String(characters.dropFirst())
  }
}
