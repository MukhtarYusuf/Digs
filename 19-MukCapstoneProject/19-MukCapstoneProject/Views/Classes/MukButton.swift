//
//  MukButton.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/8/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukButton: UIButton {
    
    // MARK: Utilities
    private func mukSetup() {
        layer.cornerRadius = 9.0
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        mukSetup()
    }
}
