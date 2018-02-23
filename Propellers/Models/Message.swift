//
//  Message.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-30.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import Foundation
import Firebase

enum MessageType {
  case text, image, payment, timestamp, error
}

class Message: NSObject {
  var key: String?
  var senderID: String?
  var text: String?
  var imageURL: String?
  var date: Int64?
  var time: Int64?
  var ref: DatabaseReference?
  var msgType: MessageType = .text

  init?(snapshot: DataSnapshot) {
    guard let snapshotValue = snapshot.value as? [String:AnyObject] else { return nil }
    key = snapshot.key
    senderID = snapshotValue["senderID"] as? String
    text = snapshotValue["text"] as? String
    imageURL = snapshotValue["imageURL"] as? String
    date = snapshotValue["date"] as? Int64
    ref = snapshot.ref
    if let imageURLInString = snapshotValue["imageURL"] as? String {
      if !imageURLInString.isEmpty {
        imageURL = imageURLInString
        msgType = .image        
      }
    }
  }
  
  init(senderID: String, text: String?, imageURL: String?, date: Int64) {
    self.senderID = senderID
    self.text = text
    if let imageURLInString = imageURL {
      self.imageURL = imageURLInString
      msgType = .image
    }
    self.date = date
  }
  
  init?(_ dateToShow: Date) {
    msgType = .timestamp
    time = dateToShow.millisecondsSince1970
  }
  
  func json() -> [String:Any]? {
    guard let senderID = senderID, let date = date else { return nil }
    return ["senderID": senderID, "text": text ?? "", "imageURL": imageURL ?? "", "date": date] as [String : AnyObject]
  }
}
