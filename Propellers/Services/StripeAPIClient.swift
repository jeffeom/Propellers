//
//  StripeAPIClient.swift
//  Propellers
//
//  Created by Jeff Eom on 2018-05-17.
//  Copyright © 2018 Jeff Eom. All rights reserved.
//

import Foundation
import Stripe
import Alamofire
import Firebase

class StripeAPIClient: NSObject {
  static let shared = StripeAPIClient()
//
//  func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
//    let baseURL = URL(string: Constants.baseURLString)
//    let url = baseURL?.appendingPathComponent("create_customer")
//    let params: [String: Any] = [
//      "email": Auth.auth().currentUser?.email ?? "",
//      "scource": NetworkingService.shared.paymentToken!
//    ]
//    Alamofire.request(url!, method: .post, parameters: params)
//      .validate(statusCode: 200..<300)
//      .responseJSON { response in
//        switch response.result {
//        case .success(let json):
//          completion(json as? [String: AnyObject], nil)
//        case .failure(let error):
//          completion(nil, error)
//        }
//    }
//  }
  
  func completeCharge(with token: STPToken, amount: Int, completion: @escaping (Result<Any>) -> Void) {
    let baseURL = URL(string: Constants.baseURLString)
    let url = baseURL?.appendingPathComponent("charge")
    let params: [String: Any] = [
      "token": token.tokenId,
      "amount": amount,
      "currency": Constants.defaultCurrency,
      "description": Constants.defaultDescription
    ]
    Alamofire.request(url!, method: .post, parameters: params)
      .validate(statusCode: 200..<300)
      .responseString { response in
        switch response.result {
        case .success:
          completion(Result.success("success"))
        case .failure(let error):
          completion(Result.failure(error))
        }
    }
  }
}
