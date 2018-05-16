//
//  RoomViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-31.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

struct RoomWithName {
  var name: String?
  var room: Room?
}

class RoomViewController: UIViewController {
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var roomTableView: UITableView!
  let appDel = UIApplication.shared.delegate as? AppDelegate

  var fetchedRooms: [RoomWithName] = []
  
  var darkIndicatorView: UIView?
  var activityIndicator: NVActivityIndicatorView?
  
  var comingFromNotification = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.backgroundImage = UIImage()
    darkIndicatorView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
    activityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width / 8, height: self.view.bounds.width / 8), type: .ballRotate, color: ThemeColor.lightBlueColor, padding: nil)
    setupActivityIndicator(darkIndicatorView: darkIndicatorView!, activityIndicator: activityIndicator!)
    setupDelegates()
    fetchRooms()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if comingFromNotification {
      fetchRooms()
      comingFromNotification = false
    }
    fetchedRooms.sort{$0.room?.date ?? 0 > $1.room?.date ?? 0}
    checkToDeleteBadge()
    roomTableView.reloadData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.barTintColor = ThemeColor.lightBlueColor
    navigationController?.navigationBar.tintColor = .white
    navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Montserrat-SemiBold", size: 18) ?? UIFont.systemFont(ofSize: 18)]
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
  }
}

//MARK: NotificationBadge
extension RoomViewController {
  func checkToDeleteBadge() {
    let totalUnreadCount = fetchedRooms.compactMap({ $0.room?.unreadMessagesCounter }).reduce(0, +)
    if totalUnreadCount == 0 {
      for subview in (tabBarController?.tabBar.subviews)! {
        if subview.tag == 1234 {
          subview.removeFromSuperview()
          break
        }
      }
    }else {
      appDel?.addRedDotAtTabBarItemIndex(index: 1, withTag: 1234)
    }
  }
}

//MARK: NetworkingService
extension RoomViewController {
  func fetchRooms() {
    fetchedRooms = []
    if let _ = darkIndicatorView, let _ = activityIndicator {
    }else {
      activityIndicator = NVActivityIndicatorView(frame: CGRect.zero, type: nil, color: nil, padding: nil)
      darkIndicatorView = UIView(frame: CGRect.zero)
    }
    startLoading(darkIndicatorView: darkIndicatorView!, activityIndicator: activityIndicator!)
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
              self.stopLoading(darkIndicatorView: self.darkIndicatorView!, activityIndicator: self.activityIndicator!)
            }
          })
        }else {
          NetworkingService.shared.fetchUser(withUID: aRoom.uid1!, completion: { (user) in
            let roomName = user?.fullName!
            self.fetchedRooms.append(RoomWithName(name: roomName, room: aRoom))
            if self.fetchedRooms.count == rooms.count {
              self.roomTableView.reloadData()
              self.stopLoading(darkIndicatorView: self.darkIndicatorView!, activityIndicator: self.activityIndicator!)
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
    guard fetchedRooms.count > 0 else { return cell }
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
