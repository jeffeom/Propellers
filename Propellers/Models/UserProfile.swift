//
//  UserProfile.swift
//  Propellers
//
//  Created by Jeff Eom on 2017-11-27.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import UIKit
import Firebase

class UserProfile: NSObject {
  var key: String?
  var about: String?
  var projects: [Project]?
  var skills: String?
  var ref: DatabaseReference?
  
  init?(snapshot: DataSnapshot) {
    guard let snapshotValue = snapshot.value as? [String:AnyObject] else { return nil }
    key = snapshot.key
    about = snapshotValue["about"] as? String
    guard let projectsDict = snapshotValue["projects"] as? [String: [String: AnyObject]] else { return }
    projects = []
    for aKey in projectsDict.keys {
      guard let aProject = projectsDict[aKey] else { return nil }
      let projectFetched = Project(data: aProject, withKey: aKey)
      self.projects?.append(projectFetched)
    }
    skills = snapshotValue["skills"] as? String
    ref = snapshot.ref
  }
  
  init(about: String, projects: [Project]?, skills: String?) {
    self.about = about
    self.projects = projects
    self.skills = skills
  }
  
  func json() -> [String:Any]? {
    return ["about": about ?? "", "projects": projects ?? [], "skills": skills ?? ""] as [String : AnyObject]
  }
}
