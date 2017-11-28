//
//  FriendsViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-27.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

enum UserStatusType {
  case client, freeLancer
}

class UserCell: UITableViewCell {
  static let identifier = "userCell"
  var statusType: UserStatusType  = .client
  
  @IBOutlet private weak var statusView: UIView!
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    switch statusType {
    case .client:
      statusView.backgroundColor = .yellow
    case .freeLancer:
      statusView.backgroundColor = .red
    }
    
    self.userImageView.layer.cornerRadius = userImageView.bounds.width / 2
    self.userImageView.clipsToBounds = true
    
    self.layer.cornerRadius = 8
    self.clipsToBounds = true
  }
}

class FriendsViewController: UIViewController {
  static let identifier = "friendsVC"
  @IBOutlet weak var friendsTableView: UITableView!
  @IBOutlet weak var searchBar: UISearchBar!
  var friendsArray: [UserModel]?
  var selectedUser: UserModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.backgroundImage = UIImage()
    setupDelegates()
    fetchMyFriends()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.barTintColor = ThemeColor.lightBlueColor
    navigationController?.navigationBar.tintColor = .white
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Montserrat-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18)]
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
}

//MARK: Setup
extension FriendsViewController {
  func setupDelegates() {
    friendsTableView.delegate = self
    friendsTableView.dataSource = self
  }
}

//MARK: NetworkingServices
extension FriendsViewController {
  func fetchMyFriends() {
    NetworkingService.shared.fetchFriends { (friends) in
      self.friendsArray = friends
      self.friendsTableView.reloadData()
    }
  }
}

//MARK: TableViewDelegates
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    guard let friendsArray = friendsArray else { return 0 }
    return friendsArray.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    let theUser = friendsArray![section]
    let userCell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
    userCell.userImageView.sd_setImage(with: URL(string: theUser.imageURL ?? "")!)
    userCell.userNameLabel.text = theUser.fullName ?? ""
    return userCell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = indexPath.section
    selectedUser = friendsArray?[section]
    performSegue(withIdentifier: "profileDetails", sender: nil)
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 6
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let clearView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 6 ))
    clearView.backgroundColor = .clear
    return clearView
  }
}

//MARK: Segue
extension FriendsViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "profileDetails" {
      let profileVC = segue.destination as! ProfileDetailViewController
      profileVC.user = selectedUser?.uid
    }
  }
}
