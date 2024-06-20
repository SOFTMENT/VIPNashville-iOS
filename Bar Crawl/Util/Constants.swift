//
//  Constant.swift
//  V.I.P Nashville
//
//  Created by Apple on 25/09/22.
//


import Foundation
import UIKit
import CoreLocation

struct Constants {
   
    
    struct StroyBoard {
        
        static let signInViewController = "signInVC"
        static let homeViewController = "mainVC"
       
    }
    
    static var clLocation : CLLocation?
    var cities: [Int : String] = [1: "Midtown", 2 : "Broadway", 3 : "Printers Alley"]
    public static var currentDate : Date = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!

}

