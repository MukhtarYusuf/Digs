//
//  MukConversationsViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/5/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase

class MukConversationsViewController: MukBaseTableViewController {
    
    // MARK: Constants
    let mukConversationsRef = Database.database().reference().child("mukConversations")
    let mukConversationCell = "MukConversationCell"
    let mukConversationsToMessages = "ConversationsToMessages"
    
    // MARK: Variables
    var mukConversations: [MukConversation] = []
    var mukConversationsHandle: DatabaseHandle?
    
    // MARK: Computed Properties
    var mukCurrentProfile: MukProfile? {
        return (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile
    }
    
    // MARK: UITableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mukConversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mukCell = tableView.dequeueReusableCell(withIdentifier: mukConversationCell, for: indexPath)
        let mukConversation = mukConversations[indexPath.row]
        
        if let mukCell = mukCell as? MukConversationCell {
            mukCell.mukConfigure(with: mukConversation)
        }
        
        return mukCell
    }
    
    // MARK: UITableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: mukConversationsToMessages, sender: indexPath)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mukIdentifier = segue.identifier {
            if mukIdentifier == mukConversationsToMessages,
                let mukDestinationVC = segue.destination as? MukMessagesViewController,
                let mukIndexPath = sender as? IndexPath {
                let mukConversation = mukConversations[mukIndexPath.row]
                mukDestinationVC.mukConversation = mukConversation
            }
        }
    }
    
    // MARK: Utilities
    func mukSetupModels() {
        mukConversationsHandle = mukConversationsRef.observe(.value) { [weak self] snapshot in
            self?.mukConversations.removeAll()
            
            for mukConversationChild in snapshot.children {
                if let mukConversationSnapshot = mukConversationChild as? DataSnapshot,
                    let mukConversation = MukConversation(mukSnapshot: mukConversationSnapshot),
                    let mukProfile = self?.mukCurrentProfile {
                    
                    if mukConversation.mukMembers.contains(mukProfile.mukUserId) {
                        self?.mukConversations.append(mukConversation)
                    }
                }
            }
            
            self?.mukUpdateUI()
        }
    }
    
    func mukUpdateUI() {
        tableView.reloadData()
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        let mukConversationNib = UINib(nibName: mukConversationCell, bundle: nil)
        tableView.register(mukConversationNib, forCellReuseIdentifier: mukConversationCell)
        
        mukSetupModels()
    }
    
}
