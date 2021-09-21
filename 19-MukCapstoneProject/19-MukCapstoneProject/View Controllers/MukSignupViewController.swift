//
//  MukSignupViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/29/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase

class MukSignupViewController: MukBaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukHeaderLabel: UILabel!
    @IBOutlet weak var mukNameTextField: MukTextField!
    @IBOutlet weak var mukEmailTextField: MukTextField!
    @IBOutlet weak var mukPasswordTextField: MukTextField!
    @IBOutlet weak var mukConfirmPasswordTextField: MukTextField!
    
    // MARK: Constants
    let mukErrorTitle = "Sign Up Error"
    
    // MARK: Variables
    var mukProfileType: MukProfileType = .mukTenant
    
    // MARK: MukBaseViewController Methods
    override func mukSetupTextFieldDelegates() {
        super.mukSetupTextFieldDelegates()
        
        mukNameTextField.delegate = self
        mukEmailTextField.delegate = self
        mukPasswordTextField.delegate = self
        mukConfirmPasswordTextField.delegate = self
    }
    
    // MARK: Action Methods
    @IBAction func mukSignUp(_ sender: UIButton) {
        mukDoSignUp()
    }
    
    @IBAction func mukToLogin(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: Utilities
    private func mukUpdateUI() {
        switch mukProfileType {
        case .mukTenant:
            mukHeaderLabel.text = "Tenant Sign Up"
        case .mukLandlord:
            mukHeaderLabel.text = "Landlord Sign Up"
        }
    }
    
    private func mukDoSignUp() {
        guard let mukName = mukNameTextField.mukValidString,
            let mukEmail = mukEmailTextField.mukValidString,
            let mukPassword = mukPasswordTextField.mukValidString,
            let mukConfirmPassword = mukConfirmPasswordTextField.mukValidString,
            mukPassword == mukConfirmPassword
            else {
                mukShowAlert(mukTitle: "Sign Up Error", mukMessage: "Please make sure input is valid, and passwords match")
                return
        }
        
        mukShowActivityIndicator()
        Auth.auth().createUser(withEmail: mukEmail, password: mukPassword) { [weak self] auth, error in
            if error != nil {
                self?.mukHideActivityIndicator()
                self?.mukShowAlert(mukTitle: self?.mukErrorTitle, mukMessage: "Could not create user")
                
                return
            }
            
            let mukProfile = MukProfile(mukUserId: auth!.user.uid, mukName: mukName,
                                        mukType: self?.mukProfileType ?? .mukTenant)
            MukProfile.mukAddProfile(mukProfile: mukProfile) { error in
                self?.mukHideActivityIndicator()
            
                if error == nil {
                    self?.mukShowSuccessView {
                        self?.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self?.mukShowAlert(mukTitle: self?.mukErrorTitle, mukMessage: "Could not create user")
                }
            }
            
//            Auth.auth().signIn(withEmail: mukEmail, password: mukPassword) { auth1, error1 in
//
//            }
        }
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukUpdateUI()
    }
}
