//
//  PaymentViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-05-17.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit

class PaymentViewController: UIViewController {
  static let identifier = "paymentVC"
  
  @IBOutlet weak var payerImageView: UIImageView!
  @IBOutlet weak var payerNameLabel: UILabel!
  @IBOutlet weak var receiverImageView: UIImageView!
  @IBOutlet weak var receiverLabel: UILabel!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var serviceFeeInfoButton: UIButton!
  @IBOutlet weak var serviceFeeTextField: UITextField!
  @IBOutlet weak var proceedButton: UIButton!
  
  var infoView: UIView?
  
  var payer: UserModel?
  var receiver: UserModel?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    appearance()
    amountTextField.delegate = self
  }
  
  @IBAction func pressedServiceFeeInfoButton(_ sender: UIButton) {
    infoView = UIView(frame: serviceFeeInfoButton.frame)
    infoView?.frame.origin = CGPoint(x: serviceFeeInfoButton.frame.origin.x + 18 + 30, y: serviceFeeInfoButton.convert(serviceFeeInfoButton.frame.origin, to: self.view).y)
    infoView?.frame.size = CGSize(width: 200, height: 200)
    infoView?.backgroundColor = .blue
//    infoView?.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(infoView!)
  }
  
}

//MARK: IBActions
extension PaymentViewController {
  @IBAction func pressedProceedButton(_ sender: UIButton) {
    print("yay")
  }
  
  @IBAction func pressedOutside(_ sender: UITapGestureRecognizer) {
    guard let infoView = infoView else { return }
    if self.view.subviews.contains(infoView) {
      infoView.removeFromSuperview()
    }
  }
}

//MARK: Setup
extension PaymentViewController {
  func appearance() {
    payerImageView.sd_addActivityIndicator()
    payerImageView.sd_setIndicatorStyle(.gray)
    payerImageView.sd_setImage(with: URL(string: payer?.imageURL ?? ""), completed: nil)
    payerImageView.layer.cornerRadius = payerImageView.bounds.width / 2
    payerImageView.clipsToBounds = true
    payerNameLabel.text = payer?.fullName
    receiverImageView.sd_addActivityIndicator()
    receiverImageView.sd_setIndicatorStyle(.gray)
    receiverImageView.sd_setImage(with: URL(string: receiver?.imageURL ?? ""), completed: nil)
    receiverImageView.layer.cornerRadius = receiverImageView.bounds.width / 2
    receiverImageView.clipsToBounds = true
    receiverLabel.text = receiver?.fullName
  }
}

//MARK: UITextFieldDelegate
extension PaymentViewController: UITextFieldDelegate {
  
}
