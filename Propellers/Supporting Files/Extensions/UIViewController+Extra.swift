//
//  UIViewController+Extra.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-02-10.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView

extension UIViewController {
  func giveHeavyHapticFeedback() {
    if #available(iOS 10.0, *) {
      let hapticFeedback = UIImpactFeedbackGenerator(style: .heavy)
      hapticFeedback.prepare()
      hapticFeedback.impactOccurred()
    }
  }
  
  func createRoundShadowView(withShadowView shadowView: UIView, andContentView contentView: UIView, withCornerRadius cornerRadius: CGFloat) {
    shadowView.backgroundColor = .clear
    shadowView.layer.shadowColor = UIColor.black.cgColor
    shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
    shadowView.layer.shadowOpacity = 0.25
    shadowView.layer.shadowRadius = 2
    
    contentView.backgroundColor = UIColor.white
    contentView.layer.cornerRadius = cornerRadius
    contentView.clipsToBounds = true
  }
  
  func setupActivityIndicator(darkIndicatorView: UIView, activityIndicator: NVActivityIndicatorView) {
    view.addSubview(darkIndicatorView)
    darkIndicatorView.addSubview(activityIndicator)
    activityIndicator.center = darkIndicatorView.center
    darkIndicatorView.backgroundColor = UIColor.white
    let tg = UIGestureRecognizer(target: self, action: #selector(stopLoading))
    darkIndicatorView.addGestureRecognizer(tg)
    darkIndicatorView.layer.opacity = 0
  }
  
  func startLoading(darkIndicatorView: UIView, activityIndicator: NVActivityIndicatorView) {
    darkIndicatorView.layer.opacity = 1
    activityIndicator.startAnimating()
  }
  
  @objc func stopLoading(darkIndicatorView: UIView, activityIndicator: NVActivityIndicatorView) {
    UIView.animate(withDuration: 0.3, animations: {
      darkIndicatorView.layer.opacity = 0
      activityIndicator.stopAnimating()
    })
  }
}
