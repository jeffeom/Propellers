//
//  ProfileDetailViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-27.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

class ProfileDetailViewController: UIViewController {
  var user: UserModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if #available(iOS 11.0, *) {
      navigationController?.navigationBar.prefersLargeTitles = true
      navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 40, weight: .bold)]
    }
    title = user?.fullName
  }
}

//MARK: IBAction
extension ProfileDetailViewController {
  @IBAction func didPressButtonToChat(_ sender: UIButton) {
    guard let user = user?.uid else { return }
    NetworkingService.shared.createRoom(withUid: user) { (chatInfo) in
      let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "newChatVC") as! NewChatViewController
      chatVC.room = chatInfo?.room
      self.navigationController?.pushViewController(chatVC, animated: true)
    }
  }
}
