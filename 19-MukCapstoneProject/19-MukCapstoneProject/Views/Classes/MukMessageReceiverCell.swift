//
//  MukMessageReceiverCell.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/5/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukMessageReceiverCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var mukRoundedContentView: UIView!
    @IBOutlet weak var mukMessageLabel: UILabel!
    
    // MARK: Utilities
    func mukConfigure(with mukMessage: MukMessage) {
        mukMessageLabel.text = mukMessage.mukMessage
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        mukRoundedContentView.layer.cornerRadius = 9.0
    }
}
