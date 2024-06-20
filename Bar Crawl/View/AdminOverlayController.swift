//
//  AdminOverlayController.swift
//  V.I.P Nashville
//
//  Created by Vijay Rathore on 29/09/22.
//

import UIKit

class AdminOverlayController: UIViewController {

    @IBOutlet weak var handle: UIView!
    @IBOutlet weak var logout: UIView!
    
    @IBOutlet weak var sendPushNotification: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var mEmail: UILabel!

    @IBOutlet weak var userPanel: UIView!
    @IBOutlet weak var profilePic: UIImageView!
    
    var hasSetPointOrigin = false
    var pointOrigin: CGPoint?
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        view.addGestureRecognizer(panGesture)
        
        handle.roundCorners(.allCorners, radius: 10)
        profilePic.layer.cornerRadius = 8
        
     
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
