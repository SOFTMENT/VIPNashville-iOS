//
//  UserData.swift
//  V.I.P Nashville
//
//  Created by Apple on 25/09/22.
//

import UIKit
import Foundation


class UserData: NSObject, Codable {

    var fullName : String?
    var email : String?
    var uid : String?
    var registredAt : Date?
    var regiType : String?
    var isAdmin : Bool?
    var expireDate : Date?

    private static var userData : UserData?
     
      static var data : UserData? {
          set(userData) {
              self.userData = userData
          }
          get {
              return userData
          }
      }

      override init() {
          
      }
}

