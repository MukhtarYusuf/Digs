//
//  MukMoreViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/7/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase

class MukMoreViewController: MukBaseTableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukSignedInLabel: UILabel!
    
    // MARK: Constants
    let mukCurrentProfile = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile
    let mukErrorTitle = "Sign Out Error"
    
    // MARK: UITableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0, indexPath.row == 3 {
            mukLogOut()
        }
    }
    
    // MARK: Utilities
    private func mukLogOut() {
        do {
            try Auth.auth().signOut()
            mukShowSuccessView(mukMessage: "Logged Out") { [weak self] in
                self?.navigationController?.tabBarController?.presentingViewController?.dismiss(animated: true)
            }
        } catch {
            mukShowAlert(mukTitle: mukErrorTitle, mukMessage: "Firebase Sign Out Error")
        }
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mukProfile = mukCurrentProfile {
            mukSignedInLabel.text = "Signed in as \(mukProfile.mukName)"
        }
    }
}
