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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var greyView1: UIView!
    @IBOutlet weak var greyView2: UIView!
    
    //MARK: -Properties
    var selectedLoginType: LoginType = .signIn {
        didSet {
            switch selectedLoginType {
            case .signUp:
                signUpSignInLabel.text = "Sign Up"
                signUpSignInLabel.fadeIn()
                createAccountLabel.text = "Create Account"
                createAccountLabel.fadeIn()
                emailTextField.fadeIn()
                emailTextField.isHidden = false
                
            case .signIn:
                signUpSignInLabel.fadeOut()
                signUpSignInLabel.text = "Sign In"
                signUpSignInLabel.fadeIn()
                createAccountLabel.fadeOut()
                createAccountLabel.text = "Welcome Back"
                createAccountLabel.fadeIn()
                emailTextField.fadeOut()
                
            }
        }
    }
    
    //MARK: -View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.addBottomBorder()
        passwordTextField.addBottomBorder()
        emailTextField.addBottomBorder()
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
            selectedLoginType = .signUp
            passwordTextField.textContentType = .newPassword
 
        case 1:
            selectedLoginType = .signIn
            passwordTextField.textContentType = .password
            
        default:
            break
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
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
