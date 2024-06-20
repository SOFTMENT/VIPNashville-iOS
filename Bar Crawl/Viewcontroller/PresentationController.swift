//
//  PresentationController.swift
//  V.I.P Nashville
//
//  Created by Apple on 25/09/22.
//
import UIKit
import StoreKit
import Firebase
import FirebaseAuth

class PresentationController: UIPresentationController{
    
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
    
    
    @objc func deleteAccountBtnClicked(){
        dismissController(r: UITapGestureRecognizer())
        self.homeVC?.deleteAccount()
        
    }
    
    
    
    @objc func redirecToTermsAndConditions() {
        
        dismissController(r: UITapGestureRecognizer())
        guard let url = URL(string: "https://softment.in/terms-of-service/") else { return}
        UIApplication.shared.open(url)
    }
    
    
    
    
    
    @objc func redirectToPrivacyPolicy() {
        
        dismissController(r: UITapGestureRecognizer())
        guard let url = URL(string: "https://softment.in/privacy-policy/") else { return}
        UIApplication.shared.open(url)
    }
    

    @objc func shareApp() {
        dismissController(r: UITapGestureRecognizer())
        if let name = URL(string: "https://itunes.apple.com/us/app/v-i-p-nashville/id6443530023?ls=1&mt=8"), !name.absoluteString.isEmpty {
            let objectsToShare = [name]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.homeVC!.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @objc func rateUs() {
        dismissController(r: UITapGestureRecognizer())
        if #available(iOS 14.0, *) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            
        }
        else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "6443530023") {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
        
    }
    
    @objc func adminSectionClicked(){
        dismissController(r: UITapGestureRecognizer())
        homeVC?.performSegue(withIdentifier: "adminSeg", sender: nil)
    }
    
    @objc func logout() {
        dismissController(r: UITapGestureRecognizer())
        do {
            try Auth.auth().signOut()
            homeVC?.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
        }
        catch {
            print("SignOut Error")
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height - 300 ),
                      size: CGSize(width: self.containerView!.frame.width, height: 300))
    }
    
    override func presentationTransitionWillBegin() {
        
        
        
        //PrivacyPolicy
        homeVC?.slideVC.privacyPolicy.isUserInteractionEnabled = true
        homeVC?.slideVC.privacyPolicy.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(redirectToPrivacyPolicy)))
        
        //TermsAndConditions
        homeVC?.slideVC.termsConditions.isUserInteractionEnabled = true
        homeVC?.slideVC.termsConditions.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(redirecToTermsAndConditions)))
        
        //shareapp
        homeVC?.slideVC.shareApp.isUserInteractionEnabled = true
        homeVC?.slideVC.shareApp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareApp)))
        
        //RateUs
        homeVC?.slideVC.rateApp.isUserInteractionEnabled = true
        homeVC?.slideVC.rateApp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rateUs)))
        
        //Logout
        homeVC?.slideVC.logout.isUserInteractionEnabled = true
        homeVC?.slideVC.logout.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logout)))
        
        if let data = UserData.data {
            //Name
            homeVC?.slideVC.name.text =  data.fullName
            homeVC?.slideVC.email.text = data.email
            homeVC?.slideVC.email.isHidden = false
            homeVC?.slideVC.deleteAccount.isHidden = false
            homeVC?.slideVC.logout.isHidden = false
            if UserData.data!.email == "iamvijay67@gmail.com" || UserData.data!.email ==  "maxlevel5468@gmail.com" {
                homeVC?.slideVC.adminPanelBtn.isHidden = false
            }
            else {
                homeVC?.slideVC.adminPanelBtn.isHidden = true
            }
        }
       
       
        
        homeVC?.slideVC.adminPanelBtn.isUserInteractionEnabled = true
        homeVC?.slideVC.adminPanelBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(adminSectionClicked)))
        
        homeVC?.slideVC.deleteAccount.isUserInteractionEnabled = true
        homeVC?.slideVC.deleteAccount.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(deleteAccountBtnClicked)))
        
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

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

