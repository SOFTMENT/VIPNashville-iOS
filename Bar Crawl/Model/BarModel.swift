//
//  BarModel.swift
//  V.I.P Nashville
//
//  Created by Vijay Rathore on 29/09/22.
//

import UIKit

class BarModel : NSObject, Codable,Copying {
    override init() {
        
    }
    
    required init(original: BarModel) {
        id = original.id
        image = original.image
        name = original.name
        rating = original.rating
        address = original.address
        about = original.about
        createDate = original.createDate
        webUrl = original.webUrl
        cityId = original.cityId
        latitude = original.latitude
        longitude = original.longitude
    }
    
    
    var id : String?
    var image : String?
    var name : String?
    var rating : Double?
    var address : String?
    var about : String?
    var createDate : Date?
    var webUrl : String?
    var cityId : Int?
    var latitude : Double?
    var longitude : Double?
    
}





