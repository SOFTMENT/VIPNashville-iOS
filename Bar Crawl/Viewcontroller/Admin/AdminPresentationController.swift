//
//  File.swift
//  V.I.P Nashville
//
//  Created by Vijay Rathore on 29/09/22.
//

import UIKit
import StoreKit
import Firebase
import FirebaseAuth

class AdminPresentationController : UIPresentationController{
    
    let blurEffectView: UIView!
    let adminDashboardVC : AdminDashboardConroller?
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    var isBlurBtnSelected = false
    
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?,adminVC : AdminDashboardConroller) {
        
        self.adminDashboardVC = adminVC
        
        
        blurEffectView = UIView()
        blurEffectView.backgroundColor = UIColor.clear
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissController(r:)))
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        blurEffectView.tag = 2
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    
    @objc func userPanelClicked(){
        dismissController(r: UITapGestureRecognizer())
        adminDashboardVC?.dismiss(animated: true)
        
    }
    
    @objc func pusNotificationClicked(){
        adminDashboardVC?.showSnack(messages: "Coming Soon...")
    }
    
    @objc func logout() {
        dismissController(r: UITapGestureRecognizer())
        do {
            try Auth.auth().signOut()
            adminDashboardVC?.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
        }
        catch {
            print("SignOut Error")
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height * 0.67 ),
                      size: CGSize(width: self.containerView!.frame.width, height: self.containerView!.frame.height *
                                   0.33))
    }
    
    override func presentationTransitionWillBegin() {
        
        
        
   
        //Logout
        adminDashboardVC?.slideVC.logout.isUserInteractionEnabled = true
        adminDashboardVC?.slideVC.logout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logout)))
        
        adminDashboardVC?.slideVC.userPanel.isUserInteractionEnabled = true
        adminDashboardVC?.slideVC.userPanel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userPanelClicked)))
        
        
        adminDashboardVC?.slideVC.sendPushNotification.isUserInteractionEnabled = true
        adminDashboardVC?.slideVC.sendPushNotification.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pusNotificationClicked)))
        
        
        //Name
        adminDashboardVC?.slideVC.name.text = UserData.data?.fullName
        adminDashboardVC?.slideVC.mEmail.text = UserData.data?.email
        
        
        
        self.containerView?.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in })
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
            
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) in
            self.blurEffectView.removeFromSuperview()
            if !self.isBlurBtnSelected {
                self.dismissController(r: UITapGestureRecognizer())
            }
            
            
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners([.topLeft, .topRight], radius: 50)
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurEffectView.frame = containerView!.bounds
    }
    
    @objc  func dismissController(r : UITapGestureRecognizer){
        if r.view?.tag == 2 {
            isBlurBtnSelected = true
        }
        else {
            isBlurBtnSelected = false
        }
        
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}


