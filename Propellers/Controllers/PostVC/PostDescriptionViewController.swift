//
//  PostDescriptionViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-07-20.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class PostDescriptionViewController: UIViewController {
  @IBOutlet weak var imageMainView: UIView!
  @IBOutlet weak var postingImageView: UIImageView!
  @IBOutlet weak var textMainView: UIView!
  @IBOutlet weak var postingTextView: UITextView!
  @IBOutlet weak var backButton: UIButton!
  
  var postImage: UIImage?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    postingImageView.image = postImage
    setupHeroViews()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
  }
  
  @IBAction func pressedBackButton(_ sender: UIButton) {
    navigationController?.popViewController(animated: true)
  }
  
  func setupHeroViews() {
    imageMainView.hero.id = "imageMainView"
//    postingImageView.hero.id = "postingImageView"
    textMainView.hero.id = "textMainView"
    postingTextView.hero.id = "postingTextView"
    backButton.hero.id = "backButton"
  }
}

extension PostDescriptionViewController: UITextViewDelegate {
  func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
    let vc2 = UIStoryboard(name: "Post", bundle: nil).instantiateViewController(withIdentifier: "PostDescriptionDetailsViewController") as! PostDescriptionDetailsViewController
    vc2.postImage = postImage
    vc2.hero.isEnabled = true
    present(vc2, animated: true, completion: nil)
    return false
  }
}
