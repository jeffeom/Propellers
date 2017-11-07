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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupDelegates()
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
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: RoomTableViewCell().identifier, for: indexPath) as! RoomTableViewCell
    cell.roomNameLabel.text = "abcd"
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedCell = tableView.cellForRow(at: indexPath) as! RoomTableViewCell
    let toVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "chatVC") as! ChatViewController
    guard let dateInt = Date().millisecondsSince1970 else { return }
    toVC.roomKey = selectedCell.roomNameLabel.text
    // TEST
    let testRoom = Room(uid1: "KYe3f3iEcZaY6nPeU8FFOcZ2sSF2", uid2: "PK7GpUTq6Fd7zonzLoVAZIwBm793", latestText: "hi", date: dateInt)
    toVC.room = testRoom
    toVC.hidesBottomBarWhenPushed = true
    navigationController?.pushViewController(toVC, animated: true)
  }
}

class RoomTableViewCell: UITableViewCell {
  @IBOutlet weak var roomNameLabel: UILabel!
  let identifier = "roomTableViewCell"
}
