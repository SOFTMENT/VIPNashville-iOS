//
//  WelcomeViewController.swift
//  V.I.P Nashville
//
//  Created by Apple on 24/09/22.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Firebase

class WelcomeViewController: UIViewController {
   
    let userDefaults = UserDefaults.standard
    
    
    
    override func viewDidLoad() {
        
        //SUBSCRIBE TO TOPIC
        Messaging.messaging().subscribe(toTopic: "vipnashville"){ error in
            if error == nil{
                print("Subscribed to topic")
            }
            else{
                print("Not Subscribed to topic")
            }
        }
        
        
        if userDefaults.value(forKey: "appFirstTimeOpend") == nil {
            //if app is first time opened then it will be nil
            userDefaults.setValue(true, forKey: "appFirstTimeOpend")
            // signOut from FIRAuth
            do {
                try Auth.auth().signOut()
            }catch {

            }
            // go to beginning of app
        }
        

      
        
        if Auth.auth().currentUser != nil {
                 
            Auth.auth().currentUser!.getIDTokenResult(forcingRefresh: true) { result, error in
                if error == nil {
                    if let result = result {
                        
                        print(result.signInProvider)
                        if result.signInProvider == "password"  {
                       if Auth.auth().currentUser!.isEmailVerified {
                          
                           self.getUserData(uid: Auth.auth().currentUser!.uid,showProgress: false)
                       }
                       else {
                           
                           self.gotoSignInViewController()
                       }
                      
                    }
                    else {
                        
                      self.getUserData(uid: Auth.auth().currentUser!.uid,showProgress: false)
                    }
                    
                    
                }
                
                }
            else {
                self.getUserData(uid: Auth.auth().currentUser!.uid,showProgress: false)
            }
            }
            }
                else {
         
               self.gotoSignInViewController()
            
        }
             
          
        
               
    }
    
    func gotoSignInViewController(){
        DispatchQueue.main.async {
            self.beRootScreen(mIdentifier: Constants.StroyBoard.homeViewController)
        }
    }
    
}
