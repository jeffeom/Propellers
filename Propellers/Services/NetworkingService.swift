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

struct NetworkingService {
  static public let shared = NetworkingService()
  var databaseRef: DatabaseReference! {
    return Database.database().reference()
  }
  var storageRef: StorageReference {
    return Storage.storage().reference()
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
    let userRef = databaseRef.child("users").child(user.uid)
    // Save the user info in the Database
    userRef.setValue(userInfo)
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
