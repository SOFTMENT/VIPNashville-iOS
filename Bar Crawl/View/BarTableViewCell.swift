//
//  BarTableViewCell.swift
//  V.I.P Nashville
//
//  Created by Apple on 25/09/22.
//

import UIKit

class BarTableViewCell : UITableViewCell {
    
    
    @IBOutlet weak var mView: UIView!
    
    @IBOutlet weak var barImage: UIImageView!
    
    @IBOutlet weak var barName: UILabel!
    
    @IBOutlet weak var barRating: UILabel!
    
    @IBOutlet weak var barAddress: UILabel!
    
    
    @IBOutlet weak var barDescription: UILabel!
    
    @IBOutlet weak var nextBtn: UIView!
    
    
    override class func awakeFromNib() {
        
    }
    
}
