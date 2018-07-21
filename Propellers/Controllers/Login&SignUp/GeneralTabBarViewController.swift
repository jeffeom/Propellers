//
//  GeneralTabBarViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-02-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class CustomPresentationController : UIPresentationController {
  override var frameOfPresentedViewInContainerView: CGRect {
    return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height)
  }
}

class GeneralTabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
    tabBar.layer.shadowRadius = 4
    tabBar.layer.shadowColor = UIColor.black.cgColor
    tabBar.layer.shadowOpacity = 0.25
    navigationController?.viewControllers = [self]
    delegate = self
    automaticallyAdjustsScrollViewInsets = false
  }
}

//MARK: TransitioningDelegate
extension GeneralTabBarController: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return CustomPresentationController(presentedViewController: presented, presenting: presenting)
  }
}

//MARK: TabBarControllerDelegate
extension GeneralTabBarController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    if viewController.tabBarItem.tag == 2{
        showPostVC()
        return false
    }else {
      return true
    }
  }
  
  @objc func showPostVC() {
    guard let toVC = UIStoryboard(name: "Post", bundle: nil).instantiateViewController(withIdentifier: "PostViewController") as? PostViewController else { return }
    toVC.modalPresentationStyle = .custom
    toVC.transitioningDelegate = self
    let navController = UINavigationController(rootViewController: toVC)
    navController.view.backgroundColor = .white
    self.present(navController, animated: true, completion: nil)
  }
}
