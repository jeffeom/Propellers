//
//  ViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-25.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

//MARK: IBAction
extension LoginViewController {
  @IBAction func loginButtonPressed(_ sender: UIButton) {
    guard let email = emailField.text, let password = passwordField.text else { return }
    guard !email.isEmpty, !password.isEmpty else { return }
    NetworkingService.shared.signIn(email, password: password) { (success) in
      if success {
        let mainScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
        self.present(mainScreen, animated: true, completion: nil)
      }else {
        print("Fail")
        return
      }
    }
  }
  @IBAction func signUpButtonPressed(_ sender: UIButton) {
  }
}
