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
}

class CustomAccessoryViewController: UIViewController {
  @IBOutlet weak var superView: UIView!
  @IBOutlet weak var dismissView: UIView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var collectionView: UICollectionView!
  
  var accessoryItem = ["Photos", "Videos", "Contract", "Invoice", "Contact", "Money"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    appearanceSetup()
    delegateSetup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseInOut, animations: {
      self.superView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
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
    return accessoryItem.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AccessoryCell().identifier, for: indexPath) as! AccessoryCell
    cell.accessoryLabel.text = accessoryItem[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: ((self.containerView.bounds.width - 40) / 4), height: ((self.containerView.bounds.height - 40) / 2))
  }
  
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//    return 20
//  }
//
//  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//    return 20
//  }
}
