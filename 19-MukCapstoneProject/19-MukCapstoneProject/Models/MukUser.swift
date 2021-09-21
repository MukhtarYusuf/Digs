//
//  MukUser.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/25/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import Foundation
import Firebase

class MukUser {
    
    // MARK: Constants
    let mukUserId: String
    let mukEmail: String?
    
    // MARK: Init
    init(mukAuthUser: Firebase.User) {
        mukUserId = mukAuthUser.uid
        mukEmail = mukAuthUser.email
    }
    
}
