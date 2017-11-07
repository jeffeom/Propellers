//
//  NetworkingService.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-30.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorageUI
import SDWebImage

struct NetworkingService {
  static public let shared = NetworkingService()
  var databaseRef: DatabaseReference! {
    return Database.database().reference()
  }
  var storageRef: StorageReference {
    return Storage.storage().reference()
  }
  
  var chatRef: DatabaseReference {
    return Database.database().reference().child("chat")
  }
  
  var userRef: DatabaseReference {
    return Database.database().reference().child("users")
  }
  
  var currentUID: String {
    return (Auth.auth().currentUser?.uid)!
  }
}

//MARK: UserInfo
extension NetworkingService {
  func downloadUserAvatarPhoto(withUid userId: String, to imageView: UIImageView){
    let imageRef = NetworkingService().storageRef.child(userId).child("profileImage\(userId)")
    imageView.sd_setImage(with: imageRef, placeholderImage: #imageLiteral(resourceName: "userPlaceHolder"))
  }
}

//MARK: SignUp
extension NetworkingService {
  // Creating Users
  func signUp(_ email: String, firstName: String, lastName: String, password: String, data: Data!, completion: @escaping (_ result: Bool) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
      if error == nil {
        UserDefaults.standard.set(true, forKey: "firstTime")
        self.setUserInfo(user, firstName: firstName, lastName: lastName, password: password, data: data) { (result) in
          completion(result)
        }
      } else {
        print(error!.localizedDescription)
        completion(false)
      }
    })
  }
  
  // Set User Info
  fileprivate func setUserInfo(_ user: User!, firstName: String, lastName: String, password: String, data: Data!, completion: @escaping (_ result: Bool) -> Void) {
    //Create Path for the User Image
    let imagePath = "profileImage\(user.uid)"
    // Create image Reference
    let imageRef = storageRef.child(user.uid).child(imagePath)
    // Create Metadata for the image
    let metaData = StorageMetadata()
    metaData.contentType = "image/jpeg"
    // Save the user Image in the Firebase Storage File
    imageRef.putData(data, metadata: metaData) { (metaData, error) in
      if error == nil {
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = "\(firstName) \(lastName)"
        changeRequest.photoURL = metaData!.downloadURL()
        changeRequest.commitChanges(completion: { (error) in
          if error == nil {
            self.saveInfo(user, firstName: firstName, lastName: lastName, password: password) { (result) in
              completion(result)
            }
          } else {
            print(error!.localizedDescription)
          }
        })
      } else {
        print(error!.localizedDescription)
      }
    }
  }
  
  fileprivate func saveInfo(_ user: User!, firstName: String, lastName: String, password: String, completion: @escaping (_ result: Bool) -> Void) {
    guard let email = user.email, let url = user.photoURL else {
      completion(false)
      return
    }
    let userInfo = ["email": email, "first_name": firstName.uppercaseFirst, "last_name": lastName.uppercaseFirst, "uid": user.uid, "photo_url": url.absoluteString]
    // create user reference
    let theUserRef = userRef.child(user.uid)
    // Save the user info in the Database
    theUserRef.setValue(userInfo)
    completion(true)
  }
}

//MARK: SignIn
extension NetworkingService {
  // Signing in the User
  func signIn(_ email: String, password: String, completion: @escaping (_ result: Bool) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
      if error == nil {
        if let _ = user {
          completion(true)
        }else {
          completion(false)
        }
      } else {
        print(error!.localizedDescription)
        completion(false)
      }
    })
  }
}


//MARK: Chat
extension NetworkingService {
  func sendMessage(roomID: String, senderID: String, withText messageText: String, onDate date: Int64){
    let theRoomRef = chatRef.child("messages").child(roomID).childByAutoId()
    let message = Message(senderID: senderID, text: messageText, imageURL: nil, date: date)
    theRoomRef.setValue(message.json())
  }
  
  func fetchMessagesBySingleEvent(roomID: String, completion: @escaping ([Message]?) -> ()) {
    var messageArray: [Message] = []
    let theRoomRef = chatRef.child("messages").child(roomID)
    theRoomRef.observeSingleEvent(of: .value) { (snapshot) in
      guard let chats = snapshot.children.allObjects as? [DataSnapshot] else {
        completion(nil)
        return
      }
      for aChat in chats {
        let theMessage = Message(snapshot: aChat)
        messageArray.append(theMessage!)
        if messageArray.count == snapshot.children.allObjects.count {
          completion(messageArray)
        }
      }
    }
  }
  
  func fetchMessagesByChildAdded(roomID: String, completion: @escaping (Message) -> ()) {
    var message: Message?
    let theRoomRef = chatRef.child("messages").child(roomID)
    theRoomRef.observe(.childAdded) { (snapshot) in
      message = Message(snapshot: snapshot)
      completion(message!)
    }
  }
  
  func uploadChatImage(imageData: Data, completion: @escaping (URL?) -> ()){
    let uploadRef = self.storageRef.child(self.currentUID).child("chatImage").child("\(Date().millisecondsSince1970 ?? 0)")
    let metaData = StorageMetadata()
    metaData.contentType = "image/jpeg"
    uploadRef.putData(imageData, metadata: metaData) { (metaData, error) in
      if error == nil{
        completion(metaData?.downloadURL())
      }else {
        completion(nil)
      }
    }
  }
}