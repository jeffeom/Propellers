//
//  PostViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-07-20.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {
  @IBOutlet weak var passionView: UIView!
  @IBOutlet weak var portfolioView: UIView!
  
  fileprivate var imageToSend: UIImage?
  fileprivate var imageData: Data = Data()
  fileprivate let picker = UIImagePickerController()
  
  var selectedImage: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    picker.delegate = self
    setupTouchGesture()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  @IBAction func pressedCancelButton(_ sender: UIButton) {
    dismiss(animated: true, completion: nil)
  }
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
  func setupTouchGesture() {
    let tg1 = UITapGestureRecognizer(target: self, action: #selector(openLibrary))
    let tg2 = UITapGestureRecognizer(target: self, action: #selector(openLibrary))

    passionView.addGestureRecognizer(tg1)
    portfolioView.addGestureRecognizer(tg2)
  }
  
  @objc func openLibrary() {
    self.picker.allowsEditing = false
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
      let toVC = UIStoryboard(name: "Post", bundle: nil).instantiateViewController(withIdentifier: "PostDescriptionViewController") as! PostDescriptionViewController
      toVC.postImage = self.imageToSend
      self.navigationController?.pushViewController(toVC, animated: true)
    })
  }
  
  func sendImageAttachment() {
    print("image selected")
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
  }
}
