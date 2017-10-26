//
//  Date+milliseconds.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-23.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import Foundation

extension Date {
  var millisecondsSince1970: Int64? {
    return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
  }
  
  init?(milliseconds: Int64?) {
    guard let milliseconds = milliseconds else { return nil }
    self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
  }
  
  func toString(dateFormat format: String) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: self)
  }
}
