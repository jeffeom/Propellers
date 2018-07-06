//
//  DetailViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-06-21.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
  @IBOutlet weak var totalStackView: UIStackView!
  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var userImageView: ProImageView!
  @IBOutlet weak var userInfoView: UIView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userSpecialLabel: UILabel!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var buttonStackView: UIStackView!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var commentsCountLabel: UILabel!
  @IBOutlet weak var commentsCollectionView: UICollectionView!
  @IBOutlet weak var commentsCollectionViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var exitView: UIView!
  @IBOutlet weak var commentView: UIView!
  @IBOutlet weak var commentTextField: UITextField!
  @IBOutlet weak var commentSendButton: UIButton!
  @IBOutlet weak var commentViewBottomConstraint: NSLayoutConstraint!
  
  var commentsArray = ["1", "2", "3", "4"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupHeroViews()
    setupCommentView()
    setupExitView()
    commentsCollectionViewHeightConstraint.constant = CGFloat(commentsArray.count * 40 + commentsArray.count * 15)
  }
  
  func setupHeroViews() {
    mainImageView.hero.id = "mainImageView"
    userImageView.hero.id = "userImageView"
    userInfoView.hero.id = "userInfoView"
    textView.hero.modifiers = [.translate(y: 500), .useGlobalCoordinateSpace]
    buttonStackView.hero.modifiers = [.translate(x: 500), .useGlobalCoordinateSpace]
    exitView.hero.modifiers = [.translate(y: -500), .useGlobalCoordinateSpace]
  }
  
  func setupExitView() {
    exitView.layer.cornerRadius = exitView.bounds.width / 2
    exitView.clipsToBounds = true
  }
  
  func setupCommentView() {
    commentView.layer.borderColor = UIColor(red: 194/255, green: 194/255, blue: 194/255, alpha: 1.0).cgColor
    commentView.layer.borderWidth = 1
    commentView.layer.cornerRadius = 20
    commentView.clipsToBounds = true
    commentSendButton.layer.cornerRadius = 15
    commentSendButton.clipsToBounds = true
  }
  @IBAction func pressedExitButton(_ sender: UIButton) {
    self.hero.dismissViewController()
  }
}

extension DetailViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView.contentOffset.y < -150 {
      self.hero.dismissViewController()
    }
    
    //change exit view color
    if scrollView.contentOffset.y + 35 >
      mainImageView.bounds.height {
      UIView.animate(withDuration: 0.2) {
        self.exitView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
      }
    }else {
      UIView.animate(withDuration: 0.2) {
        self.exitView.backgroundColor = .white
      }
    }
    
    //show comment view
    if scrollView.contentOffset.y + self.view.bounds.height > totalStackView.bounds.height * 0.95 {
      commentViewBottomConstraint.constant = 20
      UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
        self.view.layoutIfNeeded()
      })
    }else {
      if commentViewBottomConstraint.constant == 20 {
        commentViewBottomConstraint.constant = -50
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
          self.view.layoutIfNeeded()
        })
      }
    }
  }
}

extension DetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return commentsArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentsCollectionViewCell.identifier, for: indexPath) as! CommentsCollectionViewCell
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 40)
  }
}
