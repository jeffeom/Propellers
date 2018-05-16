//
//  User.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-27.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserModel: NSObject {
  var key: String?
  var firstName: String?
  var lastName: String?
  var imageURL: String?
  var uid: String?
  var friends: [String: Bool]?
  var ref: DatabaseReference?
  
  var fullName: String?
  
  init?(snapshot: DataSnapshot) {
    guard let snapshotValue = snapshot.value as? [String:AnyObject] else { return nil }
    key = snapshot.key
    firstName = snapshotValue["first_name"] as? String
    lastName = snapshotValue["last_name"] as? String
    imageURL = snapshotValue["photo_url"] as? String
    friends = snapshotValue["friends"] as? [String: Bool]
    uid = snapshotValue["uid"] as? String
    ref = snapshot.ref
    
    fullName = (firstName?.uppercaseFirst ?? "") + " " + (lastName?.uppercaseFirst ?? "")
  }
  
//  func json() -> [String:Any]? {
//    return ["firstName": firstName ?? "", "lastName": lastName ?? "", "imageURL": imageURL ?? "", "uid": uid ?? "", "friends": friends ?? []] as! [String : AnyObject]
//  }
}
