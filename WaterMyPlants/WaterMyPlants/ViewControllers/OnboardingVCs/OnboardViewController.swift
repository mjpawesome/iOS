//
//  OnboardViewController.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit

@IBDesignable class OnboardViewController: UIViewController {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var greyView1: UIView!
    
    @IBOutlet weak var greyView2: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.addBottomBorder()
        passwordTextField.addBottomBorder()
        emailTextField.addBottomBorder()
        greyView1.layer.cornerRadius = 15.0
        greyView2.layer.cornerRadius = 15.0
        
        

    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true) {
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
