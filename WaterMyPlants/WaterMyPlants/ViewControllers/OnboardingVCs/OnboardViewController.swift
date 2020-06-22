//
//  OnboardViewController.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase



//Helper enum
enum LoginType {
    case signUp
    case signIn
}

@IBDesignable class OnboardViewController: UIViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var signUpSignInLabel: UILabel!
    @IBOutlet weak var createAccountLabel: UILabel!
    @IBOutlet weak var signUpSignInSegmentedControl: UISegmentedControl!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var greyView1: UIView!
    @IBOutlet weak var greyView2: UIView!
    
    //MARK: -Properties
    var selectedLoginType: LoginType = .signIn {
        didSet {
            
            switch selectedLoginType {
                
            case .signUp:
                
                signUpSignInLabel.text = "Sign In"
                signUpSignInLabel.fadeIn()
                createAccountLabel.text = "Welcome Back"
                createAccountLabel.fadeIn()
                phoneNumberTextField.isHidden = false
                
            case .signIn:
                
                signUpSignInLabel.fadeOut()
                signUpSignInLabel.text = "Sign Up"
                signUpSignInLabel.fadeIn()
                createAccountLabel.fadeOut()
                createAccountLabel.text = "Create Account"
                createAccountLabel.fadeIn()
                phoneNumberTextField.fadeOut()
            }
        }
    }
    
    //MARK: -View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Styling
        usernameTextField.addBottomBorder()
        passwordTextField.addBottomBorder()
        phoneNumberTextField.addBottomBorder()
        greyView1.layer.cornerRadius = 15.0
        greyView2.layer.cornerRadius = 15.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        signUpSignInLabel.fadeIn()
        createAccountLabel.fadeIn()
        
    }
    
    @IBAction func signUpSignInSegmentedAction(_ sender: UISegmentedControl) {
        switch signUpSignInSegmentedControl.selectedSegmentIndex {
            
        case 0:
            
            selectedLoginType = .signIn
            passwordTextField.textContentType = .password
            phoneNumberTextField.isHidden = false
            
        default:
            
            selectedLoginType = .signUp
            passwordTextField.textContentType = .newPassword
            phoneNumberTextField.isHidden = true
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            
            let userName = self.usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = self.passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: userName, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    print("Error Authenticating User")
                }
                else {
                    
                    // User was created successfully, now store the phonenumber and password
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["username":userName, "password":password, "uid": result!.user.uid ]) { (error) in
                        
                        if error != nil {
                            // Show error message
                            print("Error creating user: \(String(describing: err?.localizedDescription))")
                        }
                    }
                    
                    // Transition to the home screen
                    self.transitionToHome()
                }
                
            }
            
        }
        
    }
    
    //MARK: - Class Funcs
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            phoneNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    
    func transitionToHome() {
        
        let homeViewController = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeVC
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
        
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}

extension OnboardViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = self.view.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
}

extension UIView {
    func fadeIn(
        _ duration: TimeInterval = 1.0,
        delay: TimeInterval = 0.0,
        completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(
        _ duration: TimeInterval = 1.0,
        delay: TimeInterval = 0.0,
        completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
