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
  var testA = ["email": "a@a.com", "password": "000000"]
  var testB = ["email": "b@b.com", "password": "000000"]
  
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
  
  
  @IBAction func testALogin(_ sender: UIButton) {
    NetworkingService.shared.signIn(testA["email"]!, password: testA["password"]!) { (success) in
      if success {
        let mainScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
        self.present(mainScreen, animated: true, completion: nil)
      }else {
        print("Fail")
        return
      }
    }
  }
  
  @IBAction func testBLogin(_ sender: UIButton) {
    NetworkingService.shared.signIn(testB["email"]!, password: testB["password"]!) { (success) in
      if success {
        let mainScreen = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
        self.present(mainScreen, animated: true, completion: nil)
      }else {
        print("Fail")
        return
      }
    }
  }
}
