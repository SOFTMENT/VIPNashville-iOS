//
//  OverlayViewViewController.swift
//  V.I.P Nashville
//
//  Created by Apple on 25/09/22.
//

import UIKit

class OverlayViewViewController : UIViewController {
    
    @IBOutlet weak var adminPanelBtn: UIButton!
    
    @IBOutlet weak var slide: UIView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var shareApp: UIView!
    @IBOutlet weak var rateApp: UIView!
    @IBOutlet weak var privacyPolicy: UIView!
    @IBOutlet weak var termsConditions: UIView!
    @IBOutlet weak var logout: UIView!
    @IBOutlet weak var deleteAccount: UIView!
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        logo.layer.cornerRadius = 8
        
        adminPanelBtn.layer.cornerRadius = 8
        adminPanelBtn.dropShadow()
        
       
        
        slide.roundCorners(corners: .allCorners, radius: 10)
        deleteAccount.layer.cornerRadius = 8
        deleteAccount.layer.borderWidth = 1.2
        deleteAccount.layer.borderColor = UIColor.red.cgColor
    }
    
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        // Not allowing the user to drag the view upward
        guard translation.y >= 0 else { return }
        
        // setting x as 0 because we don't want users to move the frame side ways!! Only want straight up or down
         view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
    
        if sender.state == .ended {
            let dragVelocity = sender.velocity(in: view)
            if dragVelocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                // Set back to original position of the view controller
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
}

