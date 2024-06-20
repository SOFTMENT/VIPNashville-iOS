//
//  Extensions.swift
//  V.I.P Nashville
//
//  Created by Apple on 25/09/22.
//

//
//  MyExtensions.swift
//  eventkreyol
//
//  Created by Vijay Rathore on 18/07/21.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase
import MBProgressHUD
import TTGSnackbar
import GoogleSignIn
import FirebaseAuth

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        
        self.rightView = paddingView
        self.rightViewMode = .always
        
    }
    
    func changePlaceholderColour()  {
        attributedPlaceholder = NSAttributedString(string: placeholder ?? "",
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)])
    }
    
    func addBorder() {
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1).cgColor
        setLeftPaddingPoints(10)
        setRightPaddingPoints(10)
    }
    
    
    /// set icon of 20x20 with left padding of 8px
    func setLeftIcons(icon: UIImage) {
        
        let padding = 8
        let size = 20
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always
    }
    
    
    
    
    /// set icon of 20x20 with left padding of 8px
    func setRightIcons(icon: UIImage) {
        
        let padding = 8
        let size = 12
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: -padding, y: 0, width: size, height: size))
        iconView.image = icon
        outerView.addSubview(iconView)
        
        rightView = outerView
        rightViewMode = .always
    }
    
}








extension Date {
    
    
    func removeTimeStamp() -> Date? {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: self)) else {
            return  nil
        }
        return date
    }
    
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "year ago" : "\(interval)" + " " + "years ago"
        }
        
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "month ago" : "\(interval)" + " " + "months ago"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "day ago" : "\(interval)" + " " + "days ago"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "hour ago" : "\(interval)" + " " + "hours ago"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "minute ago" : "\(interval)" + " " + "minutes ago"
        }
        
        return "a moment ago"
    }
}



extension UIViewController {
    
    
    public func logout(){
        do {
            try Auth.auth().signOut()
            self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
        }
        catch {
            self.beRootScreen(mIdentifier: Constants.StroyBoard.signInViewController)
        }
    }
    
    func loginWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                self.showError(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            self.authWithFirebase(credential: credential,type: "google", displayName: "")
            
        }
    }
    
    func showSnack(messages : String) {
        
        
        let snackbar = TTGSnackbar(message: messages, duration: .long)
        snackbar.messageLabel.textAlignment = .center
        snackbar.show()
    }
    
    func ProgressHUDShow(text : String) {
        let loading = MBProgressHUD.showAdded(to: self.view, animated: true)
        loading.mode = .indeterminate
        loading.label.text =  text
        loading.label.font = UIFont(name: "RobotoCondensed-Regular", size: 11)
    }
    
    func ProgressHUDHide(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    
    
    
    func sentVerificationEmail(){
        self.ProgressHUDShow(text: "")
        Auth.auth().currentUser!.sendEmailVerification { error in
            self.ProgressHUDHide()
            if error == nil {
                self.showMessage(title: "Verify Your Email", message: "We have sent verification mail on your email address. Please verify your email address before Sign In.",shouldDismiss: true)
            }
            else {
                self.showError(error!.localizedDescription)
            }
        }
    }
    
    
    func addUserData(user : UserData, type : String) {
        
        ProgressHUDShow(text: "")
        
        try? Firestore.firestore().collection("Users").document(user.uid!).setData(from: user) { (error) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            if error != nil {
                self.showError(error!.localizedDescription)
            }
            else {
                
                if type == "custom" {
                    if let user = Auth.auth().currentUser {
                        if user.isEmailVerified {
                            self.getUserData(uid: user.uid, showProgress: true)
                        }
                        else {
                            self.sentVerificationEmail()
                        }
                        
                    }
                }
                else {
                    self.getUserData(uid: user.uid!, showProgress: true)
                }
            }
            
        }
    }
    
    func membershipDaysLeft(currentDate : Date, expireDate : Date) -> Int {
        
        
        
        return Calendar.current.dateComponents([.day], from: currentDate, to: expireDate).day ?? 0
        
        
    }
    
    
    func getUserData(uid : String, showProgress : Bool)  {
        if showProgress {
            ProgressHUDShow(text: "")
        }
        
        Firestore.firestore().collection("Users").document(uid).getDocument { (snapshot, error) in
            
            
            if error != nil {
                if showProgress {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                self.showError(error!.localizedDescription)
            }
            else {
                
                if let snapshot = snapshot, snapshot.exists {
                    
                    
                    
                    if let user = try? snapshot.data(as: UserData.self) {
                        UserData.data = user
                        if showProgress {
                            self.performSegue(withIdentifier: "homeSeg", sender: nil)
                        }
                        else {
                            self.beRootScreen(mIdentifier: Constants.StroyBoard.homeViewController)
                        }
                     
                    }
                    else {
                        self.showError("Something went wrong, User not found")
                        
                    }
     
                    
                }
                else {
                    self.showError("Something went wrong, User not found")
                }
            }
        }
    }
    
    
    
    func navigateToAnotherScreen(mIdentifier : String)  {
        
        let destinationVC = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
        destinationVC.modalPresentationStyle = .fullScreen
        present(destinationVC, animated: true) {
            
        }
    }
    
    
    func getViewControllerUsingIdentifier(mIdentifier : String) -> UIViewController{
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        switch mIdentifier {
        case Constants.StroyBoard.signInViewController:
            return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? SignInViewController)!
            
        case Constants.StroyBoard.homeViewController:
            return (mainStoryboard.instantiateViewController(identifier: mIdentifier) as? MainViewController)!
            
            
        default:
            return (mainStoryboard.instantiateViewController(identifier: Constants.StroyBoard.homeViewController) as? MainViewController)!
        }
    }
    
    func beRootScreen(mIdentifier : String) {
        
        guard let window = self.view.window else {
            self.view.window?.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
            self.view.window?.makeKeyAndVisible()
            return
        }
        
        window.rootViewController = getViewControllerUsingIdentifier(mIdentifier: mIdentifier)
        window.makeKeyAndVisible()
        UIView.transition(with: window,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: nil,
                          completion: nil)
        
    }
    
    func convertDateToMonthFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    
    func convertDateAndTimeFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    func convertDateFormaterWithoutDash(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "dd MMM yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    func convertDateFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "dd-MMM-yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    func convertDateFormaterWithSlash(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    func convertDateForHomePage(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "EEEE, dd MMMM"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    func convertDateForVoucher(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "E, MMM dd  yyyy • hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    func convertDateForTicket(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "E,MMM dd, yyyy hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
    
    
    func convertDateIntoTimeForRecurringVoucher(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return "\(df.string(from: date))"
        
        
    }
    
    
    
    func convertDateIntoMonthAndYearForRecurringVoucher(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "MMM • yyyy"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return "\(df.string(from: date))"
        
    }
    
    func convertDateIntoDayForRecurringVoucher(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return "\(df.string(from: date))"
        
    }
    
    func convertDateIntoDayDigitForRecurringVoucher(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "d"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return "\(df.string(from: date))"
        
    }
    
    
    func convertTimeFormater(_ date: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.timeZone = TimeZone.current
        return df.string(from: date)
        
    }
    
  
    
    func showError(_ message : String) {
        let alert = UIAlertController(title: "ERROR", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showMessage(title : String,message : String, shouldDismiss : Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok",style: .default) { action in
            if shouldDismiss {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func authWithFirebase(credential : AuthCredential, type : String,displayName : String) {
        
        ProgressHUDShow(text: "")
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error != nil {
                
                self.showError(error!.localizedDescription)
            }
            else {
                let user = authResult!.user
                let ref =  Firestore.firestore().collection("Users").document(user.uid)
                ref.getDocument { (snapshot, error) in
                    if error != nil {
                        self.showError(error!.localizedDescription)
                    }
                    else {
                        if let doc = snapshot {
                            if doc.exists {
                                self.getUserData(uid: user.uid, showProgress: true)
                                
                            }
                            else {
                                
                            
                                var emailId = ""
                                let provider =  user.providerData
                                var name = ""
                                for firUserInfo in provider {
                                    if let email = firUserInfo.email {
                                        emailId = email
                                    }
                                }
                                
                                if type == "apple" {
                                    name = displayName
                                }
                                else {
                                    name = user.displayName!.capitalized
                                }
                                
                                
                                let userData = UserData()
                                userData.uid = user.uid
                                userData.fullName = name
                                userData.email = emailId
                                userData.registredAt = user.metadata.creationDate!
                                userData.regiType = type
                                
                                self.addUserData(user: userData, type: type)
                            }
                        }
                        
                    }
                }
                
            }
            
        }
    }
    
}









extension UIImageView {
    func makeRounded() {
        
        //self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        // self.layer.borderColor = UIColor.gray.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        
    }
    
    
    
    
}



extension UIView {
    
    func smoothShadow(){
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 5
        //        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func addBottomShadow() {
        layer.masksToBounds = false
        layer.shadowRadius = 2
        layer.shadowOpacity = 0.3
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0 , height: 1.8)
        layer.shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                     y: bounds.maxY - layer.shadowRadius,
                                                     width: bounds.width,
                                                     height: layer.shadowRadius)).cgPath
    }
    
    
    
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = .zero
        layer.shadowRadius = 2
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
  
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}



extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}


extension URL {
    static let timeIP = URL(string: "http://worldtimeapi.org/api/ip")!
    static func asyncTime(completion: @escaping ((Date?, TimeZone?, Error?)-> Void)) {
        URLSession.shared.dataTask(with: .timeIP) { data, response, error in
            guard let data = data else {
                completion(nil, nil, error)
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                let root = try decoder.decode(Root.self, from: data)
                completion(root.unixtime, TimeZone(identifier: root.timezone), nil)
            } catch {
                completion(nil, nil, error)
            }
        }.resume()
    }
}

protocol Copying {
    init(original: Self)
}

//Concrete class extension
extension Copying {
    func copy() -> Self {
        return Self.init(original: self)
    }
}

//Array extension for elements conforms the Copying protocol
extension Array where Element: Copying {
    func clone() -> Array {
        var copiedArray = Array<Element>()
        for element in self {
            copiedArray.append(element.copy())
        }
        return copiedArray
    }
}
