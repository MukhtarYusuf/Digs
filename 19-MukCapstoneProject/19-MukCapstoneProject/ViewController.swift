//
//  ViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/25/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Auth.auth().createUser(withEmail: "email2@email.com", password: "password") { auth, error in
            if error == nil, let auth = auth {
                let mukProfile = MukProfile(mukUserId: auth.user.uid, mukName: "Some name", mukType: .mukTenant)
                MukProfile.mukAddProfile(mukProfile: mukProfile, mukCompletion: nil)
            }
        }
        
//        let mukProfile = MukProfile(mukUserId: auth.user.uid, mukName: "A new Name", mukType: .mukTenant)
//        MukProfile.mukAddProfile(mukProfile: mukProfile)
        
    }


}

