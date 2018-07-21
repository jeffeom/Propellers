//
//  PostDescriptionDetailsViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-07-20.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class PostDescriptionDetailsViewController: UIViewController {
  @IBOutlet weak var imageMainView: UIView!
  @IBOutlet weak var postingImageView: UIImageView!
  @IBOutlet weak var postingImageShadowView: UIView!
  @IBOutlet weak var textMainShadowView: UIView!
  @IBOutlet weak var textMainView: UIView!
  @IBOutlet weak var postingTextView: UITextView!
  @IBOutlet weak var backButton: UIButton!
  
  var postImage: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    createRoundShadowView(withShadowView: textMainShadowView, andContentView: textMainView, withCornerRadius: 25)
    postingImageView.image = postImage
    setupHeroViews()
    postingTextView.becomeFirstResponder()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  func setupHeroViews() {
    imageMainView.hero.id = "imageMainView"
//    postingImageView.hero.id = "postingImageView"
    postingTextView.hero.id = "postingTextView"
    backButton.hero.id = "backButton"
    textMainView.hero.id = "textMainView"
  }
  
  @IBAction func pressedBackButton(_ sender: UIButton) {
    hero.dismissViewController()
  }
}
