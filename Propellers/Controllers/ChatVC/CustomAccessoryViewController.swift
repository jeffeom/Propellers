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
}
