//
//  MukConversationCell.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/5/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukConversationCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var mukImage: UIImageView!
    @IBOutlet weak var mukNameLabel: UILabel!
    @IBOutlet weak var mukTimeLabel: UILabel!
    @IBOutlet weak var mukLastMessageLabel: UILabel!
    
    // MARK: Utilities
    func mukConfigure(with mukConversation: MukConversation) {
        mukTimeLabel.text = mukConversation.mukFormattedDateString
        mukLastMessageLabel.text = mukConversation.mukLastMessage
        
        if let mukReceiverProfile = mukConversation.mukReceiverProfile {
            mukNameLabel.text = mukReceiverProfile.mukName
            mukReceiverProfile.mukLoadPhoto(into: mukImage)
        } else {
            mukConversation.mukGetReceiverProfile() { [weak self] error in
                guard let mukWeakSelf = self else { return }
                
                if error == nil {
                    mukWeakSelf.mukNameLabel.text = mukConversation.mukReceiverProfile.mukName
                    mukConversation.mukReceiverProfile.mukLoadPhoto(into: mukWeakSelf.mukImage)
                }
            }
        }
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        separatorInset = UIEdgeInsets(top: 0.0,
                                      left: mukImage.frame.width + 8.0,
                                      bottom: 0.0,
                                      right: 0.0)
        mukImage.layer.cornerRadius = mukImage.frame.width/2.0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        let mukPlaceholder = UIImage(named: "placeholder")
        mukImage.image = mukPlaceholder
        
        mukNameLabel.text = "Loading..."
    }
}
