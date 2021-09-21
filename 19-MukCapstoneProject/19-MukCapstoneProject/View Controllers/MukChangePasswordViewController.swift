//
//  MukChangePasswordViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/8/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase

class MukChangePasswordViewController: MukBaseTableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukNewPasswordTextField: MukTextField!
    @IBOutlet weak var mukConfirmNewPasswordTextField: MukTextField!
    
    // MARK: Constants
    let mukAlertTitle = "Error"
    
    // MARK: Actions
    @IBAction func mukSaveTapped(_ sender: UIBarButtonItem) {
        mukChangePassword()
    }
    
    // MARK: Utilities
    private func mukChangePassword() {
        guard let mukUser = Auth.auth().currentUser else { return }
        
        if let mukNewPassword = mukNewPasswordTextField.mukValidString,
            let mukConfirmNewPassword = mukConfirmNewPasswordTextField.mukValidString,
            mukNewPassword == mukConfirmNewPassword {
            
            mukShowActivityIndicator()
            mukUser.updatePassword(to: mukNewPassword) { [weak self] error in
                self?.mukHideActivityIndicator()
                if error != nil {
                    self?.mukShowAlert(mukTitle: self?.mukAlertTitle, mukMessage: "Firebase Error Updating Password")
                } else {
                    self?.mukShowSuccessView(mukMessage: "Updated") {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
}
