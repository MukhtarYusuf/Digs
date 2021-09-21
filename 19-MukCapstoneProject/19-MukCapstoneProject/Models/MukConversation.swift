//
//  MukConversation.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/27/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import Foundation
import Firebase

class MukConversation {
    
    // MARK: Constants
    static let mukConversationsRef = Database.database().reference().child("mukConversations")
    let mukProfilesRef = Database.database().reference().child("mukProfiles")
    let mukPhotosRef = Storage.storage().reference().child("images/profile-images")
    
    let mukConversationIdKey = "mukConversationId"
    let mukLastMessageKey = "mukLastMessage"
    let mukLastTimeKey = "mukLastTime"
    let mukMembersKey = "mukMembers"
    let mukNamesKey = "mukNames"
    let mukMessagesKey = "mukMessages"
    
    // MARK: Variables
    var mukConversationId: String
    var mukLastMessage: String
    var mukLastTime: Date
    var mukMembers: [String]
    var mukNames: [String]
    var mukMessages: [MukMessage]
    var mukReceiverProfile: MukProfile!
    
    // MARK: Computed Properties
    var mukFormattedDateString: String {
        let mukDateFormatter = DateFormatter()
        mukDateFormatter.timeStyle = .short
        mukDateFormatter.dateStyle = .none
        
        return mukDateFormatter.string(from: mukLastTime)
    }
    lazy var mukName: String = {
        var name = ""
        return name
    }()
    
    // MARK: Init
    init(mukMembers: [String], mukNames: [String]) {
        self.mukConversationId = ""
        self.mukLastMessage = ""
        self.mukLastTime = Date()
        self.mukMembers = mukMembers
        self.mukNames = mukNames
        self.mukMessages = [MukMessage]()
    }
    
    init?(mukSnapshot: DataSnapshot) {
        guard let mukValue = mukSnapshot.value as? [String: AnyObject],
            let mukLastMessage = mukValue[mukLastMessageKey] as? String,
            let mukLastTime = mukValue[mukLastTimeKey] as? Double,
            let mukMembers = mukValue[mukMembersKey] as? [String],
            let mukNames = mukValue[mukNamesKey] as? [String],
            let mukMessages = mukValue[mukMessagesKey] as? [[String: Any]]
        else {
            return nil
        }
        
        self.mukConversationId = mukSnapshot.key
        self.mukLastMessage = mukLastMessage
        self.mukLastTime = Date(timeIntervalSince1970: mukLastTime)
        self.mukMembers = mukMembers
        self.mukNames = mukNames
        self.mukMessages = [MukMessage]()
        
        for mukDictionary in mukMessages {
            if let mukMessage = MukMessage(mukData: mukDictionary) {
                self.mukMessages.append(mukMessage)
            }
        }
    }
    
    // MARK: Methods
    static func mukAddConversation(mukConversation: MukConversation, mukCompletion: ((Error?) -> Void)? = nil ) {
        mukSetConversation(mukConversation: mukConversation, mukCompletion: mukCompletion)
    }
    
    static func mukUpdateConversation(mukConversation: MukConversation, mukCompletion: ((Error?) -> Void)? = nil ) {
        mukSetConversation(mukConversation: mukConversation, mukCompletion: mukCompletion)
    }
    
    func mukAddMessage(mukMessage: MukMessage, mukCompletion: ((Error?) -> Void)? = nil ) {
        mukMessages.append(mukMessage)
        
        mukLastMessage = mukMessage.mukMessage
        mukLastTime = mukMessage.mukTime
        
        MukConversation.mukUpdateConversation(mukConversation: self, mukCompletion: mukCompletion)
    }
    
    func mukGetReceiverProfile(mukCompletion: ((Error?) -> Void)? = nil) {
        let senderId = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile?.mukUserId ?? ""
        var receiverId = ""
        for mukId in mukMembers {
            if mukId != senderId {
                receiverId = mukId
            }
        }
        
        let mukProfileRef = mukProfilesRef.child(receiverId)
        mukProfileRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let mukWeakSelf = self else { return }
            
            mukWeakSelf.mukReceiverProfile = MukProfile(mukSnapshot: snapshot)
            if mukWeakSelf.mukReceiverProfile == nil {
                mukCompletion?(NSError())
            } else {
                mukCompletion?(nil)
            }
        }
    }
    
    // MARK: Utilities
    private func mukToAny() -> Any {
        var mukMessageDicts = [[String:Any]]()
        for mukMessage in self.mukMessages {
            let mukMessageDict = mukMessage.mukToAny()
            mukMessageDicts.append(mukMessageDict)
        }
        
        return [
            mukLastMessageKey: mukLastMessage,
            mukLastTimeKey: mukLastTime.timeIntervalSince1970,
            mukMembersKey: mukMembers,
            mukNamesKey: mukNames,
            mukMessagesKey: mukMessageDicts
        ]
    }
    
    static private func mukSetConversation(mukConversation: MukConversation, mukCompletion: ((Error?) -> Void)? ) {
        if mukConversation.mukConversationId.isEmpty {
            var mukCurId = 0
            
            let mukIdRef = mukConversationsRef.child("mukCurConversationId")
            mukIdRef.observeSingleEvent(of: .value) { mukSnapshot in
                mukCurId = mukSnapshot.value as? Int ?? 0
                mukCurId += 1
                mukConversation.mukConversationId = "\(mukCurId)"
                mukIdRef.setValue(mukCurId)
                
                let mukConversationRef = mukConversationsRef.child(mukConversation.mukConversationId)
                mukConversationRef.setValue(mukConversation.mukToAny()) { error, reference in
                    if let mukCompletion = mukCompletion {
                        mukCompletion(error)
                    }
                }
            }
        } else {
            let mukConversationRef = mukConversationsRef.child(mukConversation.mukConversationId)
            mukConversationRef.setValue(mukConversation.mukToAny()) { error, reference in
                if let mukCompletion = mukCompletion {
                    mukCompletion(error)
                }
            }
        }
    }
    
}
