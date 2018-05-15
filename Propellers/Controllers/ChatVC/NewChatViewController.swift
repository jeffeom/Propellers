//
//  NewChatViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-02-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import Firebase
import NYTPhotoViewer
import Popover
import KRPullLoader

struct ChatInfo {
  var roomKey: String?
  var room: Room?
}

class NewChatViewController: UIViewController {
  var room: Room?
  var messages: [Message] = []
  
  @IBOutlet weak var mainScrollView: UIScrollView!
  @IBOutlet weak var chatCollectionView: UICollectionView!
  @IBOutlet weak var inputShadowView: UIView!
  @IBOutlet weak var inputToolView: UIView!
  @IBOutlet weak var textViewBorder: UIView!
  @IBOutlet weak var inputTextView: UITextView!
  @IBOutlet weak var attachmentView: UIView!
  @IBOutlet weak var consTextViewHeight: NSLayoutConstraint!
  @IBOutlet weak var totalHeight: NSLayoutConstraint!
  @IBOutlet weak var keyboardSpacingConstraint: NSLayoutConstraint!
  @IBOutlet weak var moreButton: UIButton!
  @IBOutlet weak var attachmentCollectionView: UICollectionView!
  
  //AttachmentView
  var accessoryItemRow1 = ["Photos", "Videos", "Contact", "Payment"]
  var accessoryImageRow1 = [#imageLiteral(resourceName: "chatPictures"), #imageLiteral(resourceName: "chatVideo"), #imageLiteral(resourceName: "chatContacts"), #imageLiteral(resourceName: "chatPayment")]
  var accessoryItemRow2 = ["Contract", "Invoice"]
  var accessoryImageRow2 = [#imageLiteral(resourceName: "chatContract"), #imageLiteral(resourceName: "chatInvoice")]
  
  //Dismiss
  var lastMessageToSend: String?
  var lastTimeStampToSend: Int64?
  var sectionNumber: Int?
  
  //KeyboardHeight
  let notificationCenter = NotificationCenter.default
  var keyboardHeight: CGFloat?
  var stopMovingKeyboard = false
  
  //Attachment
  fileprivate var imageToSend: UIImage?
  fileprivate var imageData: Data = Data()
  fileprivate let picker = UIImagePickerController()
  var selectedImage: UIImage?
  
  //View
  let placeholderText = "Type Something..."
  let placeholderFontColor =  UIColor.lightGray
  
  //cellEditOptions
  var cellEditTableView: UITableView?
  var cellEditPopover: Popover?
  var cellEditOptionsList = ["Copy", "Delete"]
  var theSelectedChat: Message?
  var theSelectedCell: UICollectionViewCell?
  
  //LazyLoad
  var previousChat: Message?
  var lastItemKey: String?
  var lastMessageFlag = false
  var isAllMessage = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let room = self.room else {
      navigationController?.popViewController(animated: true)
      return
    }
//    if room.uid1 == room.uid2 {
//      let alertView = UIAlertController(title: "Sorry", message: "You cannot message yourself.", preferredStyle: .alert)
//      let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
//        NetworkingService.shared.chatRef.child("rooms").child(room.key ?? "").removeValue()
//        self.navigationController?.popViewController(animated: true)
//      })
//      alertView.addAction(okAction)
//      present(alertView, animated: true, completion: nil)
//      return
//    }
    setupBadgeCounts()
    setupLongPressGesture()
    setupNotification()
    eraseAndResetBadgeCounter()
    picker.delegate = self
    chatCollectionView.dataSource = self
    chatCollectionView.delegate = self
    attachmentCollectionView.dataSource = self
    attachmentCollectionView.delegate = self
    inputTextView.delegate = self
    appearance()
    fetchLatestDialogues(room: room)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    mainScrollView.isScrollEnabled = false
    self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Futura-Medium", size: 20)!, NSAttributedStringKey.foregroundColor: UIColor.white]
    self.tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    notificationCenter.removeObserver(Notification.Name.UIKeyboardWillHide)
    notificationCenter.removeObserver(Notification.Name.UIKeyboardWillShow)
    self.tabBarController?.tabBar.isHidden = false
  }
}

//MARK: IBActions
extension NewChatViewController {
  @IBAction func showAttachmentView(_ sender: UIButton) {
    if attachmentView.isHidden {
      attachmentViewShouldHide(hide: false)
    }else {
      attachmentViewShouldHide(hide: true)
    }
  }
  
  @IBAction func sendButtonPressed(_ sender: UIButton) {
    guard !inputTextView.text.isEmpty, inputTextView.text != "Type Something..." else { return }
    NetworkingService.shared.sendMessage(roomID: (room?.key!)!, senderID: NetworkingService.shared.currentUID, withText: inputTextView.text, onDate: Date().millisecondsSince1970!)
    inputTextView.text = nil
  }
  
  func attachmentViewShouldHide(hide: Bool) {
    if hide {
      attachmentView.isHidden = true
      inputTextView.becomeFirstResponder()
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
        self.moreButton.transform = CGAffineTransform.identity
      })
    }else {
      attachmentView.isHidden = false
      inputTextView.resignFirstResponder()
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
        self.moreButton.transform = CGAffineTransform(rotationAngle: (CGFloat(Double.pi)) / 4)
      })
    }
  }
}

//MARK: BadgeCounts
extension NewChatViewController {
  fileprivate func setupBadgeCounts() {
    guard let room = room, let key = room.key, let dateInt = Date().millisecondsSince1970 else { return }
    let roomRef = NetworkingService.shared.chatRef.child("rooms").child(key)
    if userIsUid1(room: room){
      roomRef.updateChildValues(["lastMessageReadUID1": dateInt])
    }else {
      roomRef.updateChildValues(["lastMessageReadUID2": dateInt])
    }
    UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - room.unreadMessagesCounter
  }
  
  fileprivate func eraseAndResetBadgeCounter() {
    NotificationCenter.default.removeObserver(self, name: Notification.Name("newMessageReceived"), object: nil)
  }
}

//MARK: Setup
extension NewChatViewController {
  func appearance() {
//    if UIDevice().userInterfaceIdiom == .phone {
//      switch UIScreen.main.nativeBounds.height {
//      case 2436:
//        if #available(iOS 11.0, *) {
//          let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
//          totalHeight.constant = self.view.frame.height - bottomPadding!
//        }else {
//          totalHeight.constant = self.view.frame.height - 64
//        }
//      default:
//        if #available(iOS 11.0, *) {
//          totalHeight.constant = self.view.frame.height - 64
//        }else {
//          totalHeight.constant = self.view.frame.height - 64
//        }
//      }
//    }
    if UIDevice().userInterfaceIdiom == .phone {
      switch UIScreen.main.nativeBounds.height {
      case 2436:
        if #available(iOS 11.0, *) {
          let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
          totalHeight.constant = self.view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 44) - UIApplication.shared.statusBarFrame.height - (bottomPadding ?? 34)
        }else {
          totalHeight.constant = self.view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 44) - UIApplication.shared.statusBarFrame.height - 34
        }
      default:
        if #available(iOS 11.0, *) {
          totalHeight.constant = self.view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 44) - UIApplication.shared.statusBarFrame.height
        }else {
          totalHeight.constant = self.view.frame.height - (self.navigationController?.navigationBar.frame.height ?? 44) - UIApplication.shared.statusBarFrame.height
        }
      }
    }
    inputTextView.inputAccessoryView = UIView()
    inputTextView.layer.cornerRadius = 15
    inputTextView.clipsToBounds = true
    createRoundShadowView(withShadowView: inputShadowView, andContentView: inputToolView, withCornerRadius: 0)
    getReadyToType()
//    let refreshView = KRPullLoadView()
//    refreshView.delegate = self
//    chatCollectionView.addPullLoadableView(refreshView, type: .refresh)
    
  }
  
  func setupLongPressGesture() {
    let lpgr : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    lpgr.minimumPressDuration = 0.5
    lpgr.delegate = self
    lpgr.delaysTouchesBegan = true
    self.chatCollectionView.addGestureRecognizer(lpgr)
}

  func setupNotification() {
    notificationCenter.addObserver(self, selector: #selector(adjustKeyboardHiding(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    notificationCenter.addObserver(self, selector: #selector(adjustKeyboardShowing(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
  }
  
  @objc func adjustKeyboardHiding(notification: Notification) {
    if let _ = keyboardHeight {
      mainScrollView.isScrollEnabled = false
      keyboardSpacingConstraint.constant = 0
      UIView.animate(withDuration: 0.3, animations: {
        self.view.layoutIfNeeded()
        self.keyboardHeight = nil
        self.stopMovingKeyboard = false
      })
    }
  }
  
  @objc func adjustKeyboardShowing(notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      guard !stopMovingKeyboard else { return }
      let keyboardRectangle = keyboardFrame.cgRectValue
      keyboardHeight = keyboardRectangle.height
      mainScrollView.isScrollEnabled = true
      attachmentViewShouldHide(hide: true)
      if UIDevice().userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 2436:
          if #available(iOS 11.0, *) {
//            let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
            keyboardSpacingConstraint.constant = keyboardHeight!
          }else {
            keyboardSpacingConstraint.constant = keyboardHeight!
          }
        default:
          keyboardSpacingConstraint.constant = keyboardHeight!
        }
      }
      UIView.animate(withDuration: 0.3, animations: {
        self.view.layoutIfNeeded()
        self.stopMovingKeyboard = true
      })
    }
  }
}

//MARK: GestureRecognizer
extension NewChatViewController: UIGestureRecognizerDelegate {
  @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
    if (gestureRecognizer.state != .began){
      return
    }
    let position = gestureRecognizer.location(in: self.chatCollectionView)
    let xPostition = Swift.max(self.view.frame.width * 0.1, Swift.min(position.x, self.view.frame.width * 0.9))
    let actualPosition = CGPoint(x: xPostition, y: position.y - self.chatCollectionView.contentOffset.y + (navigationController?.navigationBar.bounds.height)! + 30)
    if let indexPath: IndexPath = (self.chatCollectionView.indexPathForItem(at: position)){
      let theChat = messages[indexPath.section]
      self.theSelectedChat = theChat
      switch theChat.msgType {
      case .text:
        if theChat.senderID == NetworkingService.shared.currentUID {
          let theCell = self.chatCollectionView.cellForItem(at: indexPath) as! OutgoingCell
          self.theSelectedCell = theCell
          theCell.bubbleImageView.image = #imageLiteral(resourceName: "chatBubbleBluePressed").resizableImage(withCapInsets: UIEdgeInsetsMake(25, 20, 25, 20), resizingMode: .stretch).withRenderingMode(.alwaysOriginal)
          //copy, delete
          showEditPopup(withAllOptions: true, withLocation: actualPosition, forCell: theCell)
        }else {
          let theCell = self.chatCollectionView.cellForItem(at: indexPath) as! IncomingCell
          self.theSelectedCell = theCell
          theCell.bubbleImageView.image = #imageLiteral(resourceName: "chatBubbleGreyPressed").resizableImage(withCapInsets: UIEdgeInsetsMake(25, 20, 25, 20), resizingMode: .stretch).withRenderingMode(.alwaysOriginal)
          //copy, delete
          showEditPopup(withAllOptions: true, withLocation: actualPosition, forCell: theCell)
        }
      case .image:
        let theCell = self.chatCollectionView.cellForItem(at: indexPath)
        self.theSelectedCell = theCell
        //copy only
        showEditPopup(withAllOptions: false, withLocation: actualPosition, forCell: theCell!)
      default:
        break
      }
    }
  }
  
  private func showEditPopup(withAllOptions needAllOptions: Bool, withLocation startPoint: CGPoint, forCell cell: UICollectionViewCell) {
    giveHeavyHapticFeedback()
    if needAllOptions {
      cellEditTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
      cellEditOptionsList = ["Copy", "Delete"]
    }else {
      cellEditTableView = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
      cellEditOptionsList = ["Delete"]
    }
    cellEditTableView?.delegate = self
    cellEditTableView?.dataSource = self
    cellEditTableView?.isScrollEnabled = false
    if startPoint.y < self.view.frame.height / 2 {
      cellEditPopover = Popover(options: [.type(.down), .cornerRadius(10)], showHandler: nil, dismissHandler: {
        if cell is OutgoingCell {
          (cell as! OutgoingCell).bubbleImageView.image = #imageLiteral(resourceName: "chatBubbleBlue").resizableImage(withCapInsets: UIEdgeInsetsMake(25, 20, 25, 20), resizingMode: .stretch).withRenderingMode(.alwaysOriginal)
        }else if cell is IncomingCell {
          (cell as! IncomingCell).bubbleImageView.image = #imageLiteral(resourceName: "chatBubbleWhite").resizableImage(withCapInsets: UIEdgeInsetsMake(25, 20, 25, 20), resizingMode: .stretch).withRenderingMode(.alwaysOriginal)
        }
      })
      cellEditPopover?.show(cellEditTableView!, point: startPoint)
    }else {
      cellEditPopover = Popover(options: [.type(.up), .cornerRadius(10)], showHandler: nil, dismissHandler: {
        if cell is OutgoingCell {
          (cell as! OutgoingCell).bubbleImageView.image = #imageLiteral(resourceName: "chatBubbleBlue").resizableImage(withCapInsets: UIEdgeInsetsMake(25, 20, 25, 20), resizingMode: .stretch).withRenderingMode(.alwaysOriginal)
        }else if cell is IncomingCell {
          (cell as! IncomingCell).bubbleImageView.image = #imageLiteral(resourceName: "chatBubbleWhite").resizableImage(withCapInsets: UIEdgeInsetsMake(25, 20, 25, 20), resizingMode: .stretch).withRenderingMode(.alwaysOriginal)
        }
      })
      cellEditPopover?.show(cellEditTableView!, point: CGPoint(x: startPoint.x, y: startPoint.y - 30) )
    }
  }
}

//MARK: TextViewDelegate
extension NewChatViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    guard self.messages.count != 0 else { return }
    self.chatCollectionView.scrollToItem(at: IndexPath(item: 0, section: self.messages.count - 1), at: UICollectionViewScrollPosition.bottom, animated: true)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    self.consTextViewHeight.constant = Swift.min(50, textView.contentSize.height)
    guard self.messages.count != 0 else { return }
    self.chatCollectionView.scrollToItem(at: IndexPath(item: 0, section: self.messages.count - 1), at: UICollectionViewScrollPosition.bottom, animated: false)
  }
  
  func getReadyToType() {
    inputTextView?.text = placeholderText
    inputTextView?.textColor = placeholderFontColor
    inputTextView?.selectedTextRange = inputTextView?.textRange(from: (inputTextView?.beginningOfDocument)!, to: (inputTextView?.beginningOfDocument)!)
    self.view.layoutIfNeeded()
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let currentText = textView.text as NSString?
    let updatedText = currentText?.replacingCharacters(in: range, with: text)
    guard let textEmpty = updatedText else { return false }
    if textEmpty.isEmpty {
      textView.text = placeholderText
      textView.textColor = placeholderFontColor
      textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
      return false
    }else if textView.textColor == placeholderFontColor && !text.isEmpty {
      textView.text = nil
      textView.textColor = UIColor.black
    }
    return true
  }
  
  func textViewDidChangeSelection(_ textView: UITextView) {
    if self.view.window != nil {
      if textView.textColor == placeholderFontColor && textView.text == placeholderText {
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
      }else {
        textView.textColor = UIColor.black
      }
    }
  }
}

//MARK: NetworkingServices
extension NewChatViewController {
  func fetchLatestDialogues(room: Room) {
    guard Reachability.isConnectedToNetwork() else {
      navigationController?.popViewController(animated: true)
      return
    }
    guard let key = room.key else {
      navigationController?.popViewController(animated: true)
      return
    }
//    startLoading()
    self.chatCollectionView.reloadData()
    //nothing found fetch new messages.
    NetworkingService.shared.chatRef.child("messages").child(key).observeSingleEvent(of: .value) { (snapshot) in
      if !snapshot.hasChildren() {
        self.fetchNewDialogues(room: room)
//        self.stopLoading()
      }
    }
    //found messages fetch 21 at a time.
//    NetworkingService.shared.chatRef.child("messages").child(key).queryLimited(toLast: 21).observeSingleEvent(of: .value) { (snapshot) in
    NetworkingService.shared.chatRef.child("messages").child(key).observeSingleEvent(of: .value) { (snapshot) in
      let snapshotArray = snapshot.children.allObjects as! [DataSnapshot]
      for aSnap in snapshotArray {
        if aSnap == snapshotArray.first {
          //for first message; top of the VC
          self.lastItemKey = aSnap.key
          if snapshotArray.count == 1 {
            // if there are only one message,
            self.fetchNewDialogues(room: room)
          }else {
            // else show date + message
            guard let chat = Message(snapshot: aSnap) else { return }
            self.messages.append(Message(Date(milliseconds: chat.date) ?? Date())!)
            self.messages.append(chat)
          }
        }else {
          if aSnap == snapshotArray.last {
            // last message; Need to reload before scrolling.
            self.chatCollectionView.reloadData()
            self.chatCollectionView.scrollToItem(at: IndexPath(item: 0, section: self.messages.count - 1), at: UICollectionViewScrollPosition.bottom, animated: false)
            self.fetchNewDialogues(room: room)
          }else {
            // rest of the messages
            guard let chat = Message(snapshot: aSnap) else { return }
            if self.messages.count == 1 {
              self.messages.append(Message(Date(milliseconds: chat.date) ?? Date())!)
            }
            if let previousChat = self.previousChat {
              self.applyTimeStamp(withChat: chat, andPreviousChat: previousChat)
            }
            self.messages.append(chat)
            self.previousChat = chat
          }
        }
      }
    }
  }
  
  func fetchNewDialogues(room: Room) {
    guard Reachability.isConnectedToNetwork() else {
//      stopLoading()
      navigationController?.popViewController(animated: true)
      return
    }
    guard let key = room.key else {
      navigationController?.popViewController(animated: true)
      return
    }
    NetworkingService.shared.chatRef.child("messages").child(key).queryLimited(toLast: 1).observe(.childAdded, with: { (snapshot) in
      guard let chat = Message(snapshot: snapshot) else { return }
      if self.messages.count == 1 {
        let chatTimeStamp = Message(Date(milliseconds: chat.date) ?? Date())!
        chatTimeStamp.msgType = .timestamp
        self.messages.append(chatTimeStamp)
      }
      if let previousChat = self.previousChat {
        self.applyTimeStamp(withChat: chat, andPreviousChat: previousChat)
      }
      self.messages.append(chat)
      self.previousChat = chat
      self.chatCollectionView.reloadData()
//      self.stopLoading()
      self.chatCollectionView.scrollToItem(at: IndexPath(item: 0, section: self.messages.count - 1), at: UICollectionViewScrollPosition.bottom, animated: true)
    })
  }
  
  ////////////////
  
  private func applyTimeStamp(withChat currentChat: Message, andPreviousChat previousChat: Message) {
    guard let currentTime = currentChat.date, let previouseTime = previousChat.date else { return }
    guard let currentDate = Date(milliseconds: currentTime), let previousDate = Date(milliseconds: previouseTime) else { return }
    let dateDifferenceInMin = abs(currentDate.timeIntervalSince(previousDate) / 60.0)
    if dateDifferenceInMin > 30 {
      let timeStampChat = (Message(currentDate)!)
      timeStampChat.msgType = .timestamp
      self.messages.append(timeStampChat)
    }
  }
  
  private func applyTimeStampForScroll(withChat currentChat: Message, andPreviousChat previousChat: Message) -> Bool {
    guard let currentTime = currentChat.date, let previouseTime = previousChat.date else { return false }
    guard let currentDate = Date(milliseconds: currentTime), let previousDate = Date(milliseconds: previouseTime) else { return false }
    let dateDifferenceInMin = abs(currentDate.timeIntervalSince(previousDate) / 60.0)
    if dateDifferenceInMin > 30 {
      let timeStampChat = (Message(currentDate)!)
      timeStampChat.msgType = .timestamp
      self.messages.insert(timeStampChat, at: 0)
      return true
    }else {
      return false
    }
  }
  
  fileprivate func userIsUid1(room: Room?) -> Bool {
    let myUid = NetworkingService.shared.currentUID
    return room?.uid1 == myUid
  }
  
  fileprivate func fetchFriendsUID() -> String? {
    var friendUID: String?
    let myUID = NetworkingService.shared.currentUID
    friendUID = (room?.uid1 == myUID) ? room?.uid2 : room?.uid1
    return friendUID
  }
}

//MARK: UICollectionView
extension NewChatViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    if collectionView == attachmentCollectionView {
      return 2
    }else {
      return messages.count
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if collectionView == attachmentCollectionView {
      if section == 0 {
        return accessoryItemRow1.count
      }else {
        return accessoryItemRow2.count
      }
    }else {
      return 1
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    if collectionView == attachmentCollectionView {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccessoryCell().identifier, for: indexPath) as! AccessoryCell
      if indexPath.section == 0 {
        cell.accessoryImageView.image = accessoryImageRow1[indexPath.item]
        cell.accessoryLabel.text = accessoryItemRow1[indexPath.item]
      }else {
        cell.accessoryImageView.image = accessoryImageRow2[indexPath.item]
        cell.accessoryLabel.text = accessoryItemRow2[indexPath.item]
      }
      return cell
    }else {
      let theChat = messages[indexPath.section]
      switch theChat.msgType {
      case .text:
        if theChat.senderID == NetworkingService.shared.currentUID {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutgoingCell.identifier, for: indexPath) as! OutgoingCell
          cell.contentTextView.text = theChat.text
          guard let contentInNSString = theChat.text as NSString? else { return cell }
          let size = contentInNSString.size(withAttributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)])
          let theContentWidth = size.width
          cell.contentWidth.constant = Swift.min(theContentWidth + 25, collectionView.bounds.width * 0.8)
          return cell
        }else {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IncomingCell.identifier, for: indexPath) as! IncomingCell
          cell.contentTextView.text = theChat.text
          guard let contentInNSString = theChat.text as NSString? else { return cell }
          let size = contentInNSString.size(withAttributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)])
          let theContentWidth = size.width
          cell.contentWidth.constant = Swift.min(theContentWidth + 25, collectionView.bounds.width * 0.8)
          return cell
        }
      case .timestamp:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeStampCell.identifier, for: indexPath) as! TimeStampCell
        let dateDifferenceInMinutes = Date().timeIntervalSince(Date(milliseconds: theChat.date) ?? Date()) / 60
        let dateDifferenceInHour = dateDifferenceInMinutes / 60
        let dateDifferenceInDay = dateDifferenceInHour / 24
        if dateDifferenceInDay > 6 {
          cell.timeLabel.text = Date(milliseconds: theChat.date)?.toString(dateFormat: "MMM dd - hh:mm a")
        }else if dateDifferenceInDay < 1 {
          cell.timeLabel.text = "Today - " + (Date(milliseconds: theChat.date)?.toString(dateFormat: "hh:mm a"))!
        }else if dateDifferenceInDay > 1 && dateDifferenceInDay < 2 {
          cell.timeLabel.text = "Yesterday - " + (Date(milliseconds: theChat.date)?.toString(dateFormat: "hh:mm a"))!
        }else {
          cell.timeLabel.text = Date(milliseconds: theChat.date)?.toString(dateFormat: "E - hh:mm a")
        }
        return cell
        //    case .payment:
        //      if theChat.senderID == NetworkingService.shared.currentUID {
        //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutgoingPaymentCell.identifier, for: indexPath) as! OutgoingPaymentCell
        //        cell.priceLabel.text = theChat.paymentSummary?.amount
        //        cell.dateLabel.text = theChat.paymentSummary?.date
        //        cell.timeLabel.text = theChat.paymentSummary?.time
        //        return cell
        //      }else {
        //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IncomingPaymentCell.identifier, for: indexPath) as! IncomingPaymentCell
        //        cell.priceLabel.text = theChat.paymentSummary?.amount
        //        cell.dateLabel.text = theChat.paymentSummary?.date
        //        cell.timeLabel.text = theChat.paymentSummary?.time
        //        return cell
      //      }
      case .image:
        if theChat.senderID == NetworkingService.shared.currentUID {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OutgoingImageCell.identifier, for: indexPath) as! OutgoingImageCell
          if let imageURL = URL(string: theChat.imageURL ?? "") {
            cell.contentImageView.sd_addActivityIndicator()
            cell.contentImageView.sd_setIndicatorStyle(.gray)
            cell.contentImageView.sd_setImage(with: imageURL, completed: nil)
          }
          return cell
        }else {
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IncomingImageCell.identifier, for: indexPath) as! IncomingImageCell
          if let imageURL = URL(string: theChat.imageURL ?? "") {
            cell.contentImageView.sd_addActivityIndicator()
            cell.contentImageView.sd_setIndicatorStyle(.gray)
            cell.contentImageView.sd_setImage(with: imageURL, completed: nil)
          }
          return cell
        }
      default:
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IncomingImageCell.identifier, for: indexPath) as! IncomingImageCell
        return cell
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    if collectionView == attachmentCollectionView {
      let width = collectionView.bounds.width / 4
      return CGSize(width: width - 5, height: width - 5)
    }else {
      let theChat = messages[indexPath.section]
      switch theChat.msgType {
      case .text:
        guard let contentInNSString = theChat.text as NSString? else { return CGSize.zero }
        let size = contentInNSString.size(withAttributes: [NSAttributedStringKey.font: UIFont(name: "AvenirNext-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)])
        let theContentWidth = Swift.min(size.width, collectionView.bounds.width * 0.8)
        let tempLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: theContentWidth, height: CGFloat.greatestFiniteMagnitude))
        tempLabel.numberOfLines = 0
        tempLabel.text = theChat.text
        tempLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        tempLabel.sizeToFit()
        return CGSize(width: collectionView.bounds.width - 16, height: tempLabel.frame.height + 20)
      case .timestamp:
        return CGSize(width: collectionView.bounds.width, height: 30)
        //    case .payment:
      //      return CGSize(width: collectionView.bounds.width, height: 85)
      case .image:
        return CGSize(width: collectionView.bounds.width - 16, height: 130)
      default:
        return CGSize(width: collectionView.bounds.width - 16, height: 38)
      }
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    if collectionView == attachmentCollectionView {
      let width = collectionView.bounds.width / 4
      return (collectionView.bounds.width - width * 4) / 3
    }else {
      return 10
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    if collectionView == attachmentCollectionView {
      let width = collectionView.bounds.width / 4
      return (collectionView.bounds.width - width * 4) / 3
    }else {
      return 10
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if collectionView == attachmentCollectionView {
      if section == 0 {
        return CGSize.zero
      }else {
        let width = collectionView.bounds.width / 4
        let heightMargin = abs(collectionView.bounds.height - width * 2)
        return CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: heightMargin).size
      }
    }else {
      return CGSize.zero
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if collectionView == attachmentCollectionView {
      if indexPath.section == 0 {
        switch indexPath.item {
        case 0:
          print("Photos")
          useCamera()
        case 1:
          print("Videos")
          usePhotoLibrary()
        case 2:
          print("Contract")
        case 3:
          print("Invoice")
        default:
          print("Default")
        }
      }else {
        switch indexPath.item {
        case 0:
          print("Contact")
        case 1:
          print("Money")
        default:
          print("Default")
        }
      }
    }else {
      let theChat = messages[indexPath.section]
      if theChat.msgType == .image {
        if theChat.senderID == NetworkingService.shared.currentUID {
          let cell = collectionView.cellForItem(at: indexPath) as! OutgoingImageCell
          selectedImage = cell.contentImageView.image
        }else {
          let cell = collectionView.cellForItem(at: indexPath) as! IncomingImageCell
          selectedImage = cell.contentImageView.image
        }
        self.performSegue(withIdentifier: "showMedia", sender: self)
      }
    }
  }
}

//MARK: Segue
extension NewChatViewController {
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showMedia" {
      if segue.destination is NYTPhotoViewController {
        let zoomPhoto = ZoomPhoto(image: selectedImage, placeHolder: nil)
        let datasource = NYTPhotoViewerArrayDataSource(photos: [zoomPhoto])
        let photosViewController = NYTPhotosViewController(dataSource: datasource)
        present(photosViewController, animated: true, completion: {
          self.selectedImage = nil
        })
      } else {
        print("type destination not ok")
      }
    } else {
      print("segue inexistant")
    }
  }
}

//MARK: PopoverTableView
extension NewChatViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return cellEditOptionsList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
    cell.textLabel?.text = cellEditOptionsList[indexPath.row]
    cell.textLabel?.textAlignment = .center
    cell.textLabel?.font = UIFont(name: "OpenSans-Regular", size: 14)
    cell.textLabel?.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
    tableView.separatorColor = UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 1.0)
    tableView.separatorInset = UIEdgeInsetsMake(tableView.separatorInset.top, 6.5, tableView.separatorInset.top, 6.5)
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let theSelectedChat = theSelectedChat, let theSelectedCell = theSelectedCell else { return }
    switch indexPath.row {
    case 0:
      if cellEditOptionsList.count == 1 {
        // delete
        guard let msgKey = theSelectedChat.key else { return }
        let ref = NetworkingService.shared.chatRef.child("messages").child((room?.key)!).child(msgKey)
        if userIsUid1(room: room) {
          ref.updateChildValues(["hideFromFirstUser": true])
        }else {
          ref.updateChildValues(["hideFromSecondUser": true])
        }
        guard let ip = self.messages.index(of: theSelectedChat) else { break }
        self.messages.remove(at: ip)
        self.chatCollectionView.deleteSections(IndexSet([ip]))
      }else {
        // copy
        var value = ""
        if theSelectedChat.senderID == NetworkingService.shared.currentUID {
          //outgoing
          let cell = theSelectedCell as! OutgoingCell
          value = cell.contentTextView.text
        }else {
          //incoming
          let cell = theSelectedCell as! IncomingCell
          value = cell.contentTextView.text
        }
        UIPasteboard.general.string = value
      }
    case 1:
      // delete
      guard let msgKey = theSelectedChat.key else { return }
      let ref = NetworkingService.shared.chatRef.child("messages").child((room?.key)!).child(msgKey)
      if userIsUid1(room: room) {
        ref.updateChildValues(["hideFromFirstUser": true])
      }else {
        ref.updateChildValues(["hideFromSecondUser": true])
      }
      guard let ip = self.messages.index(of: theSelectedChat) else { break }
      self.messages.remove(at: ip)
      self.chatCollectionView.deleteSections(IndexSet([ip]))
    default:
      break
    }
    cellEditPopover?.dismiss()
    self.theSelectedChat = nil
    self.theSelectedCell = nil
  }
}

//MARK: Attachment+ImagePickerDelegate
extension NewChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func useCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      self.picker.allowsEditing = true
      self.picker.sourceType = UIImagePickerControllerSourceType.camera
      self.picker.cameraCaptureMode = .photo
      self.picker.modalPresentationStyle = .fullScreen
      self.present(self.picker,animated: true,completion: nil)
    } else {
      let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style:.default, handler: nil)
      alertVC.addAction(okAction)
      self.present( alertVC, animated: true, completion: nil)
    }
  }
  
  func usePhotoLibrary() {
    self.picker.allowsEditing = true
    self.picker.sourceType = .photoLibrary
    self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
    self.picker.modalPresentationStyle = .popover
    self.present(self.picker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    self.tabBarController?.tabBar.isHidden = true
    self.imageToSend = info[UIImagePickerControllerOriginalImage] as? UIImage
    guard let imageToSend = self.imageToSend else {
      dismiss(animated: true, completion: {
        let alertView = UIAlertController(title: "Error", message: "Something went wrong, failed to fetch the image. Please try again later.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertView.addAction(okAction)
        self.present(alertView, animated: true, completion: nil)
      })
      return
    }
    self.imageData = UIImageJPEGRepresentation(imageToSend, 0.1) ?? #imageLiteral(resourceName: "image_placeholder").sd_imageData()!
    dismiss(animated:true, completion: {
      guard let dateInt = Date().millisecondsSince1970 else { return }
      self.lastMessageToSend = "[PHOTO]"
      self.lastTimeStampToSend = dateInt
      self.sendImageAttachment()
    })
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  func sendImageAttachment() {
    guard let key = room?.key else { return }
    NetworkingService.shared.uploadChatImage(imageData: self.imageData, completion: { url in
      let messageRef = NetworkingService.shared.chatRef.child("messages").child(key).childByAutoId()
      let roomRef = NetworkingService.shared.chatRef.child("rooms").child(key)
      guard let dateInt = Date().millisecondsSince1970 else { return }
      guard let url = url else { return }
      let stringURL = url.absoluteString
      let message = ["senderID": NetworkingService.shared.currentUID, "imageURL": stringURL, "date": dateInt, "userAvatarURL": ""] as [String : Any]
      messageRef.setValue(message)
      if self.userIsUid1(room: self.room){
        roomRef.updateChildValues(["lastMessageuid1":"[PHOTO]", "lastTimestampuid1": dateInt])
      }else {
        roomRef.updateChildValues(["lastMessageuid2":"[PHOTO]", "lastTimestampuid2": dateInt])
      }
//      let friendUID = self.fetchFriendsUID()
//      NetworkingService.shared.fetchSignalUID(withFriendUID: friendUID, completion: { (signalUID) in
//        guard let signalUID = signalUID else {
//          print("no singal uid found!")
//          return
//        }
//        self.sendPushNotification(toFriendSignalUID: signalUID, withMessage: nil, withMedia: "[PHOTO]")
//      })
    })
  }
}
