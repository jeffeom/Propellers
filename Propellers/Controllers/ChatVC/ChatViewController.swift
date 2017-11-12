//
//  ChatViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-06.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import JSQMessagesViewController

extension JSQMessagesInputToolbar {
  override open func didMoveToWindow() {
    super.didMoveToWindow()
    if #available(iOS 11.0, *) {
      if self.window?.safeAreaLayoutGuide != nil {
        self.bottomAnchor.constraintLessThanOrEqualToSystemSpacingBelow((self.window?.safeAreaLayoutGuide.bottomAnchor)!, multiplier: 1.0).isActive = true
      }
    }
  }
}

final class ChatViewController: JSQMessagesViewController {
  var roomKey: String?
  var room: Room?
  
  @IBOutlet weak var activitySheet: UIView!
  @IBOutlet weak var activitySheetHeightConstraint: NSLayoutConstraint!
  fileprivate var messages = [JSQMessage]()
  fileprivate var friendUID: String?
  fileprivate var imageToSend: UIImage?
  fileprivate var imageData: Data = Data()
  fileprivate let picker = UIImagePickerController()
  var selectedImage: UIImage?
  
  lazy var outgoingBubble: JSQMessagesBubbleImage = {
    return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor(red:0.55, green:0.85, blue:0.58, alpha:1.00))
  }()
  
  lazy var incomingBubble: JSQMessagesBubbleImage = {
    return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.white)
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    senderId = NetworkingService.shared.currentUID
    senderDisplayName = ""
    picker.delegate = self
    fetchMessages()
    friendUID = fetchFriendsUID()
    collectionView.backgroundColor = UIColor(red:0.94, green:0.94, blue:0.95, alpha:1.00)
    collectionView.collectionViewLayout.sectionInset = UIEdgeInsetsMake(20, 10, 10, -20)
  }
}

//MARK: NetworkingServices
extension ChatViewController {
  func fetchMessages() {
    NetworkingService.shared.fetchMessagesByChildAdded(roomID: roomKey ?? "") { (message) in
      let date = message.date
      let senderUID = message.senderID
      let text = message.text
      if let imageURL = message.imageURL {
        if imageURL.isEmpty {
          if let message =
            JSQMessage(senderId: senderUID, senderDisplayName: self.senderDisplayName, date: Date(milliseconds: date), text: text)
          {
            self.messages.append(message)
            self.finishReceivingMessage()
          }else {
            self.collectionView.reloadData()
          }
        }else {
          guard let attachment = message.imageURL else { return }
          guard let attachmentURL = URL(string: attachment) else { return }
          let mediaData = AsyncPhotoMediaItem(withURL: attachmentURL)
          if let message = JSQMessage(senderId: senderUID, senderDisplayName: self.senderDisplayName, date: Date(milliseconds: date), media: mediaData){
            if message.senderId == self.senderId {
              mediaData.appliesMediaViewMaskAsOutgoing = true
            } else {
              mediaData.appliesMediaViewMaskAsOutgoing = false
            }
            self.messages.append(message)
            self.finishReceivingMessage()
          }
        }
      }else {
        if let message =
          JSQMessage(senderId: senderUID, senderDisplayName: self.senderDisplayName, date: Date(milliseconds: date), text: text)
        {
          self.messages.append(message)
          self.finishReceivingMessage()
        }else {
          self.collectionView.reloadData()
        }
      }
    }
  }
}

//MARK: JSQCollectionView
extension ChatViewController {
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    // implemented in cellforItemAt function.
    // need to have this function or else we get fatalerror.
    return nil
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    let message = messages[indexPath.item]
    var previousMessage: JSQMessage?
    if indexPath.item > 1 {
      previousMessage = messages[indexPath.item - 1]
    }
    
    if !message.isMediaMessage {
      cell.textView.isSelectable = false
      cell.textView.isUserInteractionEnabled = false
    }
    
    if previousMessage == nil {
      if message.senderId == senderId {
        cell.textView?.textColor = UIColor.white
        cell.avatarImageView.isHidden = true
      } else {
        cell.textView?.textColor = UIColor.black
        NetworkingService.shared.downloadUserAvatarPhoto(withUid: friendUID!, to: cell.avatarImageView)
        cell.avatarImageView.isHidden = false
      }
    }else {
      if previousMessage!.senderId == message.senderId {
        if message.senderId == senderId {
          cell.textView?.textColor = UIColor.white
        } else {
          cell.textView?.textColor = UIColor.black
        }
        cell.avatarImageView.isHidden = true
      }else {
        if message.senderId == senderId {
          cell.textView?.textColor = UIColor.white
          cell.avatarImageView.isHidden = true
        } else {
          cell.textView?.textColor = UIColor.black
          NetworkingService.shared.downloadUserAvatarPhoto(withUid: friendUID!, to: cell.avatarImageView)
          cell.avatarImageView.isHidden = false
        }
      }
    }
    cell.layoutIfNeeded()
    cell.avatarImageView.clipsToBounds = true
    cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.width / 2.0
    cell.avatarImageView.layer.masksToBounds = true
    cell.avatarImageView.contentMode = .scaleAspectFill
    return cell
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return messages[indexPath.item]
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
  {
    return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
  {
    let previousIP = indexPath.item - 1
    let currentMessage = messages[indexPath.item]
    
    if indexPath.item == 0 {
      return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: currentMessage.date)
    }
    if previousIP > 0 {
      let previousMessage = messages[previousIP]
      let dateDifferenceInMin = currentMessage.date.timeIntervalSince(previousMessage.date) / 60.0
      if dateDifferenceInMin > 30 {
        return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: currentMessage.date)
      }
    }
    return nil
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
  {
    let previousIP = indexPath.item - 1
    let currentMessage = messages[indexPath.item]
    
    if indexPath.item == 0 {
      return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    if previousIP > 0 {
      let previousMessage = messages[previousIP]
      let dateDifferenceInMin = currentMessage.date.timeIntervalSince(previousMessage.date) / 60.0
      if dateDifferenceInMin > 30 {
        return kJSQMessagesCollectionViewCellLabelHeightDefault
      }
    }
    return 0.0
  }
  
  override func didPressAccessoryButton(_ sender: UIButton!) {
    guard let toVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "accessoryVC") as? CustomAccessoryViewController else {
      print("Could not instantiate view controller with identifier of type SecondViewController")
      return
    }
    toVC.modalPresentationStyle = .custom
    toVC.transitioningDelegate = self
    present(toVC, animated: true, completion: nil)
  }
}

//MARK: TransitioningDelegate
extension ChatViewController: UIViewControllerTransitioningDelegate {
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
    return AccessoryPresentationViewController(presentedViewController: presented, presenting: presenting)
  }
}

class AccessoryPresentationViewController : UIPresentationController {
  override var frameOfPresentedViewInContainerView: CGRect {
    return CGRect(x: 0, y: 0, width: containerView!.bounds.width, height: containerView!.bounds.height)
  }
}

//MARK: JSQFuncitons
extension ChatViewController {
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
  {
    guard let key = roomKey else { return }
    guard let dateInt = Date().millisecondsSince1970 else { return }
    NetworkingService.shared.sendMessage(roomID: key, senderID: senderId, withText: text, onDate: dateInt)
    self.finishSendingMessage()
  }
}

//MARK: User Check
extension ChatViewController {
  func fetchFriendsUID() -> String? {
    var friendUID: String?
    let myUID = senderId
    if room?.uid1 == myUID { friendUID = room?.uid2 } else { friendUID = room?.uid1 }
    return friendUID
  }
  
  func userIsUid1(room: Room?) -> Bool {
    let myUid = NetworkingService.shared.currentUID
    return room?.uid1 == myUid
  }
}

//MARK: Attachment+ImagePickerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func useCamera() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      self.picker.allowsEditing = false
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
    self.picker.allowsEditing = false
    self.picker.sourceType = .photoLibrary
    self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
    self.picker.modalPresentationStyle = .popover
    self.present(self.picker, animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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
    self.imageData = UIImageJPEGRepresentation(imageToSend, 0.1) ?? #imageLiteral(resourceName: "userPlaceHolder").sd_imageData()!
    dismiss(animated:true, completion: {
      self.sendImageAttachment()
    })
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
  
  func sendImageAttachment() {
    guard let key = roomKey else { return }
    NetworkingService.shared.uploadChatImage(imageData: self.imageData, completion: { url in
      let messageRef = NetworkingService.shared.chatRef.child("messages").child(key).childByAutoId()
      let roomRef = NetworkingService.shared.chatRef.child("rooms").child(key)
      guard let dateInt = Date().millisecondsSince1970 else { return }
      guard let url = url else { return }
      let stringURL = url.absoluteString
      let message = Message(senderID: NetworkingService.shared.currentUID, text: nil, imageURL: stringURL, date: dateInt)
      
      messageRef.setValue(message.json())
      roomRef.updateChildValues(["latestText": "[Photo]", "date": dateInt])
      self.finishSendingMessage()
    })
  }
}
