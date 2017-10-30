//
//  MessengerViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-10-23.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import NMessenger
import AsyncDisplayKit

class MessengerViewController: NMessengerViewController {
  let segmentedControlPadding: CGFloat = 10
  let segmentedControlHeight: CGFloat = 30
  
  var messagesGroups: [MessageGroup]?
  
  let messageTimestamp = MessageSentIndicator()
  
  private(set) var lastMessageGroup: MessageGroup? = nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    appearance()
  }
  
  override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
    //create a new text message
    let textContent = TextContentNode(textMessageString: text, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
    let newMessage = MessageNode(content: textContent)
    newMessage.cellPadding = messagePadding
    newMessage.currentViewController = self
    self.postText(newMessage, isIncomingMessage: false)
    return newMessage
  }
}

//MARK: Initial Setup
extension MessengerViewController {
  func appearance() {
    placeholderFix()
    createTimeStamp()
    automaticallyAdjustsScrollViewInsets = false
  }
  
  func placeholderFix() {
    guard let inputView = self.inputBarView as? NMessengerBarView else { return }
    inputView.inputTextViewPlaceholder = "Type your message here ..."
  }
  
  func createTimeStamp() {
    //    let date = Date(milliseconds: selectedRoom?.timeUid2)
    let currentDate = Date()
    // [REFACTOR]
    let dateDiff = Calendar.current.dateComponents([.day], from: currentDate, to: currentDate)
    if dateDiff.day == 0 {
      messageTimestamp.messageSentText = currentDate.toString(dateFormat: "h:mm a")
      self.addMessageToMessenger(messageTimestamp)
    }else if (dateDiff.day ?? 0 > 0) && (dateDiff.day ?? 0 <= 7){
      messageTimestamp.messageSentText = currentDate.toString(dateFormat: "EEEE, h:mm a")
      self.addMessageToMessenger(messageTimestamp)
    }else{
      messageTimestamp.messageSentText = currentDate.toString(dateFormat: "MMM d, h:mm a")
      self.addMessageToMessenger(messageTimestamp)
    }
  }
}

//MARK: Helper method
extension MessengerViewController {
  fileprivate func postText(_ message: MessageNode, isIncomingMessage: Bool) {
    if self.lastMessageGroup == nil || self.lastMessageGroup?.isIncomingMessage == !isIncomingMessage {
      self.lastMessageGroup = self.createMessageGroup()
      //add avatar if incoming message
      if isIncomingMessage {
        self.lastMessageGroup?.avatarNode = self.createAvatar()
      }
      self.lastMessageGroup!.isIncomingMessage = isIncomingMessage
      self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: false)
      self.messengerView.addMessage(self.lastMessageGroup!, scrollsToMessage: true, withAnimation: isIncomingMessage ? .left : .right)
    } else {
      self.messengerView.addMessageToMessageGroup(message, messageGroup: self.lastMessageGroup!, scrollsToLastMessage: true)
    }
  }
  
  fileprivate func createMessageGroup() -> MessageGroup {
    let newMessageGroup = MessageGroup()
    newMessageGroup.currentViewController = self
    newMessageGroup.cellPadding = self.messagePadding
    return newMessageGroup
  }
  
  fileprivate func createAvatar()->ASImageNode {
    let avatar = ASImageNode()
    avatar.image = UIImage(named: "nAvatar")
    avatar.backgroundColor = UIColor.lightGray
    avatar.style.preferredSize = CGSize(width: 20, height: 20)
    avatar.layer.cornerRadius = 10
    return avatar
  }
}

