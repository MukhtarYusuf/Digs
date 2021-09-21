//
//  MukMessage.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/27/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import Foundation
import Firebase

class MukMessage {
    
    // MARK: Constants
    let mukSenderKey = "mukSender"
    let mukReceiverKey = "mukReceiver"
    let mukMessageKey = "mukMessage"
    let mukTimeKey = "mukTime"
    
    // MARK: Variables
    var mukSender: String
    var mukReceiver: String
    var mukMessage: String
    var mukTime: Date
    
    // MARK: Computed Properties
    var mukIsSender: Bool {
        let mukCurrentProfile = (UIApplication.shared.delegate as! AppDelegate).mukCurrentProfile
        guard let mukProfile = mukCurrentProfile else { return false }
        
        return mukProfile.mukUserId == mukSender
    }
    
    // MARK: Init
    init(mukSender: String, mukReceiver: String, mukMessage: String) {
        self.mukSender = mukSender
        self.mukReceiver = mukReceiver
        self.mukMessage = mukMessage
        self.mukTime = Date()
    }
    
    init?(mukData: [String: Any]) {
        guard let mukSender = mukData[mukSenderKey] as? String,
            let mukReceiver = mukData[mukReceiverKey] as? String,
            let mukMessage = mukData[mukMessageKey] as? String,
            let mukTime = mukData[mukTimeKey] as? Double
            else {
                return nil
        }
        
        self.mukSender = mukSender
        self.mukReceiver = mukReceiver
        self.mukMessage = mukMessage
        self.mukTime = Date(timeIntervalSince1970: mukTime)
    }
    
    // MARK: Utilities
    func mukToAny() -> [String: Any] {
        return [
            mukSenderKey: mukSender,
            mukReceiverKey: mukReceiver,
            mukMessageKey: mukMessage,
            mukTimeKey: mukTime.timeIntervalSince1970
        ]
    }
}
