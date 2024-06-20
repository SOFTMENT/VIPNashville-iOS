//
//  SignViewController.swift
//  V.I.P Nashville
//
//  Created by Apple on 24/09/22.
//

import UIKit
import AuthenticationServices
import CryptoKit
import Firebase
import FirebaseAuth

class SignInViewController : UIViewController {
    
    @IBOutlet weak var backBtn: UIView!
    @IBOutlet weak var mLogo: UIImageView!
    @IBOutlet weak var signInWithGoogleBtn: UIView!
    @IBOutlet weak var signinWithAppleBtn: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var resetBtn: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var registerBtn: UILabel!
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        
        
        
        backBtn.isUserInteractionEnabled = true
        backBtn.dropShadow()
        backBtn.layer.cornerRadius = 8
        backBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
        mLogo.layer.cornerRadius = 16
        
        signInWithGoogleBtn.isUserInteractionEnabled = true
        signInWithGoogleBtn.layer.cornerRadius = 8
        
        signinWithAppleBtn.isUserInteractionEnabled = true
        signinWithAppleBtn.layer.cornerRadius = 8
        
        signInWithGoogleBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(googleBtnClicked)))
        signinWithAppleBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(appleBtnClicked)))
        
        resetBtn.isUserInteractionEnabled = true
        registerBtn.isUserInteractionEnabled = true
        
        resetBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resetBtnClicked)))
        registerBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(registerBtnClicked)))
        
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
        continueBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signInBtnClicked)))
        
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    
    
    @objc func signInBtnClicked(){
        let sEmail = emailTF.text?.trimmingCharacters(in: .nonBaseCharacters)
        let sPassword = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sEmail == "" {
            showSnack(messages: "Enter Email Address")
        }
        else if sPassword == "" {
            showSnack(messages: "Enter Password")
        }
        else {
            ProgressHUDShow(text: "")
            Auth.auth().signIn(withEmail: sEmail!, password: sPassword!) { authResult, error in
                self.ProgressHUDHide()
                if error == nil {
                    
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
                    self.showError(error!.localizedDescription)
                }
            }
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeSeg" {
            if let dest = segue.destination as? MainViewController {
                dest.isFromLoginPage = true
            }
        }
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    
    @objc func googleBtnClicked(){
        self.loginWithGoogle()
        
    }
    
    @objc func appleBtnClicked(){
        self.startSignInWithAppleFlow()
    }
    
    @objc func resetBtnClicked(){
        let sEmail = emailTF.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sEmail == "" {
            showSnack(messages: "Enter Email Address")
        }
        else {
            ProgressHUDShow(text: "")
            Auth.auth().sendPasswordReset(withEmail: sEmail!) { error in
                self.ProgressHUDHide()
                if error == nil {
                    self.showMessage(title: "RESET PASSWORD", message: "We have sent reset password link on your mail address.", shouldDismiss: false)
                }
                else {
                    self.showError(error!.localizedDescription)
                }
            }
        }
    }
    
    @objc func registerBtnClicked(){
        self.performSegue(withIdentifier: "registerSeg", sender: nil)
    }
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        // authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
   
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    
}


extension SignInViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
}


extension SignInViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            
            var displayName = "V.I.P Nashville"
            if let fullName = appleIDCredential.fullName {
                if let firstName = fullName.givenName {
                    displayName = firstName
                }
                if let lastName = fullName.familyName {
                    displayName = "\(displayName) \(lastName)"
                }
            }
            
            authWithFirebase(credential: credential, type: "apple",displayName: displayName)
            // User is signed in to Firebase with Apple.
            // ...
            
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        
        print("Sign in with Apple errored: \(error)")
    }
    
}

