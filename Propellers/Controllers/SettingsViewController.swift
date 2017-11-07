//
//  SettingsViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-06.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import Firebase

class SettingsViewController: UIViewController {
  let appDel = UIApplication.shared.delegate as? AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func logoutButtonTapped(_ sender: UIButton) {
    try? Auth.auth().signOut()
    
    appDel?.window!.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainRootScreen")
  }
}
