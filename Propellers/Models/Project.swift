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
  var imageURL: String?
  var favorite: Int = 0
  var title: String?
  var type: String?
  var ref: DatabaseReference?
  
  init?(snapshot: DataSnapshot) {
    guard let snapshotValue = snapshot.value as? [String:AnyObject] else { return nil }
    key = snapshot.key
    imageURL = snapshotValue["imageURL"] as? String
    favorite = snapshotValue["favorite"] as! Int
    title = snapshotValue["title"] as? String
    type = snapshotValue["type"] as? String
    ref = snapshot.ref
  }
  
  init(imageURL: String?, title: String?, type: String?, favorite: Int) {
    self.imageURL = imageURL
    self.favorite = favorite
    self.title = title
    self.type = type
  }
  
  init(data: [String: AnyObject]) {
    self.imageURL = data["imageURL"] as? String
    self.favorite = data["favorite"] as! Int
    self.title = data["title"] as? String
    self.type = data["type"] as? String
  }
  
  func json() -> [String:Any]? {
    return ["title": title ?? "", "type": type ?? "", "favorite": favorite, "imageURL": imageURL ?? ""] as [String : AnyObject]
  }
}
