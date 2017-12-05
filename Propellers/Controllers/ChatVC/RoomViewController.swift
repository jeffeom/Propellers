//
//  RoomViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-31.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController {
  @IBOutlet weak var roomTableView: UITableView!
  var fetchedRooms: [Room] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupDelegates()
    fetchRoom()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.barTintColor = ThemeColor.lightBlueColor
    navigationController?.navigationBar.tintColor = .white
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Montserrat-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18)]
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
}

//MARK: NetworkingService
extension RoomViewController {
  func fetchRoom() {
    NetworkingService.shared.fetchRooms { (rooms) in
      self.fetchedRooms = rooms
      self.roomTableView.reloadData()
    }
  }
}

extension RoomViewController: UITableViewDelegate, UITableViewDataSource {
  func setupDelegates() {
    roomTableView.delegate = self
    roomTableView.dataSource = self
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedRooms.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RoomTableViewCell().identifier, for: indexPath) as! RoomTableViewCell
    cell.roomNameLabel.text = fetchedRooms[indexPath.section].key!
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedCell = tableView.cellForRow(at: indexPath) as! RoomTableViewCell
    let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
    let selectedRoom = fetchedRooms[indexPath.section]
    let chatInfoToSend = ChatInfo(roomKey: selectedRoom.key, room: selectedRoom)
    chatVC.chatInfo = chatInfoToSend
    chatVC.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(chatVC, animated: true)
  }
}

class RoomTableViewCell: UITableViewCell {
  @IBOutlet weak var roomNameLabel: UILabel!
  let identifier = "roomTableViewCell"
}
