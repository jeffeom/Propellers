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

class FriendsViewController: UIViewController {
  @IBOutlet weak var friendsTableView: UITableView!
  
  static let identifier = "friendsVC"
  var friendsArray = [UserModel]()
  var filteredFriendsArray = [UserModel]()
  var selectedUser: UserModel?
  let searchController = UISearchController(searchResultsController: nil)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    if #available(iOS 11.0, *) {
      navigationController?.navigationBar.prefersLargeTitles = true
      navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 40, weight: .bold)]
    }
    setupDelegates()
    fetchMyFriends()
    searchController.searchResultsUpdater = self
    if #available(iOS 11.0, *) {
      navigationItem.searchController = searchController
    } else {
      navigationItem.titleView = searchController.searchBar
    }
    searchController.dimsBackgroundDuringPresentation = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    searchController.hidesNavigationBarDuringPresentation = true
    navigationController?.navigationBar.barTintColor = .white
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    searchController.hidesNavigationBarDuringPresentation = false
  }
}

//MARK: SearchResultsUpdater
extension FriendsViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let theText = searchController.searchBar.text
    filteredFriendsArray = friendsArray.filter({ $0.fullName?.lowercased().range(of: theText!.lowercased()) != nil })
    friendsTableView.reloadData()
  }
  
  func isFiltering() -> Bool {
    return searchController.isActive && !searchBarIsEmpty()
  }
  
  func searchBarIsEmpty() -> Bool {
    return searchController.searchBar.text?.isEmpty ?? true
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
    NetworkingService.shared.fetchMyFriends { (friends) in
      self.friendsArray = friends as? [UserModel] ?? []
      self.friendsTableView.reloadData()
    }
  }
}

//MARK: TableViewDelegates
extension FriendsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    if isFiltering() {
      return filteredFriendsArray.count
    }else {
      return friendsArray.count      
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = indexPath.section
    let theUser = friendsArray[section]
    let userCell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
    userCell.userImageView.sd_setImage(with: URL(string: theUser.profileImage ?? "")!)
    userCell.userNameLabel.text = theUser.fullName ?? ""
    return userCell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = indexPath.section
    if isFiltering() {
      selectedUser = filteredFriendsArray[section]
    }else {
      selectedUser = friendsArray[section]
    }
    
    let toVC = UIStoryboard(name: "Friends", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as! ProfileDetailViewController
    toVC.user = selectedUser
    presentingViewController?.navigationController?.pushViewController(toVC, animated: true)
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
