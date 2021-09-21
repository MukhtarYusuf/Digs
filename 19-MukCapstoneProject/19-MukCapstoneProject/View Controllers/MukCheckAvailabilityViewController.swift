//
//  MukCheckAvailabilityViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/6/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukCheckAvailabilityViewController: MukBaseTableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukNameTextField: MukTextField!
    @IBOutlet weak var mukPhoneTextField: MukTextField!
    @IBOutlet weak var mukEmailTextField: MukTextField!
    @IBOutlet weak var mukMessageTextView: UITextView!
    
    // MARK: Constants
    let mukCurrentProfile = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile
    let mukCurrentUser = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentUser
    let mukAlertTitle = "Alert"
    let mukErrorTitle = "Error"
    
    // MARK: Variables
    var mukListing: MukListing!
    
    // MARK: Action Methods
    @IBAction func mukCheckAvailabilityTapped(_ sender: UIButton) {
        mukSendMessage()
    }
    
    
    // MARK: Utilities
    private func mukUpdateUI() {
        guard let mukProfile = mukCurrentProfile,
            let mukUser = mukCurrentUser else { return }
        
        mukNameTextField.text = mukProfile.mukName
        mukPhoneTextField.text = mukProfile.mukPhoneNo
        mukEmailTextField.text = mukUser.mukEmail
    }
    
    private func mukSendMessage() {
        guard let _ = mukNameTextField.mukValidString,
            let _ = mukEmailTextField.mukValidString,
            let mukMessage = mukMessageTextView.text,
            !mukMessage.isEmpty
            else {
                mukShowAlert(mukTitle: mukAlertTitle, mukMessage: "Please Validate all Fields")
                return
        }
        
        if let mukProfile = mukCurrentProfile {
            let mukMembers = [mukProfile.mukUserId, mukListing.mukOwnerId]
            let mukNames = [mukProfile.mukName, mukListing.mukOwnerName]
            let mukConversation = MukConversation(mukMembers: mukMembers, mukNames: mukNames)
            
            mukShowActivityIndicator()
            MukConversation.mukAddConversation(mukConversation: mukConversation) { [weak self] error in
                guard let mukWeakSelf = self else { return }
                
                if error != nil {
                    mukWeakSelf.mukHideActivityIndicator()
                    mukWeakSelf.mukShowAlert(mukTitle: mukWeakSelf.mukErrorTitle, mukMessage: "Error Sending Message")
                } else {
                    // Construct First Message
                    let mukMessage1String = "\(mukWeakSelf.mukListing.mukAddress1),\n" +
                        "\(mukWeakSelf.mukListing.mukCity), \(mukWeakSelf.mukListing.mukState). " +
                        "\(mukWeakSelf.mukListing.mukZipCode)"
                    let mukMessage1 = MukMessage(mukSender: mukProfile.mukUserId,
                                                 mukReceiver: mukWeakSelf.mukListing.mukOwnerId,
                                                 mukMessage: mukMessage1String)
                    
                    let mukNameDetails = "Name: \(mukWeakSelf.mukNameTextField.mukValidString ?? "")"
                    let mukEmailDetails = "Email: \(mukWeakSelf.mukEmailTextField.mukValidString ?? "")"
                    
                    var mukPhoneDetails = ""
                    if let mukPhone = mukWeakSelf.mukPhoneTextField.mukValidString {
                        mukPhoneDetails = "Phone: \(mukPhone)"
                    }
                    
                    // Construct Second Message
                    let mukMessage2String = "\(mukNameDetails)\n\(mukEmailDetails)\n\(mukPhoneDetails)"
                    let mukMessage2 = MukMessage(mukSender: mukProfile.mukUserId,
                                                 mukReceiver: mukWeakSelf.mukListing.mukOwnerId,
                                                 mukMessage: mukMessage2String)
                    
                    // Construct Third Message
                    let mukMessage3String = mukWeakSelf.mukMessageTextView.text!
                    let mukMessage3 = MukMessage(mukSender: mukProfile.mukUserId,
                                                 mukReceiver: mukWeakSelf.mukListing.mukOwnerId,
                                                 mukMessage: mukMessage3String)
                    
                    // Chain Message Adding With Completion Handlers
                    mukConversation.mukAddMessage(mukMessage: mukMessage1) { error1 in
                        if error1 != nil {
                            mukWeakSelf.mukHideActivityIndicator()
                            mukWeakSelf.mukShowAlert(mukTitle: mukWeakSelf.mukErrorTitle,
                                                     mukMessage: "Error Sending Message")
                        } else {
                            mukConversation.mukAddMessage(mukMessage: mukMessage2) { error2 in
                                if error2 != nil {
                                    mukWeakSelf.mukHideActivityIndicator()
                                    mukWeakSelf.mukShowAlert(mukTitle: mukWeakSelf.mukErrorTitle,
                                                             mukMessage: "Error Sending Message")
                                } else {
                                    mukConversation.mukAddMessage(mukMessage: mukMessage3) { error3 in
                                        mukWeakSelf.mukHideActivityIndicator()
                                        if error3 != nil {
                                            mukWeakSelf.mukShowAlert(mukTitle: mukWeakSelf.mukErrorTitle,
                                                                     mukMessage: "Error Sending Message")
                                        } else {
                                            mukWeakSelf.mukShowSuccessView(mukMessage: "Sent") {
                                                mukWeakSelf.navigationController?.popViewController(animated: true)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukUpdateUI()
    }
}
