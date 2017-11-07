//
//  ChatContainerViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-06.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

class ChatContainerViewController: UIViewController {
  @IBOutlet weak var activitySheetView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    activitySheetView.isHidden = true
  }
}
