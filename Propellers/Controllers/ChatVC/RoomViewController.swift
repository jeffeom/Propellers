//
//  RoomViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-31.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

struct RoomWithName {
  var name: String?
  var room: Room?
}

class RoomViewController: UIViewController {
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var roomTableView: UITableView!
  var fetchedRooms: [RoomWithName] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    automaticallyAdjustsScrollViewInsets = false
    searchBar.backgroundImage = UIImage()
    setupDelegates()
//    fetchRoom()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
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
    fetchedRooms = []
    NetworkingService.shared.fetchRooms { (rooms) in
      let currentUID = NetworkingService.shared.currentUID
      for aRoom in rooms {
        if aRoom.uid1 == currentUID {
          NetworkingService.shared.fetchUser(withUID: aRoom.uid2!, completion: { (user) in
            let roomName = user?.fullName!
            self.fetchedRooms.append(RoomWithName(name: roomName, room: aRoom))
            if self.fetchedRooms.count == rooms.count {
              self.fetchedRooms.sort(by: { (firstRoom, secondRoom) -> Bool in
                let firstDate = firstRoom.room?.date
                let secondDate = secondRoom.room?.date
                return firstDate! > secondDate!
              })
              self.roomTableView.reloadData()
            }
          })
        }else {
          NetworkingService.shared.fetchUser(withUID: aRoom.uid1!, completion: { (user) in
            let roomName = user?.fullName!
            self.fetchedRooms.append(RoomWithName(name: roomName, room: aRoom))
            if self.fetchedRooms.count == rooms.count {
              self.roomTableView.reloadData()
            }
          })
        }
      }
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
    let currentUID = NetworkingService.shared.currentUID
    let aRoom = fetchedRooms[indexPath.section].room!
    if aRoom.uid1 == currentUID {
      NetworkingService.shared.fetchUser(withUID: aRoom.uid2!, completion: { (user) in
        cell.userImageView.sd_setImage(with: URL(string: (user?.imageURL!)!), completed: nil)
        cell.roomNameLabel.text = user?.fullName
        cell.roomLatestTextLabel.text = aRoom.latestText
        cell.dateLabel.text = Date(milliseconds: aRoom.date)?.toString(dateFormat: "h:mm a")
        cell.isNew = true
      })
    }else {
      NetworkingService.shared.fetchUser(withUID: aRoom.uid2!, completion: { (user) in
        cell.userImageView.sd_setImage(with: URL(string: (user?.imageURL!)!), completed: nil)
        cell.roomNameLabel.text = user?.fullName
        cell.roomLatestTextLabel.text = aRoom.latestText
        cell.dateLabel.text = Date(milliseconds: aRoom.date)?.toString(dateFormat: "h:mm a")
        cell.isNew = false
      })
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue(withIdentifier: "showChat", sender: nil)
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
extension RoomViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard segue.identifier == "showChat" else { return }
    guard let controller = segue.destination as? NewChatViewController, let indexPath = self.roomTableView.indexPathForSelectedRow, fetchedRooms.count != 0 else { return }
    let selectedRoom = fetchedRooms[indexPath.section]
    controller.room = selectedRoom.room
    controller.title = selectedRoom.name
    self.tabBarController?.tabBar.isHidden = true
  }
}