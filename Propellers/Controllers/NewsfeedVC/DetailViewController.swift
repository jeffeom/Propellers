//
//  DetailViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-06-21.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var userImageView: ProImageView!
  @IBOutlet weak var userInfoView: UIView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userSpecialLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var buttonStackView: UIStackView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupHeroViews()
  }
  
  func setupHeroViews() {
    mainImageView.hero.id = "mainImageView"
    userImageView.hero.id = "userImageView"
    userInfoView.hero.id = "userInfoView"
    textView.hero.modifiers = [.translate(y: 500), .useGlobalCoordinateSpace]
    buttonStackView.hero.modifiers = [.translate(x: 500), .useGlobalCoordinateSpace]
  }
}

extension DetailViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y < -150 || scrollView.contentOffset.y > 150 {
      self.hero.dismissViewController()
    }
  }
}
