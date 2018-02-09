//
//  RoomTableViewCell.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-02-08.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class RoomTableViewCell: UITableViewCell {
  @IBOutlet weak var cellContentShadowView: UIView!
  @IBOutlet weak var cellContentView: UIView!
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var roomNameLabel: UILabel!
  @IBOutlet weak var roomLatestTextLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var newIndicatorImageView: UIImageView!
  
  var isNew: Bool = false {
    didSet {
      newIndicatorImageView.isHidden = !isNew
    }
  }
  let identifier = "roomTableViewCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    backgroundColor = .clear
    
    cellContentShadowView.backgroundColor = .clear
    cellContentShadowView.layer.shadowColor = UIColor.black.cgColor
    cellContentShadowView.layer.shadowOffset = CGSize(width: 1, height: 1)
    cellContentShadowView.layer.shadowOpacity = 0.25
    cellContentShadowView.layer.shadowRadius = 2
    
    cellContentView.backgroundColor = UIColor.white
    cellContentView.layer.cornerRadius = 8
    cellContentView.clipsToBounds = true
  }
}
