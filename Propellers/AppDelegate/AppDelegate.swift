//
//  AppDelegate.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-25.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import BuddyBuildSDK
import Stripe

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  lazy var mainViewController = {
    return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainScreen") as! GeneralTabBarController
  }()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    BuddyBuildSDK.setup()
    FirebaseApp.configure()
//    IQKeyboardManager.shared.enable = true
    STPPaymentConfiguration.shared().publishableKey = Constants.publishableKey
    UIApplication.shared.statusBarStyle = .lightContent
    return true
  }
  
  func addRedDotAtTabBarItemIndex(index: Int, withTag tag: Int) {
    for subview in mainViewController.tabBar.subviews {
      if subview.tag == tag {
        subview.removeFromSuperview()
        break
      }
    }
    let RedDotRadius: CGFloat = 5
    let RedDotDiameter = RedDotRadius * 2
    let TopMargin:CGFloat = 5
    let TabBarItemCount = CGFloat(self.mainViewController.tabBar.items!.count)
    let HalfItemWidth = self.mainViewController.view.bounds.width / (TabBarItemCount * 2)
    let xOffset = HalfItemWidth * CGFloat(index * 2 + 1)
    guard let selectedTabImage = (self.mainViewController.tabBar.items![index]).selectedImage else { return }
    let imageHalfWidth: CGFloat = selectedTabImage.size.width / 2
    let redDot = UIView(frame: CGRect(x: xOffset + imageHalfWidth, y: TopMargin, width: RedDotDiameter, height: RedDotDiameter))
    
    redDot.tag = tag
    redDot.backgroundColor = .red
    redDot.layer.cornerRadius = RedDotRadius
    
    self.mainViewController.tabBar.addSubview(redDot)
  }
}
