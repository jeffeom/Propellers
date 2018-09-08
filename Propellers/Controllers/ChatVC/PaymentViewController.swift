//
//  PaymentViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-05-17.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import UIKit
import Stripe

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
  
  var paymentContext: STPPaymentContext?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    appearance()
//    setupData()
    amountTextField.delegate = self
  }
}

//MARK: IBActions
extension PaymentViewController {
  @IBAction func pressedServiceFeeInfoButton(_ sender: UIButton) {
    infoView = UIView(frame: serviceFeeInfoButton.frame)
    infoView?.frame.origin = CGPoint(x: serviceFeeInfoButton.frame.origin.x + 18 + 30, y: serviceFeeInfoButton.convert(serviceFeeInfoButton.frame.origin, to: self.view).y)
    infoView?.frame.size = CGSize(width: 200, height: 200)
    infoView?.backgroundColor = .blue
    //    infoView?.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(infoView!)
  }
  
  @IBAction func pressedAddNewCard(_ sender: UIButton) {
    
  }
  
  @IBAction func pressedProceedButton(_ sender: UIButton) {
    let addCardViewController = STPAddCardViewController()
    addCardViewController.delegate = self
    navigationController?.pushViewController(addCardViewController, animated: true)
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
//  func setupData() {
//    let config = STPPaymentConfiguration.shared()
//    config.publishableKey = Constants.publishableKey
//
//    let customerContext = STPCustomerContext(keyProvider: StripeAPIClient.shared)
//    paymentContext = STPPaymentContext(customerContext: customerContext,
//                                       configuration: config,
//                                       theme: settings.theme)
//    let userInformation = STPUserInformation()
//    paymentContext?.prefilledInformation = userInformation
//    paymentContext?.paymentAmount = price
//    paymentContext?.paymentCurrency = self.paymentCurrency
//    paymentContext?.delegate = self
//    paymentContext?.hostViewController = self
//  }
  
  func appearance() {
    payerImageView.sd_addActivityIndicator()
    payerImageView.sd_setIndicatorStyle(.gray)
//    payerImageView.sd_setImage(with: URL(string: payer?.imageURL ?? ""), completed: nil)
    payerImageView.layer.cornerRadius = payerImageView.bounds.width / 2
    payerImageView.clipsToBounds = true
    payerNameLabel.text = payer?.fullName
    receiverImageView.sd_addActivityIndicator()
    receiverImageView.sd_setIndicatorStyle(.gray)
//    receiverImageView.sd_setImage(with: URL(string: receiver?.imageURL ?? ""), completed: nil)
    receiverImageView.layer.cornerRadius = receiverImageView.bounds.width / 2
    receiverImageView.clipsToBounds = true
    receiverLabel.text = receiver?.fullName
  }
}

//MARK: UITextFieldDelegate
extension PaymentViewController: UITextFieldDelegate {
  
}

//MARK: StripeDelegate
extension PaymentViewController: STPAddCardViewControllerDelegate {
  func addCardViewControllerDidCancel(_ addCardViewController: STPAddCardViewController) {
    navigationController?.popViewController(animated: true)
  }
  
  func addCardViewController(_ addCardViewController: STPAddCardViewController,
                             didCreateToken token: STPToken,
                             completion: @escaping STPErrorBlock) {
    StripeAPIClient.shared.completeCharge(with: token, amount: (Int(amountTextField.text ?? "0") ?? 0) * 100) { (result) in
      switch result {
      case .success:
        completion(nil)

        let alertController = UIAlertController(title: "Congrats",
                                                message: "Your payment was successful!",
                                                preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
          self.navigationController?.popViewController(animated: true)
        })
        alertController.addAction(alertAction)
        self.present(alertController, animated: true)
      case .failure(let error):
        completion(error)
      }
    }
    
//    StripeAPIClient.shared.createCustomer(with: token) { (result) in
//      switch result {
//      case .success:
//        completion(nil)
//        let alertController = UIAlertController(title: "Congrats",
//                                                message: "Customer has been added",
//                                                preferredStyle: .alert)
//        let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
//          self.navigationController?.popViewController(animated: true)
//        })
//        alertController.addAction(alertAction)
//        self.present(alertController, animated: true)
//      case .failure(let error):
//        completion(error)
//      }
//    }
  }
}
