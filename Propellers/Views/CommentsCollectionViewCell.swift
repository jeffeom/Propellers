//
//  CommentsCollectionViewCell.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-07-05.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class CommentsCollectionViewCell: UICollectionViewCell {
  static let identifier = "commentsCell"
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
}
