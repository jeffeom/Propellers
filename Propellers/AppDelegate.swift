//
//  AppDelegate.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-25.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    BuddyBuildSDK.setup()
    FirebaseApp.configure()
    return true
  }
}

