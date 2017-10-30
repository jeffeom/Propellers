//
//  SignUpViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-30.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
  @IBOutlet weak var firstNameField: UITextField!
  @IBOutlet weak var lastNameField: UITextField!
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  
  var imageData: Data?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

//MARK: IBAction
extension SignUpViewController {
  @IBAction func signUpButtonPressed(_ sender: UIButton) {
    let imageData = UIImageJPEGRepresentation(#imageLiteral(resourceName: "userPlaceHolder"), 0.8)
    guard let email = emailField.text, let password = passwordField.text, let firstName = firstNameField.text, let lastName = lastNameField.text, let data = imageData else { return }
    guard !email.isEmpty, !firstName.isEmpty, !lastName.isEmpty else { return }
    NetworkingService.shared.signUp(email, firstName: firstName, lastName: lastName, password: password, data: data) { (success) in
      if success {
        let mainScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
        self.present(mainScreen, animated: true, completion: nil)
      }else {
        print("Failure to create a user")
      }
    }
  }
}
