//
//  AsyncPhotoMediaItem.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-06.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import Foundation
import JSQMessagesViewController
import SDWebImage

class AsyncPhotoMediaItem: JSQPhotoMediaItem {
  var asyncImageView: UIImageView!
  
  override init!(maskAsOutgoing: Bool) {
    super.init(maskAsOutgoing: maskAsOutgoing)
  }
  
  init(withURL url: URL) {
    super.init()
    asyncImageView = UIImageView()
    asyncImageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
    asyncImageView.contentMode = .scaleAspectFill
    asyncImageView.clipsToBounds = true
    asyncImageView.layer.cornerRadius = 20
    asyncImageView.backgroundColor = UIColor.jsq_messageBubbleLightGray()
    
    let activityIndicator = JSQMessagesMediaPlaceholderView.withActivityIndicator()
    activityIndicator?.frame = asyncImageView.frame
    asyncImageView.addSubview(activityIndicator!)
    
    asyncImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "userPlaceHolder"), options: [], completed: { (image, error, cacheType, imageURL) in
      if (error == nil) {
        activityIndicator?.removeFromSuperview()
      }
    })
  }
  
  override func mediaView() -> UIView! {
    return asyncImageView
  }
  
  override func mediaViewDisplaySize() -> CGSize {
    return asyncImageView.frame.size
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
