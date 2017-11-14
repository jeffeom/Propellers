//
//  CustomAccessoryViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-06.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit

class AccessoryCell: UICollectionViewCell {
  @IBOutlet weak var accessoryLabel: UILabel!
  let identifier = "accessoryCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = 5
    self.clipsToBounds = true
  }
}

class CustomAccessoryViewController: UIViewController {
  @IBOutlet weak var superView: UIView!
  @IBOutlet weak var dismissView: UIView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  var roomKey: String?
  fileprivate var imageToSend: UIImage?
  fileprivate var imageData: Data = Data()
  fileprivate let picker = UIImagePickerController()
  var selectedImage: UIImage?
  
  var accessoryItemRow1 = ["Photos", "Videos", "Contract", "Invoice"]
  var accessoryItemRow2 = ["Contact", "Money"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    appearanceSetup()
    delegateSetup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
      self.superView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }, completion: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
      self.superView.backgroundColor = UIColor.clear
    }, completion: nil)
  }
}

//MARK: Setup
extension CustomAccessoryViewController {
  func appearanceSetup() {
    
  }
  
  func delegateSetup() {
    collectionView.delegate = self
    collectionView.dataSource = self
    picker.delegate = self
  }
}

//MARK: IBAction
extension CustomAccessoryViewController {
  @IBAction func tappedToDismiss(_ sender: UITapGestureRecognizer) {
    self.dismiss(animated: true, completion: nil)
  }
}

//MARK: CollectionViewDelegate, Datasource
extension CustomAccessoryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if section == 0 {
      return accessoryItemRow1.count
    }else {
      return accessoryItemRow2.count
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccessoryCell().identifier, for: indexPath) as! AccessoryCell
    if indexPath.section == 0 {
      cell.accessoryLabel.text = accessoryItemRow1[indexPath.item]
    }else {
      cell.accessoryLabel.text = accessoryItemRow2[indexPath.item]
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.bounds.width / 4
    return CGSize(width: width - 5, height: width - 5)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    let width = collectionView.bounds.width / 4
    return (collectionView.bounds.width - width * 4) / 3
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    let width = collectionView.bounds.width / 4
    return (collectionView.bounds.width - width * 4) / 3
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
    if section == 0 {
      return CGSize.zero
    }else {
      let width = collectionView.bounds.width / 4
      let heightMargin = collectionView.bounds.height - width * 2
      return CGRect(x: 0, y: 0, width: collectionView.bounds.width, height: heightMargin - 20).size
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
  }
}

//MARK: Attachment+ImagePickerDelegate
extension CustomAccessoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
    self.dismiss(animated: true, completion: nil)
    NetworkingService.shared.uploadChatImage(imageData: self.imageData, completion: { url in
      let messageRef = NetworkingService.shared.chatRef.child("messages").child(key).childByAutoId()
      let roomRef = NetworkingService.shared.chatRef.child("rooms").child(key)
      guard let dateInt = Date().millisecondsSince1970 else { return }
      guard let url = url else { return }
      let stringURL = url.absoluteString
      let message = Message(senderID: NetworkingService.shared.currentUID, text: nil, imageURL: stringURL, date: dateInt)
      
      messageRef.setValue(message.json())
      roomRef.updateChildValues(["latestText": "[Photo]", "date": dateInt])
    })
  }
}
