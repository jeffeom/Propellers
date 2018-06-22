//
//  NewsfeedViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-06-07.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import Hero

class NewsfeedViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  @IBAction func pressedCardView(_ sender: Any) {
    print("hi")
    let vc2 = UIStoryboard(name: "Newsfeed", bundle: nil).instantiateViewController(withIdentifier: "VC2")
    vc2.hero.isEnabled = true
  }
}
