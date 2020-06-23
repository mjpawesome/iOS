//
//  OnboardViewController.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit

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
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK: -Properties
    
    var plantController: PlantController?
    
    var selectedLoginType: LoginType = .signIn {
        
        didSet {
            
            switch selectedLoginType {
                
            case .signUp:
                
                signUpSignInLabel.fadeOut()
                signUpSignInLabel.text = "Sign Up"
                signUpSignInLabel.fadeIn()
                createAccountLabel.fadeOut()
                createAccountLabel.text = "Create Account"
                createAccountLabel.fadeIn()
                phoneNumberTextField.isHidden = false
                phoneNumberTextField.fadeIn()
                phoneNumberTextField.isHidden = false
                signUpButton.isHidden = false
                signInButton.isHidden = true
                
            case .signIn:
                
                signUpSignInLabel.fadeOut()
                signUpSignInLabel.text = "Sign In"
                signUpSignInLabel.fadeIn()
                createAccountLabel.fadeOut()
                createAccountLabel.text = "Welcome Back"
                createAccountLabel.fadeIn()
                phoneNumberTextField.fadeOut()
                signInButton.isHidden = false
                signUpButton.isHidden = true
                
            }
            
        }
        
    }
    
    //MARK: -View Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        usernameTextField.addBottomBorder()
        passwordTextField.addBottomBorder()
        phoneNumberTextField.addBottomBorder()
        greyView1.layer.cornerRadius = 15.0
        greyView2.layer.cornerRadius = 15.0
        signInButton.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        signUpSignInLabel.fadeIn()
        createAccountLabel.fadeIn()
        
    }
    @IBAction func signUpSignInSegmentedAction(_ sender: UISegmentedControl) {
        switch signUpSignInSegmentedControl.selectedSegmentIndex {
        case 0:
            selectedLoginType = .signUp
            passwordTextField.textContentType = .newPassword
            
        case 1:
            selectedLoginType = .signIn
            passwordTextField.textContentType = .password
            
        default:
            break
        }
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        let authService = AuthService()
        
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            password.isEmpty == false,
            let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            username.isEmpty == false
            else { return }

        let phoneNumber = "1234567890"
        authService.registerUser(username: username, password: password, phoneNumber: phoneNumber) {
            
            DispatchQueue.main.async {
                self.dismiss(animated: true) {
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    print("Successful Registration)")

                }
            }
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        let authService = AuthService()
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            password.isEmpty == false,
            let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            username.isEmpty == false
            else { return }

        authService.loginUser(username: username, password: password) {

            DispatchQueue.main.async {
                print("Successful Sign-in")
                self.dismiss(animated: true) {
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                }

            }
        }

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
