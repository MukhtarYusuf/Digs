//
//  MukMessagesViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/5/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase

class MukMessagesViewController: MukBaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukTableView: UITableView!
    @IBOutlet weak var mukTextField: UITextField!
    @IBOutlet weak var mukTypeMessageView: UIView!
    
    // MARK: Constants
    let mukCurrentProfile = (UIApplication.shared.delegate as! AppDelegate).mukCurrentProfile
    let mukConversationsRef = Database.database().reference().child("mukConversations")
    let mukMessageSenderCell = "MukMessageSenderCell"
    let mukMessageReceiverCell = "MukMessageReceiverCell"
    
    // MARK: Variables
    var mukConversationRef: DatabaseReference!
    var mukHandle: DatabaseHandle?
    var mukConversation: MukConversation!
    var mukMessages: [MukMessage] = []
    var mukMessageAccessoryView = MukMessageAccessoryView()
    var mukSenderId = ""
    var mukReceiverId = ""
    
    // MARK: Override Methods
    override func mukSetupTextFieldDelegates() {
        mukTextField.delegate = self
        mukMessageAccessoryView.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 45.0)
        mukMessageAccessoryView.mukSendButton.addTarget(self, action: #selector(mukSendButtonTapped), for: .touchUpInside)
        mukMessageAccessoryView.mukMessageTextField.delegate = self
        
        mukTextField.inputAccessoryView = mukMessageAccessoryView
    }
    
    override func mukHandleKeyboardDidShow(mukNotification: Notification) {
        super.mukHandleKeyboardDidShow(mukNotification: mukNotification)
        mukTypeMessageView.isHidden = true
    }
    
    override func mukHandleKeyboardWillHide(mukNotification: Notification) {
        super.mukHandleKeyboardWillHide(mukNotification: mukNotification)
        mukTypeMessageView.isHidden = false
    }
    
    // MARK: Action Methods
    @objc func mukSendButtonTapped() {
        if let mukText = mukMessageAccessoryView.mukMessageTextField.mukValidString {
            let mukMessage = MukMessage(mukSender: mukSenderId, mukReceiver: mukReceiverId, mukMessage: mukText)
            mukConversation.mukAddMessage(mukMessage: mukMessage)
            
            mukMessageAccessoryView.mukMessageTextField.text = ""
            mukActiveTextField.resignFirstResponder()
        }
    }
    
    // MARK: Utilities
    private func mukUpdateUI() {
        mukTableView.reloadData()
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get Receiver Name and set Title
        var mukReceiverName = ""
        for mukName in mukConversation.mukNames {
            if let mukProfile = mukCurrentProfile, mukName != mukProfile.mukName {
                mukReceiverName = mukName
                title = mukReceiverName
            }
        }
        
        // Set Sender and Receiver Ids
        for mukId in mukConversation.mukMembers {
            if let mukProfile = mukCurrentProfile {
                if mukId == mukProfile.mukUserId {
                    mukSenderId = mukId
                } else {
                    mukReceiverId = mukId
                }
            }
        }
        
        let mukMessageSenderNib = UINib(nibName: mukMessageSenderCell, bundle: nil)
        mukTableView.register(mukMessageSenderNib, forCellReuseIdentifier: mukMessageSenderCell)
        
        let mukMessageReceiverNib = UINib(nibName: mukMessageReceiverCell, bundle: nil)
        mukTableView.register(mukMessageReceiverNib, forCellReuseIdentifier: mukMessageReceiverCell)
        
        mukTableView.dataSource = self
        mukTableView.delegate = self
        
        mukConversationRef = mukConversationsRef.child(mukConversation.mukConversationId)
        mukHandle = mukConversationRef.observe(.value) { [weak self] snapshot in
            if let mukConversation = MukConversation(mukSnapshot: snapshot) {
                self?.mukConversation = mukConversation
                self?.mukMessages = mukConversation.mukMessages
                
                self?.mukUpdateUI()
            }
        }
    }
}

// MARK: UITableView DataSource and Delegate Methods
extension MukMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mukMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var mukCell: UITableViewCell
        
        let mukMessage = mukMessages[indexPath.row]
        if mukMessage.mukIsSender {
            mukCell = tableView.dequeueReusableCell(withIdentifier: mukMessageSenderCell, for: indexPath)
        } else {
            mukCell = tableView.dequeueReusableCell(withIdentifier: mukMessageReceiverCell, for: indexPath)
        }
        
        if let mukSenderCell = mukCell as? MukMessageSenderCell {
            mukSenderCell.mukConfigure(with: mukMessage)
        } else if let mukReceiverCell = mukCell as? MukMessageReceiverCell {
            mukReceiverCell.mukConfigure(with: mukMessage)
        }
        
        return mukCell
    }
}
