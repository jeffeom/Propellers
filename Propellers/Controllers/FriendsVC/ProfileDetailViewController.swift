//
//  ProfileDetailViewController.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-27.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import TagListView

protocol ProjectCellDelegate: class {
  func tappedOnFavorite(cell:ProjectCell)
}

class ProjectCell: UICollectionViewCell {
  static let identifier = "projectCell"
  @IBOutlet weak var contentShadowView: UIView!
  @IBOutlet weak var cellContentView: UIView!
  @IBOutlet weak var projectImage: UIImageView!
  @IBOutlet weak var projectTitleLabel: UILabel!
  @IBOutlet weak var projectTypeLabel: UILabel!
  @IBOutlet weak var starImageView: UIImageView!
  @IBOutlet weak var favoriteLabel: UILabel!
  @IBOutlet weak var favoriteStackView: UIStackView!
  
  var isFavorited: Bool = false {
    didSet {
      if isFavorited {
        starImageView.image = #imageLiteral(resourceName: "likeSelectedButtonSm")
      }else {
        starImageView.image = #imageLiteral(resourceName: "likeUnselectedButtonSm")
      }
    }
  }
  
  weak var projectCellDelegate: ProjectCellDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    createShadow()
    let tg = UITapGestureRecognizer(target: self, action: #selector(didTapFavorite))
    favoriteStackView.isUserInteractionEnabled = true
    favoriteStackView.addGestureRecognizer(tg)
  }
  
  func createShadow() {
    contentShadowView.backgroundColor = .clear
    contentShadowView.layer.shadowColor = UIColor.black.cgColor
    contentShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
    contentShadowView.layer.shadowOpacity = 0.2
    contentShadowView.layer.shadowRadius = 2
    
    cellContentView.backgroundColor = UIColor.white
    cellContentView.layer.cornerRadius = 8
    cellContentView.clipsToBounds = true
  }
  
  @objc func didTapFavorite() {
    if !isFavorited {
      favoriteLabel.text = "\(Int(favoriteLabel.text!)! + 1)"
    }else {
      favoriteLabel.text = "\(Int(favoriteLabel.text!)! - 1)"
    }
    isFavorited = !isFavorited
    projectCellDelegate?.tappedOnFavorite(cell:self)
  }
}

class ProfileDetailViewController: UIViewController {
  static let identifier = "profileVC"
  @IBOutlet weak var projectCollectionView: UICollectionView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var aboutTextView: UITextView!
  @IBOutlet weak var aboutTextViewHeight: NSLayoutConstraint!
  @IBOutlet weak var skillsTagListView: TagListView!
  
  var user: String?
  var projects: [Project]?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupDelegates()
    appearance()
    fetchProfileData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.tabBar.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.tabBar.isHidden = false
  }
}

//MARK: Setup
extension ProfileDetailViewController {
  func setupDelegates() {
    projectCollectionView.delegate = self
    projectCollectionView.dataSource = self
  }
  
  func appearance() {
    userImageView.layer.cornerRadius = userImageView.bounds.height / 2
    userImageView.clipsToBounds = true
    skillsTagListView.textFont = UIFont(name: "AvenirNext-Medium", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .medium)
  }
  
  func textViewAppearance() {
    aboutTextView.isScrollEnabled = false
    aboutTextView.textContainer.maximumNumberOfLines = 0
    aboutTextView.textContainerInset = UIEdgeInsets.zero
    aboutTextView.textContainer.lineFragmentPadding = 0
    guard let expandedSize = aboutTextView.font?.sizeOfString(string: aboutTextView.text, constrainedToWidth: Double(self.aboutTextView.bounds.width)) else { return }
    self.aboutTextView.frame.size = CGSize(width: expandedSize.width, height: expandedSize.height)
    self.aboutTextViewHeight.constant = expandedSize.height
  }
}

//MARK: NetworkingService
extension ProfileDetailViewController {
  func fetchProfileData() {
    guard let user = user else {
      navigationController?.popViewController(animated: true)
      return
    }
    guard !user.isEmpty else {
      navigationController?.popViewController(animated: true)
      return
    }
    NetworkingService.shared.fetchProfileForFriend(withUID: user) { (profile) in
      NetworkingService.shared.fetchUser(withUID: user, completion: { (user) in
        self.userNameLabel.text = user?.fullName
        self.userImageView.sd_setImage(with: URL(string: user?.imageURL ?? ""))
        self.aboutTextView.text = profile?.about ?? ""
        self.skillsTagListView.addTags(profile?.skills?.components(separatedBy: ";") ?? [])
        self.projects = profile?.projects ?? []
        self.textViewAppearance()
        self.projectCollectionView.reloadData()
      })
    }
  }
}

//MARK: ProjectCellDelegate
extension ProfileDetailViewController: ProjectCellDelegate {
  func tappedOnFavorite(cell: ProjectCell) {
    print("favorited")
    guard let user = user else { return }
    guard let projectIP = projectCollectionView.indexPath(for: cell) else { return }
    guard let projects = projects else { return }
    let project = projects[projectIP.item]
    NetworkingService.shared.markFavorite(withUID: user, projectKey: project.key!) {}
  }
}

//MARK: CollectionViewDelegate
extension ProfileDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let projects = projects else { return 0 }
    return projects.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectCell.identifier, for: indexPath) as! ProjectCell
    let theProject = projects![indexPath.item]
    
    cell.projectCellDelegate = self
    cell.projectImage.sd_setImage(with: URL(string: theProject.imageURL ?? ""))
    cell.projectTitleLabel.text = theProject.title ?? ""
    cell.projectTypeLabel.text = theProject.type ?? ""
    cell.favoriteLabel.text = "\(theProject.favoriteCount)"
    cell.isFavorited =  theProject.favorite?.keys.contains(NetworkingService.shared.currentUID) ?? false
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.width / 2 - 5, height: 200)
  }
}

//MARK: IBAction
extension ProfileDetailViewController {
  @IBAction func didPressButtonToChat(_ sender: UIButton) {
    guard let user = user else { return }
    NetworkingService.shared.createRoom(withUid: user) { (chatInfo) in
      let chatVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "newChatVC") as! NewChatViewController
      chatVC.room = chatInfo?.room
      self.navigationController?.pushViewController(chatVC, animated: true)
    }
  }
}