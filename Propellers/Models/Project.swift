//
//  Project.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-27.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import Firebase

class Project: NSObject {
  var key: String?
  var favorite: Int?
  var title: String?
  var type: String?
  var ref: DatabaseReference?
  
  init?(snapshot: DataSnapshot) {
    guard let snapshotValue = snapshot.value as? [String:AnyObject] else { return nil }
    key = snapshot.key
    favorite = snapshotValue["favorite"] as? Int
    title = snapshotValue["title"] as? String
    type = snapshotValue["type"] as? String
    ref = snapshot.ref
  }
  
  init(title: String?, type: String?) {
    self.favorite = 0
    self.title = title
    self.type = type
  }
  
  func json() -> [String:Any]? {
    return ["title": title ?? "", "type": type ?? "", "favorite": favorite ?? 0] as [String : AnyObject]
  }
}
