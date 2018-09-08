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
import FirebaseUI
import SDWebImage

struct NetworkingService {
  static public let shared = NetworkingService()
  var paymentToken: String? {
    return UserDefaults.standard.value(forKey: "paymentToken") as? String
  }
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
  
  func fetchMyFriends(completion: @escaping ([UserModel?]?) -> ()) {
    userRef.child(currentUID).child("friends").observeSingleEvent(of: .value) { (snapshot) in
      var listOfFriends = [UserModel?]()
      let listOfFriendsUID = snapshot.value as? [String: Bool]
      let group = DispatchGroup()
      listOfFriendsUID?.keys.forEach({
        group.enter()
        self.fetchUser(withUID: $0, completion: { (fetchedFriend) in
          listOfFriends.append(fetchedFriend)
          group.leave()
        })
      })
      
      group.notify(queue: .main, execute: {
        completion(listOfFriends)
      })
    }
  }
  
  func fetchUser(withUID userID: String, completion: @escaping(UserModel?) -> ()) {
    userRef.child(userID).observeSingleEvent(of: .value) { (snapshot) in
      let user = UserModel(snapshot: snapshot)
      completion(user)
    }
  }
}

//MARK: SignUp
extension NetworkingService {
  // Creating Users
  func signUp(_ email: String, firstName: String, lastName: String, password: String, data: Data!, completion: @escaping (_ result: Bool) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
      if error == nil {
        UserDefaults.standard.set(true, forKey: "firstTime")
        self.setUserInfo(user?.user, firstName: firstName, lastName: lastName, password: password, data: data) { (result) in
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
        imageRef.downloadURL(completion: { (url, error) in
          if error != nil {
            print(error!.localizedDescription)
            return
          }
          if url != nil {
            changeRequest.photoURL = url
          }
        })
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
    let userInfo = ["email": email, "first_name": firstName.uppercaseFirst, "last_name": lastName.uppercaseFirst, "uid": user.uid, "profile_image": url.absoluteString]
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

//MARK: Chat Service
extension NetworkingService {
  func fetchRooms(completion: @escaping ([Room]) -> ()) {
    chatRef.child("rooms").observeSingleEvent(of: .value) { (snapshot) in
      var fetchedRooms: [Room] = []
      let rooms = snapshot.children.allObjects as! [DataSnapshot]
      for aRoom in rooms {
        guard let theRoom = Room(snapshot: aRoom) else {
          completion([])
          return
        }
        if theRoom.uid1 == self.currentUID || theRoom.uid2 == self.currentUID {
          fetchedRooms.append(theRoom)
        }
      }
      completion(fetchedRooms)
    }
  }
  
  func createRoom(withUid uid: String, completion: @escaping (ChatInfo?) -> ()) {
    chatRef.child("rooms").observeSingleEvent(of: .value) { (snapshot) in
      let rooms = snapshot.children.allObjects as! [DataSnapshot]
      var fetchedChatInfo: ChatInfo?
      for aRoom in rooms {
        guard let theRoom = Room(snapshot: aRoom) else {
          completion(nil)
          return
        }
        if (theRoom.uid1 == self.currentUID && theRoom.uid2 == uid) || (theRoom.uid2 == self.currentUID && theRoom.uid1 == uid) {
          fetchedChatInfo = ChatInfo(roomKey: theRoom.key, room: theRoom)
        }
      }
      if fetchedChatInfo == nil {
        let newRoom = Room(uid1: self.currentUID, uid2: uid, latestText: "", date: Date().millisecondsSince1970 ?? 0)
        self.chatRef.child("rooms").childByAutoId().setValue(
          ["date": newRoom.date!,
           "uid1": newRoom.uid1!,
           "uid2": newRoom.uid2!,
           "latestText": newRoom.latestText!
          ], withCompletionBlock: { (error, ref) in
            completion(ChatInfo(roomKey: ref.key, room: newRoom))
        })
      }else {
        completion(fetchedChatInfo)
      }
    }
  }
  
  func sendMessage(roomID: String, senderID: String, withText messageText: String, onDate date: Int64){
    let theChatRef = chatRef.child("messages").child(roomID).childByAutoId()
    let message = Message(senderID: senderID, text: messageText, imageURL: nil, date: date)
    let roomRef = chatRef.child("rooms").child(roomID)
    roomRef.updateChildValues(
      [ "latestText": messageText,
        "date": date
    ]) { (_, _) in
      theChatRef.setValue(message.json())
    }
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
        uploadRef.downloadURL(completion: { (url, error) in
          if error != nil {
            print(error!.localizedDescription)
            completion(nil)
            return
          }
          if url != nil {
            completion(url)
          }
        })
      }else {
        completion(nil)
      }
    }
  }
}
