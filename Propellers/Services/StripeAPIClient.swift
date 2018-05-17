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

class StripeAPIClient: NSObject, STPEphemeralKeyProvider {
  static let shared = StripeAPIClient()
//  func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
//    let baseURL = URL(string: NetworkingService.baseURLString)!
//    let url = baseURL.appendingPathComponent("stripe/ephemeral_keys")
//    Alamofire.request(url, method: .post, parameters: [
//      "token": NetworkingService.shared.paymentToken!,
//      "user_id": NetworkingService.shared.currentUser,
//      "order_id": UserDefaults.standard.value(forKey: "orderID") as! String,
//      "api_version": NetworkingService.apiVersion,
//      ], encoding: JSONEncoding.default)
//      .validate(statusCode: 200..<300)
//      .responseJSON { responseJSON in
//        switch responseJSON.result {
//        case .success(let json):
//          completion(json as? [String: AnyObject], nil)
//        case .failure(let error):
//          completion(nil, error)
//        }
//    }
//  }
//  
//  func completeCharge(_ result: STPPaymentResult,
//                      amount: Int,
//                      orderID: String,
//                      completion: @escaping STPErrorBlock) {
//    let baseURL = URL(string: NetworkingService.baseURLString)!
//    let url = baseURL.appendingPathComponent("stripe/charge")
//    let params: [String: Any] = [
//      "token": NetworkingService.shared.paymentToken!,
//      "source": result.source.stripeID,
//      "amount": amount,
//      "order_id": orderID,
//      "user_id": NetworkingService.shared.currentUser
//    ]
//    Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
//      .validate(statusCode: 200..<300)
//      .responseString { response in
//        switch response.result {
//        case .success:
//          UserDefaults.standard.setValue("", forKey: "orderID")
//          completion(nil)
//        case .failure(let error):
//          completion(error)
//        }
//    }
//  }
}
