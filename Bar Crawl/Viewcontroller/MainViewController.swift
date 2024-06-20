//
//  ViewController.swift
//  V.I.P Nashville
//
//  Created by Apple on 24/09/22.
//

import UIKit
import FirebaseAuth
import Firebase
import RevenueCat
import FBSDKCoreKit
import GoogleMobileAds

class MainViewController : UIViewController {

    @IBOutlet weak var no_bars_available: UIStackView!
    @IBOutlet weak var midtownBtn: UIButton!
    
    @IBOutlet weak var broadwayBtn: UIButton!
    
    @IBOutlet weak var printersAllaytbn: UIButton!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mProfileBtn: UIImageView!
    
    @IBOutlet weak var locationView: UIStackView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var searchTF: UITextField!
   
    @IBOutlet weak var filterBtn: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var barItems = Array<BarModel>()
    var cityBarItems = Array<BarModel>()
    var cityBarItemsFinal = Array<BarModel>()
    var selectedCityID = 2
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    let slideVC = OverlayViewViewController()
    let membershipVC = MembershipOverlayViewController()

    var isFromLoginPage = false
    var offering : Offering?
    private var interstitial: GADInterstitialAd?
    var barModel : BarModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
       

        loadInterstitialAds()
        
        Purchases.shared.getOfferings { (offerings, error) in
            if let offer = offerings?.current, error == nil  {
                self.offering = offer
            }
                
        }
  
        mProfileBtn.isUserInteractionEnabled = true
        mProfileBtn.layer.cornerRadius = 12
        mProfileBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profilePicClicked)))
        
    
        midtownBtn.layer.cornerRadius = 8
        midtownBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
        midtownBtn.layer.borderWidth = 1
        midtownBtn.backgroundColor = UIColor.white
        
        
        printersAllaytbn.layer.cornerRadius = 8
        printersAllaytbn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
        printersAllaytbn.layer.borderWidth = 1
        printersAllaytbn.backgroundColor = UIColor.white
        
        broadwayBtn.layer.cornerRadius = 8
        broadwayBtn.backgroundColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1)
        
        if let user = UserData.data {
            nameLabel.text = "Hi \(user.fullName ?? "")"
        }
        else {
            nameLabel.text = "Bar Crawl"
        }
        
        
        searchTF.delegate = self
        searchTF.layer.cornerRadius = 8
        searchTF.layer.borderWidth = 1
        searchTF.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        searchTF.setLeftPaddingPoints(12)
        searchTF.setLeftPaddingPoints(12)
        
        searchTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
     
        filterBtn.isUserInteractionEnabled = true
        filterBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(filterBtnClicked)))
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 0
        tableView.rowHeight = 124
        tableView.isScrollEnabled = false
        
        getAllBar(filter: "AtoZ")
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        if isFromLoginPage {
            purchase()
        }
    }
    
    func loadInterstitialAds(){
        let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3746780957747656/3736352457",
                                        request: request,
                              completionHandler: { [self] ad, error in
                                if let error = error {
                                  print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                  return
                                }
                                interstitial = ad
                                interstitial?.fullScreenContentDelegate = self
                              }
            )
    }
 
    @objc func textFieldDidChange(_ textField: UITextField) {
        let query = textField.text
        if query == "" {
            cityBarItems = cityBarItemsFinal.clone()
            tableView.reloadData()
        }
        else {
            cityBarItems = cityBarItemsFinal.filter({ barModel in
                if barModel.name!.lowercased().contains(query!.lowercased()) || barModel.address!.lowercased().contains(query!.lowercased())  {
            
                    return true
                }
                return false
            })
            
            tableView.reloadData()
        }
     
    }
   
    
    func getAllBar(filter : String) {
        ProgressHUDShow(text: "Loading...")
        var query = Firestore.firestore().collection("Bars").order(by: "name")
        if filter == "Rating" {
            query = Firestore.firestore().collection("Bars").order(by: "rating",descending: true)
        }
        query.getDocuments(completion: { snapshot, error in
            self.ProgressHUDHide()
            if let error = error {
                self.showError(error.localizedDescription)
            }
            else {
                self.barItems.removeAll()
             
                if let snapshot = snapshot, !snapshot.isEmpty {
                    for qdr in snapshot.documents {
                        if let barModel = try? qdr.data(as: BarModel.self) {
                            self.barItems.append(barModel)
                        }
                    }
                }
                
                self.getDataFor(cityId: 2)
               
            }
        })
        
        
    }
    
    func getDataFor(cityId : Int) {
        self.cityBarItems.removeAll()
        self.cityBarItemsFinal.removeAll()
    
            for cityBarItem in barItems {
                if cityBarItem.cityId == cityId {
                    self.cityBarItems.append(cityBarItem)
                    
                }
            }
        
        self.cityBarItemsFinal = self.cityBarItems.clone()
        self.tableView.reloadData()
    }

    
    
    func deleteAccount(){
        let alert = UIAlertController(title: "DELETE ACCOUNT", message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            
            if let user = Auth.auth().currentUser {
                
                self.ProgressHUDShow(text: "Account Deleting...")
                let userId = user.uid
                
                        Firestore.firestore().collection("Users").document(userId).delete { error in
                           
                            if error == nil {
                                user.delete { error in
                                    self.ProgressHUDHide()
                                    if error == nil {
                                        self.logout()
                                        
                                    }
                                    else {
                                        self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
                                    }
    
                                
                                }
                                
                            }
                            else {
                       
                                self.showError(error!.localizedDescription)
                            }
                        }
                    
                }
            
            
        }))
        present(alert, animated: true)
    }

    
    
    @objc func filterBtnClicked(){
        let alert = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "A to Z", style: .default,handler: { action in
            self.getAllBar(filter: "AtoZ")
        }))
//        alert.addAction(UIAlertAction(title: "Location", style: .default,handler: { action in
//            //CODE
//        }))
        alert.addAction(UIAlertAction(title: "Rating", style: .default,handler: { action in
            self.getAllBar(filter: "Rating")
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    
    }
    
    
    
    
    
    func refreshCollectionViewHeight(){
       
    
        self.tableViewHeight.constant = CGFloat((124)) * CGFloat(cityBarItems.count)
        
    }
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
       
    }
    
    
    @objc func profilePicClicked(){
        
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        self.present(slideVC, animated: true, completion: nil)
    }
    
    
    @IBAction func midtownClicked(_ sender: Any) {
//        Purchases.shared.getCustomerInfo { (customerInfo, error) in
//            if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                self.broadwayBtn.layer.cornerRadius = 8
                self.broadwayBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
                self.broadwayBtn.layer.borderWidth = 1
                self.broadwayBtn.backgroundColor = UIColor.white
                self.broadwayBtn.setTitleColor(UIColor.black, for: .normal)
                
                self.printersAllaytbn.layer.cornerRadius = 8
                self.printersAllaytbn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
                self.printersAllaytbn.layer.borderWidth = 1
                self.printersAllaytbn.backgroundColor = UIColor.white
                self.printersAllaytbn.setTitleColor(UIColor.black, for: .normal)
                
                self.midtownBtn.layer.cornerRadius = 8
                self.midtownBtn.backgroundColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1)
                self.midtownBtn.setTitleColor(UIColor.white, for: .normal)
                
                self.getDataFor(cityId: 1)
//            }
//            else {
//                self.membershipVC.modalPresentationStyle = .custom
//                self.membershipVC.transitioningDelegate = self
//                self.present(self.membershipVC, animated: true, completion: nil)
//
//            }
            
//        }
        
        
    }
    
  
    @IBAction func broadWayClicked(_ sender: Any) {
        
        broadwayBtn.layer.cornerRadius = 8
        broadwayBtn.backgroundColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1)
        broadwayBtn.setTitleColor(UIColor.white, for: .normal)
        
        midtownBtn.layer.cornerRadius = 8
        midtownBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
        midtownBtn.layer.borderWidth = 1
        midtownBtn.backgroundColor = UIColor.white
        midtownBtn.setTitleColor(UIColor.black, for: .normal)


        printersAllaytbn.layer.cornerRadius = 8
        printersAllaytbn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
        printersAllaytbn.layer.borderWidth = 1
        printersAllaytbn.backgroundColor = UIColor.white
        printersAllaytbn.setTitleColor(UIColor.black, for: .normal)
        self.getDataFor(cityId: 2)
      
        
    }
    
    @IBAction func printersAlleyClicked(_ sender: Any) {
//        Purchases.shared.getCustomerInfo { (customerInfo, error) in
//            if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                
                self.midtownBtn.layer.cornerRadius = 8
                self.midtownBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
                self.midtownBtn.layer.borderWidth = 1
                self.midtownBtn.backgroundColor = UIColor.white
                self.midtownBtn.setTitleColor(UIColor.black, for: .normal)

                self.broadwayBtn.layer.cornerRadius = 8
                self.broadwayBtn.layer.borderColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1).cgColor
                self.broadwayBtn.layer.borderWidth = 1
                self.broadwayBtn.backgroundColor = UIColor.white
                self.broadwayBtn.setTitleColor(UIColor.black, for: .normal)

                self.printersAllaytbn.layer.cornerRadius = 8
                self.printersAllaytbn.backgroundColor = UIColor(red: 205/255, green: 8/255, blue: 75/255, alpha: 1)
                self.printersAllaytbn.setTitleColor(UIColor.white, for: .normal)
                self.getDataFor(cityId: 3)
//            }
//            else {
//                self.membershipVC.modalPresentationStyle = .custom
//                self.membershipVC.transitioningDelegate = self
//                self.present(self.membershipVC, animated: true, completion: nil)
//            }
//        }
        
       
      
 
        
    }
    
    @objc func barClicked(value : MyGesture){
        if let interstitial = interstitial{
            self.barModel = value.barModel
          interstitial.present(fromRootViewController: self)
            
        } else {
            performSegue(withIdentifier: "showBarDetailsSeg", sender: value.barModel!)
        }
       
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showBarDetailsSeg" {
            if let destination = segue.destination as? ShowBarDetailsViewController {
                if let barModel = sender as? BarModel {
                    destination.barModel = barModel
                }
            }
        }
    }
    
    func restorePurchase() {
        ProgressHUDShow(text: "Restoring...")
    
        Purchases.shared.restorePurchases { (customerInfo, error) in
            self.ProgressHUDHide()
            if customerInfo?.entitlements.all["Premium"]?.isActive == true {
                self.showSnack(messages: "Restored")
            }
            else {
                self.showSnack(messages: "There is no active subscription found")
            }
        }
    }
    
    func purchaseMembershipBtnTapped() {
            
      
            purchase()
      

    }
    
    func purchase(){
        
        if let offering = self.offering {
            if offering.availablePackages.count > 0 {
                if let firstPack =  offering.availablePackages.first {
                    self.ProgressHUDShow(text: "Purchasing...")
                    Purchases.shared.purchase(package: firstPack) { (transaction, customerInfo, error, userCancelled) in
                        self.ProgressHUDHide()
                        if !userCancelled && error == nil {
                            self.showSnack(messages: "Purchased")
                        }
                        else {
                            self.showError(error!.localizedDescription)
                        }
                    }
                    
                }
            }
            
            
        }
    }
    
}

extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cityBarItems.count > 0 {
            self.no_bars_available.isHidden = true
        }
        else {
            self.no_bars_available.isHidden = false
        }
        return cityBarItems.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "barcell", for: indexPath) as? BarTableViewCell {
            
            cell.barImage.layer.cornerRadius = 8
            cell.nextBtn.layer.cornerRadius = 8
            cell.nextBtn.dropShadow()
            
            let barModel = cityBarItems[indexPath.row]
            
            if let image = barModel.image, !image.isEmpty {
                cell.barImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"), options: .continueInBackground, completed: .none)
            }
            cell.barName.text = barModel.name ?? "Error"
            cell.barRating.text = String(format: "%.1f", barModel.rating ?? 0.0)
            cell.barAddress.text = barModel.address ?? "Error"
            cell.barDescription.text = barModel.about ?? "Error"
            cell.mView.isUserInteractionEnabled = true
            let myGest = MyGesture(target: self, action: #selector(barClicked(value:)))
            myGest.barModel = barModel
            cell.mView.addGestureRecognizer(myGest)
            
            refreshCollectionViewHeight()
            cell.layoutIfNeeded()
            
            return cell
        }
        
        return BarTableViewCell()
        
      
        
    }
    
    
    
}

extension MainViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

extension MainViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        
        if let name =  presented.nibName {
            if name == "MembershipOverlayViewController" {
                return MembershipPresentationController(presentedViewController: presented, presenting: presenting,homeVC: self)
            }

        }

        return PresentationController(presentedViewController: presented, presenting: presenting,homeVC: self)
       
 
    }

}

extension MainViewController : GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
     func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
       print("Ad did fail to present full screen content.")
     }

     /// Tells the delegate that the ad will present full screen content.
     func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       print("Ad will present full screen content.")
     }

     /// Tells the delegate that the ad dismissed full screen content.
     func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
      loadInterstitialAds()
         performSegue(withIdentifier: "showBarDetailsSeg", sender: self.barModel!)
     }
}
