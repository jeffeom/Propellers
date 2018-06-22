//
//  NewsfeedViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-06-07.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import Hero

class NewsfeedViewController: UIViewController {
  @IBOutlet weak var shadowView: UIView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var mainImageView: UIImageView!
  @IBOutlet weak var userInfoView: UIView!
  @IBOutlet weak var userImageView: ProImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userSpecialLabel: UILabel!
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationController?.navigationBar.barTintColor = ThemeColor.lightBlueColor
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if #available(iOS 11, *) {
//      self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    createRoundShadowView(withShadowView: shadowView, andContentView: contentView, withCornerRadius: 15)
    setupHeroViews()
  }
  
  @IBAction func pressedCardView(_ sender: Any) {
    print("hi")
    let vc2 = UIStoryboard(name: "Newsfeed", bundle: nil).instantiateViewController(withIdentifier: "detailVC") as! DetailViewController
    vc2.hero.isEnabled = true
    present(vc2, animated: true, completion: nil)
  }
  
  func setupHeroViews() {
    mainImageView.hero.id = "mainImageView"
    userImageView.hero.id = "userImageView"
    userInfoView.hero.id = "userInfoView"
  }
}
