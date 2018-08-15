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
  var uid: String?
  var firstName: String?
  var lastName: String?
  var email: String?
  var userDescription: String?
  var profession: String?
  var profileImage: String?
  var mainImage: String?
  var friends: [String]?
  var portfolios: [String]?
  var passions: [String]?
  var ref: DatabaseReference?
  
  var fullName: String?
  
  init?(snapshot: DataSnapshot) {
    guard let snapshotValue = snapshot.value as? [String:AnyObject] else { return nil }
    key = snapshot.key
    uid = snapshotValue["uid"] as? String
    firstName = snapshotValue["first_name"] as? String
    lastName = snapshotValue["last_name"] as? String
    email = snapshotValue["email"] as? String
    userDescription = snapshotValue["description"] as? String
    profession = snapshotValue["profession"] as? String
    profileImage = snapshotValue["profile_image"] as? String
    mainImage = snapshotValue["main_image"] as? String
    friends = (snapshotValue["friends"] as? [String: Bool])?.map({ $0.key })
    portfolios = (snapshotValue["portfolios"] as? [String: Bool])?.map({ $0.key })
    passions = (snapshotValue["passions"] as? [String: Bool])?.map({ $0.key })
    ref = snapshot.ref
    
    fullName = (firstName?.uppercaseFirst ?? "") + " " + (lastName?.uppercaseFirst ?? "")
  }
}
