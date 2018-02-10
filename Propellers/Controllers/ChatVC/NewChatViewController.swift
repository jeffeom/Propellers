//
//  NewChatViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-02-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import Firebase
import Popover
import KRPullLoader


class NewChatViewController: UIViewController {
  var room: Room?
  var messages: [Message] = []
  
  @IBOutlet weak var mainScrollView: UIScrollView!
  @IBOutlet weak var chatCollectionView: UICollectionView!
  @IBOutlet weak var inputShadowView: UIView!
  @IBOutlet weak var inputToolView: UIView!
  @IBOutlet weak var textViewBorder: UIView!
  @IBOutlet weak var inputTextView: UITextView!
  @IBOutlet weak var consTextViewHeight: NSLayoutConstraint!
  @IBOutlet weak var totalHeight: NSLayoutConstraint!
  @IBOutlet weak var keyboardSpacingConstraint: NSLayoutConstraint!
  
  //Dismiss
  var lastMessageToSend: String?
  var lastTimeStampToSend: Int64?
  var sectionNumber: Int?
  
  //KeyboardHeight
  let notificationCenter = NotificationCenter.default
  var keyboardHeight: CGFloat?
  
  //Attachment
  fileprivate var imageToSend: UIImage?
  fileprivate var imageData: Data = Data()
  fileprivate let picker = UIImagePickerController()
  var selectedImage: UIImage?
  
  //View
  let placeholderText = "Type Something..."
  let placeholderFontColor =  UIColor(red: 206/255, green: 188/255, blue: 178/255, alpha: 1.0)
  
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
    if room.uid1 == room.uid2 {
      let alertView = UIAlertController(title: "Sorry", message: "You cannot message yourself.", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
        NetworkingService.shared.chatRef.child("rooms").child(room.key ?? "").removeValue()
        self.navigationController?.popViewController(animated: true)
      })
      alertView.addAction(okAction)
      present(alertView, animated: true, completion: nil)
      return
    }
    setupBadgeCounts()
    setupLongPressGesture()
    setupNotification()
    eraseAndResetBadgeCounter()
    picker.delegate = self
    chatCollectionView.dataSource = self
    chatCollectionView.delegate = self
    inputTextView.delegate = self
    appearance()
    fetchLatestDialogues(room: room)
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
    //    UserDefaults.standard.set(0, forKey: room?.key ?? "")
    NotificationCenter.default.removeObserver(self, name: Notification.Name("newMessageReceived"), object: nil)
  }
}

//MARK: Setup
extension NewChatViewController {
  func appearance() {
    titleImageView.layer.cornerRadius = titleImageView.bounds.height / 2
    titleImageView.clipsToBounds = true
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
    createRoundShadowView(withShadowView: inputShadowView, andContentView: inputToolView, withCornerRadius: 0, withOpacity: 0.25)
    textViewBorder.layer.cornerRadius = 15
    textViewBorder.layer.borderWidth = 1
    textViewBorder.layer.borderColor = UIColor(red: 206/255, green: 188/255, blue: 178/255, alpha: 1.0).cgColor
    textViewBorder.clipsToBounds = true
    getReadyToType()
    let refreshView = KRPullLoadView()
    refreshView.delegate = self
    chatCollectionView.addPullLoadableView(refreshView, type: .refresh)
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
      })
    }
  }
  
  @objc func adjustKeyboardShowing(notification: Notification) {
    if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
      let keyboardRectangle = keyboardFrame.cgRectValue
      keyboardHeight = keyboardRectangle.height
      mainScrollView.isScrollEnabled = true
      if UIDevice().userInterfaceIdiom == .phone {
        switch UIScreen.main.nativeBounds.height {
        case 2436:
          if #available(iOS 11.0, *) {
            let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom
            keyboardSpacingConstraint.constant = keyboardHeight! - (bottomPadding ?? 34)
          }else {
            keyboardSpacingConstraint.constant = keyboardHeight! - 34
          }
        default:
          keyboardSpacingConstraint.constant = keyboardHeight!
        }
      }
      UIView.animate(withDuration: 0.3, animations: {
        self.view.layoutIfNeeded()
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
        if theChat.uid == NetworkingService.shared.currentUser {
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
  
  func showEditPopup(withAllOptions needAllOptions: Bool, withLocation startPoint: CGPoint, forCell cell: UICollectionViewCell) {
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

/MARK: TextViewDelegate
extension NewChatViewController: UITextViewDelegate {
  func textViewDidBeginEditing(_ textView: UITextView) {
    self.chatCollectionView.scrollToItem(at: IndexPath(item: 0, section: self.messages.count - 1), at: UICollectionViewScrollPosition.bottom, animated: true)
  }
  
  func textViewDidChange(_ textView: UITextView) {
    self.consTextViewHeight.constant = Swift.min(100, textView.contentSize.height)
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

