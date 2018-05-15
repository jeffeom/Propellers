//
//  ChatCollectionViewCells.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-02-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import Foundation
import UIKit

class IncomingCell: UICollectionViewCell {
  static let identifier = "incomingCell"
  @IBOutlet weak var bubbleImageView: UIImageView!
  @IBOutlet weak var contentTextView: UITextView!
  @IBOutlet weak var contentWidth: NSLayoutConstraint!
  override func awakeFromNib() {
    super.awakeFromNib()
    bubbleImageView.image = bubbleImageView.image?.resizableImage(withCapInsets: UIEdgeInsetsMake(25, 20, 25, 20), resizingMode: .stretch).withRenderingMode(.alwaysOriginal)
  }
}

class OutgoingCell: UICollectionViewCell {
  static let identifier = "outgoingCell"
  @IBOutlet weak var bubbleImageView: UIImageView!
  @IBOutlet weak var contentTextView: UITextView!
  @IBOutlet weak var contentWidth: NSLayoutConstraint!
  override func awakeFromNib() {
    super.awakeFromNib()
    bubbleImageView.image = bubbleImageView.image?.resizableImage(withCapInsets: UIEdgeInsetsMake(25, 20, 25, 20), resizingMode: .stretch).withRenderingMode(.alwaysOriginal)
  }
}

class IncomingImageCell: UICollectionViewCell {
  static let identifier = "incomingImage"
  @IBOutlet weak var imageContentView: UIView!
  @IBOutlet weak var contentImageView: UIImageView!
  override func awakeFromNib() {
    super.awakeFromNib()
    contentImageView.layer.cornerRadius = 10
    contentImageView.clipsToBounds = true
  }
}

class OutgoingImageCell: UICollectionViewCell {
  static let identifier = "outgoingImage"
  @IBOutlet weak var imageContentView: UIView!
  @IBOutlet weak var contentImageView: UIImageView!
  override func awakeFromNib() {
    super.awakeFromNib()
    contentImageView.layer.cornerRadius = 10
    contentImageView.clipsToBounds = true
  }
}

class IncomingPaymentCell: UICollectionViewCell {
  static let identifier = "incomingPayment"
  @IBOutlet weak var borderView: UIView!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    borderView.layer.cornerRadius = 10
    borderView.layer.borderWidth = 2
    borderView.layer.borderColor = UIColor(red: 0, green: 164/255, blue: 255/255, alpha: 1.0).cgColor
    borderView.clipsToBounds = true
  }
}

class OutgoingPaymentCell: UICollectionViewCell {
  static let identifier = "outgoingPayment"
  @IBOutlet weak var borderView: UIView!
  @IBOutlet weak var priceLabel: UILabel!
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    borderView.layer.cornerRadius = 10
    borderView.layer.borderWidth = 2
    borderView.layer.borderColor = UIColor(red: 0, green: 164/255, blue: 255/255, alpha: 1.0).cgColor
    borderView.clipsToBounds = true
  }
}

class TimeStampCell: UICollectionViewCell {
  static let identifier = "timestampCell"
  @IBOutlet weak var timeLabel: UILabel!
}

class AccessoryCell: UICollectionViewCell {
  @IBOutlet weak var accessoryImageView: UIImageView!
  @IBOutlet weak var accessoryLabel: UILabel!
  let identifier = "accessoryCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    self.layer.cornerRadius = 5
    self.clipsToBounds = true
  }
}
