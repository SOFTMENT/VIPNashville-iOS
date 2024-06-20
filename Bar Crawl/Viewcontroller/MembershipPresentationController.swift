//
//  MembershipPresentationController.swift
//  V.I.P Nashville
//
//  Created by Apple on 25/09/22.
//

import UIKit
import StoreKit
import Firebase
import FirebaseAuth

class MembershipPresentationController: UIPresentationController{
    
    
    let blurEffectView: UIView!
    let homeVC : MainViewController?
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    var isBlurBtnSelected = false
    
    
    
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?,homeVC : MainViewController) {
        
        self.homeVC = homeVC
        
        
        blurEffectView = UIView()
        blurEffectView.backgroundColor = UIColor.clear
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissController(r:)))
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        blurEffectView.tag = 2
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
        
        
    }
    
    @objc func restoreBtnClicked(){
        dismissController(r: UITapGestureRecognizer())
            homeVC?.restorePurchase()
    }
    
    @objc func goPremiumBtnClicked() {
        
    dismissController(r: UITapGestureRecognizer())
        
        homeVC?.purchaseMembershipBtnTapped()
    }
        
    @objc func termsOfUse() {
        dismissController(r: UITapGestureRecognizer())
        guard let url = URL(string: "https://softment.in/terms-of-service/") else { return}
        UIApplication.shared.open(url)
    }
    
    @objc func privacyPolicy() {
        guard let url = URL(string: "https://softment.in/privacy-policy/") else { return}
        UIApplication.shared.open(url)
    }
   
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height - 585),
                      size: CGSize(width: self.containerView!.frame.width, height: self.containerView!.frame.height *
                                   585))
    }
    
    override func presentationTransitionWillBegin() {
        
        self.homeVC?.membershipVC.termsOfUseBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(termsOfUse)))
        
        self.homeVC?.membershipVC.privacyPolicyBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(privacyPolicy)))
        
        self.homeVC?.membershipVC.activateNowBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goPremiumBtnClicked)))
       
        self.homeVC?.membershipVC.restoreBtn.isUserInteractionEnabled = true
        self.homeVC?.membershipVC.restoreBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(restoreBtnClicked)))

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


