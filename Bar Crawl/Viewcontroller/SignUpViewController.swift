//
//  SignUpController.swift
//  V.I.P Nashville
//
//  Created by Apple on 24/09/22.
//


import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mLogo: UIImageView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var loginBtn: UILabel!
    
    override func viewDidLoad() {
        
        mLogo.layer.cornerRadius = 16
        
    
        backView.isUserInteractionEnabled = true
        backView.dropShadow()
        backView.layer.cornerRadius = 8
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
       
        loginBtn.isUserInteractionEnabled = true
        loginBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signInBtnClicked)))
        
        nameTF.layer.cornerRadius = 8
        nameTF.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        nameTF.layer.borderWidth = 1.4
        nameTF.setLeftPaddingPoints(12)
        nameTF.setRightPaddingPoints(12)
        nameTF.delegate = self
        
        emailTF.layer.cornerRadius = 8
        emailTF.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        emailTF.layer.borderWidth = 1.4
        emailTF.setLeftPaddingPoints(12)
        emailTF.setRightPaddingPoints(12)
        emailTF.delegate = self
        
        passwordTF.layer.cornerRadius = 8
        passwordTF.layer.borderColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1).cgColor
        passwordTF.layer.borderWidth = 1.4
        passwordTF.setLeftPaddingPoints(12)
        passwordTF.setRightPaddingPoints(12)
        passwordTF.delegate = self
        
        continueBtn.isUserInteractionEnabled = true
        continueBtn.layer.cornerRadius = 8
        continueBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(registerBtnClicked)))
        
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
    }
    
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func signInBtnClicked(){
        self.dismiss(animated: true)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    
    @objc func registerBtnClicked(){
        let sFullName = nameTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sEmail =    emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sPassword = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sFullName == "" {
            showSnack(messages: "Enter Full Name")
        }
        else if sEmail == "" {
            showSnack(messages: "Enter Email")
        }
        else if sPassword  == "" {
            showSnack(messages: "Enter Password")
        }
        else {
            ProgressHUDShow(text: "Creating Account...")
            Auth.auth().createUser(withEmail: sEmail!, password: sPassword!) { result, error in
                self.ProgressHUDHide()
                if error == nil {
                    
                    let userData = UserData()
                    userData.uid = Auth.auth().currentUser!.uid
                    userData.fullName = sFullName ?? "VIP Nashville"
                    userData.email = sEmail ?? "support@nashville.com"
                    userData.registredAt = Date()
                    userData.regiType = "custom"
                    self.addUserData(user: userData, type: "custom")
                    
               
                }
                else {
                    self.showError(error!.localizedDescription)
                }
            }
        }
        
       
    }
    
}


extension SignUpViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}

    


