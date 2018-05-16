//
//  GeneralTabBarViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-02-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class GeneralTabBarViewController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    self.delegate = self
    automaticallyAdjustsScrollViewInsets = false
  }
}

//MARK: TabbarControllerDelegate
extension GeneralTabBarViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    if viewController.tabBarItem.tag == 1 {
      let theNav = viewController as! UINavigationController
      guard let roomVC = theNav.viewControllers.first as? RoomViewController else { return true }
      roomVC.fetchRooms()
    }
    return true
  }
}
