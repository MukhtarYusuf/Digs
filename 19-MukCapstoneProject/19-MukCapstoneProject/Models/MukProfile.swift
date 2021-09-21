//
//  MukProfile.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/25/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import Foundation
import Firebase
import FirebaseUI

enum MukProfileType {
    case mukTenant
    case mukLandlord
    
    static func mukCaseFromString(_ mukString: String) -> MukProfileType {
        var mukType = MukProfileType.mukTenant
        
        if mukString == "Landlord" {
            mukType = .mukLandlord
        }
        
        return mukType
    }
    
    static func mukCaseToString(_ mukType: MukProfileType) -> String {
        switch mukType {
        case .mukTenant:
            return "Tenant"
        case .mukLandlord:
            return "Landlord"
        }
    }
}

class MukProfile {
    
    // MARK: Constants
    static let mukProfilesRef = Database.database().reference().child("mukProfiles")
    let mukPhotosRef = Storage.storage().reference().child("images/profile-images")
    
    let mukIdKey = "mukUserId"
    let mukPhotoKey = "mukPhotoPath"
    let mukNameKey = "mukName"
    let mukPhoneNoKey = "mukPhoneNo"
    let mukTypeKey = "mukType"
    let mukConversationsKey = "mukConversations"
    let mukFavoritesKey = "mukFavorites"
    let mukUserId: String
    
    // MARK: Variables
    var mukProfilePhoto: UIImage?
    var mukPhotoPath: String?
    var mukName: String
    var mukPhoneNo: String?
    var mukType: MukProfileType
    var mukConversations: [String : Bool]?
    var mukFavorites: [String : Bool]?
    
    // MARK: Init
    init(mukUserId: String, mukName: String, mukType: MukProfileType) {
        self.mukUserId = mukUserId
        self.mukName = mukName
        self.mukType = mukType
    }
    
    init?(mukSnapshot: DataSnapshot) {
        guard let mukValue = mukSnapshot.value as? [String : AnyObject],
            let mukName = mukValue[mukNameKey] as? String,
            let mukType = mukValue[mukTypeKey] as? String
            else {
                return nil
        }
        
        self.mukUserId = mukSnapshot.key
        self.mukPhotoPath = mukValue[mukPhotoKey] as? String
        self.mukName = mukName
        self.mukPhoneNo = mukValue[mukPhoneNoKey] as? String
        self.mukType = MukProfileType.mukCaseFromString(mukType)
        self.mukConversations = mukValue[mukConversationsKey] as? [String:Bool]
        self.mukFavorites = mukValue[mukFavoritesKey] as? [String:Bool]
    }
    
    // MARK: Methods
    static func mukAddProfile(mukProfile: MukProfile, mukCompletion: ((Error?) -> Void)? = nil) {
        mukSetProfile(mukProfile: mukProfile, mukCompletion: mukCompletion)
    }
    
    static func mukUpdateProfile(mukProfile: MukProfile, mukCompletion: ((Error?) -> Void)? = nil) {
        mukSetProfile(mukProfile: mukProfile, mukCompletion: mukCompletion)
    }
    
    static func mukDeleteProfile(mukProfile: MukProfile, mukCompletion: ((Error?) -> Void)? = nil) {
        let mukId = mukProfile.mukUserId
        let mukProfileRef = mukProfilesRef.child(mukId)
        mukProfileRef.removeValue { error1, reference in
            if error1 == nil {
                let mukPhotosRef = Storage.storage().reference().child("images/profile-images")
                let mukPhotoRef = mukPhotosRef.child("\(mukId).png")
                
                Auth.auth().currentUser?.delete { error3 in
                    if error3 == nil {
                        mukPhotoRef.delete()
                    }
                    mukCompletion?(error3)
                }
            } else {
                mukCompletion?(error1)
            }
        }
    }
    
    func mukUploadPhoto(mukImage: UIImage, mukCompletion: ((Error?) -> Void)? = nil) {
        if let mukImageData = mukImage.pngData() {
            if mukPhotoPath == nil || mukPhotoPath!.isEmpty {
                mukPhotoPath = mukUserId
            }
            
            let mukPhotoRef = mukPhotosRef.child("\(mukPhotoPath!).png")
            mukPhotoRef.putData(mukImageData, metadata: nil) { metadata, error in
                if let mukCompletion = mukCompletion {
                    mukCompletion(error)
                }
            }
        }
    }
    
    func mukLoadPhoto(into mukImageView: UIImageView) {
        let mukPlaceHolder = UIImage(named: "profile-placeholder.png")
        mukImageView.image = mukPlaceHolder
        
        if let mukPhotoPath = mukPhotoPath {
            let user = Auth.auth().currentUser?.uid
            let mukPhotoRef = mukPhotosRef.child("\(mukPhotoPath).png")
            
            mukPhotoRef.getData(maxSize: 300 * 1024 * 1024) { data, error in
                if error == nil {
                    let mukImage = UIImage(data: data!)
                    mukImageView.image = mukImage
                }
            }
        }
    }
    
    // MARK: Utilities
    private func mukToAny() -> Any {
        return [
            mukPhotoKey: mukPhotoPath ?? "",
            mukNameKey: mukName,
            mukPhoneNoKey: mukPhoneNo ?? "",
            mukTypeKey: MukProfileType.mukCaseToString(mukType),
            mukConversationsKey: mukConversations ?? [String:Bool](),
            mukFavoritesKey: mukFavorites ?? [String:Bool]()
        ]
    }
    
    static private func mukSetProfile(mukProfile: MukProfile, mukCompletion: ((Error?) -> Void)? = nil ) {
        
//        var mukCurId = 0
//
//        let mukIdRef = mukProfilesRef.child("mukCurId")
//        mukIdRef.observeSingleEvent(of: .value) { mukSnapshot in
//            mukCurId = mukSnapshot.value as? Int ?? 0
//        }
//
//        mukCurId += 1
//        mukIdRef.setValue(mukCurId)
        
        let mukProfileRef = mukProfilesRef.child("\(mukProfile.mukUserId)")
        mukProfileRef.setValue(mukProfile.mukToAny()) { error, reference in
            if let mukCompletion = mukCompletion {
                mukCompletion(error)
            }
        }
        
        
    }
    
}
