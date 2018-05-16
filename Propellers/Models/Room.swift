//
//  Room.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-06.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Room: NSObject {
  var key: String?
  var uid1: String?
  var uid2: String?
  var latestText: String?
  var date: Int64?
  var ref: DatabaseReference?
  
  var unreadMessagesCounter = 0
  
  init?(snapshot: DataSnapshot) {
    guard let snapshotValue = snapshot.value as? [String:AnyObject] else { return nil }
    key = snapshot.key
    uid1 = snapshotValue["uid1"] as? String
    uid2 = snapshotValue["uid2"] as? String
    latestText = snapshotValue["latestText"] as? String
    date = snapshotValue["date"] as? Int64
    ref = snapshot.ref
  }
  
  init(uid1: String, uid2: String, latestText: String?, date: Int64) {
    self.uid1 = uid1
    self.uid2 = uid2
    self.latestText = latestText
    self.date = date
  }
  
  func json() -> [String:Any]? {
    guard let uid1 = uid1, let uid2 = uid2, let date = date else { return nil }
    return ["uid1": uid1, "uid2": uid2, "latestText": latestText ?? "", "date": date] as [String : AnyObject]
  }
}
