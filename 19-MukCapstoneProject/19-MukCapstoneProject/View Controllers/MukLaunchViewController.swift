//
//  MukLaunchPageViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/28/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukLaunchViewController: MukBaseViewController {
    
    // MARK: Constants
    let mukTenantToLogin = "TenantToLogin"
    let mukLandlordToLogin = "LandlordToLogin"
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mukIdentifier = segue.identifier {
            
            if let mukLoginVC = segue.destination as? MukLoginViewController {
            
                var mukType: MukProfileType = .mukTenant
                if mukIdentifier == mukTenantToLogin {
                    mukType = .mukTenant
                } else if mukIdentifier == mukLandlordToLogin {
                    mukType = .mukLandlord
                }
                
                mukLoginVC.mukProfileType = mukType
            }
        }
    }
    
}
