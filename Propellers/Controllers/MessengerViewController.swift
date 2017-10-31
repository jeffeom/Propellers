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
  var messageGroups: [MessageGroup]?
  let messageTimestamp = MessageSentIndicator()
  
  private(set) var lastMessageGroup: MessageGroup? = nil
  
  var currentUID: String?
  
  var firstLoad = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    currentUID = NetworkingService.shared.currentUID
    appearance()
//    fetchMessages()
    fetchMessagesByChildAdded()
  }
  
  override func sendText(_ text: String, isIncomingMessage: Bool) -> GeneralMessengerCell {
    //create a new text message
    let textContent = TextContentNode(textMessageString: text, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
    let newMessage = MessageNode(content: textContent)
    newMessage.cellPadding = messagePadding
    newMessage.currentViewController = self
    NetworkingService.shared.sendMessage(roomID: "abcd", senderID: currentUID!, withText: textContent.textMessageString?.string ?? "", onDate: Int64(Date().timeIntervalSince1970))
    self.postText(newMessage, isIncomingMessage: false)
    return newMessage
  }
}

//MARK: NetworkingServices
extension MessengerViewController {
  fileprivate func reloadMessengerView() {
    self.messengerView.addMessages(self.messageGroups!, scrollsToMessage: false)
    self.messengerView.scrollToLastMessage(animated: false)
    self.lastMessageGroup = self.messageGroups?.last
  }
  
  func fetchMessages() {
    guard let currentUID = currentUID else { return }
    self.messageGroups = [MessageGroup]()
    NetworkingService.shared.fetchMessagesBySingleEvent(roomID: "abcd") { (messages) in
      guard let messages = messages else { return }
      for message in messages {
        guard let messageText = message.text else { return }
        if message.senderID == currentUID {
          if message == messages.last {
            self.fetchMessage(withText: messageText, isIncomingMessage: false, lastMessage: true)
            self.reloadMessengerView()
            self.firstLoad = false
          }else {
            self.fetchMessage(withText: messageText, isIncomingMessage: false, lastMessage: false)
          }
        }else {
          if message == messages.last {
            self.fetchMessage(withText: messageText, isIncomingMessage: true, lastMessage: true)
            self.reloadMessengerView()
            self.firstLoad = false
          }else {
            self.fetchMessage(withText: messageText, isIncomingMessage: true, lastMessage: false)
          }
        }
      }
    }
  }

  func fetchMessagesByChildAdded() {
    NetworkingService.shared.fetchMessagesByChildAdded(roomID: "abcd") { (message) in
//      if !self.firstLoad {
        if message.senderID != self.currentUID {
          let textContent = TextContentNode(textMessageString: message.text!, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
          let newMessage = MessageNode(content: textContent)
          newMessage.cellPadding = self.messagePadding
          newMessage.currentViewController = self
          self.postText(newMessage, isIncomingMessage: true)
        }
//      }
    }
  }

  func fetchMessage(withText text: String, isIncomingMessage: Bool, lastMessage: Bool) {
    let textContent = TextContentNode(textMessageString: text, currentViewController: self, bubbleConfiguration: self.sharedBubbleConfiguration)
    let newMessage = MessageNode(content: textContent)
    newMessage.cellPadding = self.messagePadding
    newMessage.currentViewController = self
    if messageGroups?.last == nil || messageGroups?.last?.isIncomingMessage == !isIncomingMessage {
      let newMessageGroup = self.createMessageGroup()
      //add avatar if incoming message
      if isIncomingMessage {
        newMessageGroup.avatarNode = self.createAvatar()
      }
      newMessageGroup.isIncomingMessage = isIncomingMessage
      newMessageGroup.addMessageToGroup(newMessage, completion: nil)
      messageGroups?.append(newMessageGroup)
    } else {
      messageGroups?.last?.addMessageToGroup(newMessage, completion: nil)
    }
//    if lastMessage {
//      messengerView.addMessage(newMessage, scrollsToMessage: false)
//      messengerView.scrollToLastMessage(animated: false)
//      lastMessageGroup = messageGroups?.last
//    }
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
  private func postText(_ message: MessageNode, isIncomingMessage: Bool) {
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

