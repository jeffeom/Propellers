//
//  JSQChatViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-12-04.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

class JSQChatViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let messageVC = ChatViewController()
    let navBarHeight: CGFloat = 64
    messageVC.view.frame = CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - navBarHeight)
    self.view.addSubview(messageVC.view)
  }
}
