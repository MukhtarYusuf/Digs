//
//  MukListing.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/26/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import FirebaseUI

enum MukListingType {
    case mukHouse
    case mukApartment
    case mukRoom
    
    static func mukCaseFromString(_ mukString: String) -> MukListingType {
        var mukType = MukListingType.mukHouse
        
        if mukString == "Apartment" {
            mukType = .mukApartment
        } else if mukString == "Room" {
            mukType = .mukRoom
        }
        
        return mukType
    }
    
    static func mukStringFromCase(_ mukType: MukListingType) -> String {
        switch mukType {
        case .mukHouse:
            return "House"
        case .mukApartment:
            return "Apartment"
        case .mukRoom:
            return "Room"
        }
    }
}

class MukListing: NSObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake((mukLatitude ?? 0.0), (mukLongitude ?? 0.0))
    }
    public var title: String? {
        return "$\(mukPrice)"
    }
    public var subtitle: String? {
        return """
                \(mukAddress1), \(mukCity)
                """
    }
    
    // MARK: Constants
    static let mukListingsRef = Database.database().reference().child("mukListings")
    let mukPhotosRef = Storage.storage().reference().child("images/listing-images")
    let mukProfilesRef = Database.database().reference().child("mukProfiles")
    
    let mukOwnerIdKey = "mukOwnerId"
    let mukOwnerNameKey = "mukOwnerName"
    let mukIsPublishedKey = "mukIsPublished"
    let mukBedsKey = "mukBeds"
    let mukSquareFeetKey = "mukSquareFeet"
    let mukCurPhotoIdKey = "mukCurPhotoId"
    let mukBathsKey = "mukBaths"
    let mukPriceKey = "mukPrice"
    let mukTypeKey = "mukType"
    let mukAddress1Key = "mukAddress"
    let mukCityKey = "mukCity"
    let mukStateKey = "mukState"
    let mukZipCodeKey = "mukZipCode"
    let mukCountryKey = "mukCountry"
    let mukDescriptionKey = "mukDescription"
    let mukDatePostedKey = "mukDatePosted"
    let mukLatitudeKey = "mukLatitude"
    let mukLongitudeKey = "mukLongitude"
    let mukFeaturesKey = "mukFeatures"
    let mukPhotosKey = "mukPhotos"
    
    let mukWasherDryerKey = "mukWasherDryer"
    let mukHighSpeedInternetKey = "mukHighSpeedInternet"
    let mukMicrowaveKey = "mukMicrowave"
    let mukSwimmingPoolKey = "mukSwimmingPool"
    let mukDishwasherKey = "mukDishwasher"
    let mukPatioBalconyKey = "mukPatioBalcony"
    let mukGymKey = "mukGym"
    let mukPetsKey = "mukPets"
    
    // MARK: Variables
    var mukProfile: MukProfile!
//    var mukProfileRef: DatabaseReference!
    
    var mukListingId: String
    var mukOwnerId: String
    var mukOwnerName: String
    var mukIsPublished: Bool
    var mukBeds: Int
    var mukSquareFeet: Int
    var mukCurPhotoId: Int
    var mukBaths: Double
    var mukPrice: Double
    var mukType: MukListingType
    var mukAddress1: String
    var mukCity: String
    var mukState: String
    var mukZipCode: String
    var mukCountry: String
    var mukDescription: String
    var mukDatePosted: Date
    var mukLatitude: Double?
    var mukLongitude: Double?
    var mukFeatures: [String : Bool]
    var mukPhotos: [String]?
    
    // MARK: Init
    init(mukBeds: Int, mukSquareFeet: Int, mukBaths: Double, mukPrice: Double,
         mukAddress1: String, mukCity: String, mukState: String,
         mukZipCode: String, mukCountry: String,  mukDescription: String,
         mukCompletion: ((Error?) -> Void)? = nil) {
        
        self.mukListingId = ""
        self.mukOwnerId = ""
        self.mukOwnerName = ""
        self.mukIsPublished = false
        self.mukBeds = mukBeds
        self.mukSquareFeet = mukSquareFeet
        self.mukCurPhotoId = 0
        self.mukBaths = mukBaths
        self.mukPrice = mukPrice
        self.mukType = .mukHouse
        self.mukAddress1 = mukAddress1
        self.mukCity = mukCity
        self.mukState = mukState
        self.mukZipCode = mukZipCode
        self.mukCountry = mukCountry
        self.mukDescription = mukDescription
        self.mukDatePosted = Date()
        
        self.mukFeatures = [
            mukWasherDryerKey: false,
            mukHighSpeedInternetKey: false,
            mukMicrowaveKey: false,
            mukSwimmingPoolKey: false,
            mukDishwasherKey: false,
            mukPatioBalconyKey: false,
            mukGymKey: false,
            mukPetsKey: false,
        ]
        self.mukPhotos = [String]()
        super.init()
        
        mukProfile = (UIApplication.shared.delegate as! AppDelegate).mukCurrentProfile
        mukOwnerId = mukProfile.mukUserId
        mukOwnerName = mukProfile.mukName
        var mukCurId = 0
        
        let mukIdRef = MukListing.mukListingsRef.child("\(mukProfile.mukUserId)").child("mukCurListingId")
        mukIdRef.observeSingleEvent(of: .value) { [weak self] mukSnapshot in
            mukCurId = mukSnapshot.value as? Int ?? 0
            mukCurId += 1
            self?.mukListingId = "\(mukCurId)"
            mukIdRef.setValue(mukCurId) { error, reference in
                if let mukCompletion = mukCompletion {
                    mukCompletion(error)
                }
            }
        }
        
//        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
//            guard let mukUser = user, let mukWeakSelf = self else { return }
//
//            mukWeakSelf.mukProfileRef = mukWeakSelf.mukProfilesRef.child(mukUser.uid)
//            mukWeakSelf.mukProfileObserver = mukWeakSelf.mukProfileRef?.observe(.value) { mukSnapshot in
//                mukWeakSelf.mukProfile = MukProfile(mukSnapshot: mukSnapshot)
//                mukWeakSelf.mukOwnerId = mukWeakSelf.mukProfile.mukUserId
//
//                var mukCurId = 0
//
//                let mukIdRef = MukListing.mukListingsRef.child("\(mukWeakSelf.mukProfile.mukUserId)").child("mukCurListingId")
//                mukIdRef.observeSingleEvent(of: .value) { mukSnapshot in
//                    mukCurId = mukSnapshot.value as? Int ?? 0
//                }
//
//                mukCurId += 1
//                mukWeakSelf.mukListingId = "\(mukCurId)"
//                mukIdRef.setValue(mukCurId)
//            } ?? 1
//        }
    }
    
    init(mukCompletion: ((Error?) -> Void)? = nil) {
        self.mukListingId = ""
        self.mukOwnerId = ""
        self.mukOwnerName = ""
        self.mukIsPublished = false
        self.mukBeds = 0
        self.mukSquareFeet = 0
        self.mukCurPhotoId = 0
        self.mukBaths = 0
        self.mukPrice = 0
        self.mukType = .mukHouse
        self.mukAddress1 = ""
        self.mukCity = ""
        self.mukState = ""
        self.mukZipCode = ""
        self.mukCountry = ""
        self.mukDescription = ""
        self.mukDatePosted = Date()
        
        self.mukFeatures = [
            mukWasherDryerKey: false,
            mukHighSpeedInternetKey: false,
            mukMicrowaveKey: false,
            mukSwimmingPoolKey: false,
            mukDishwasherKey: false,
            mukPatioBalconyKey: false,
            mukGymKey: false,
            mukPetsKey: false,
        ]
        self.mukPhotos = [String]()
        super.init()
        
        mukProfile = (UIApplication.shared.delegate as! AppDelegate).mukCurrentProfile
        mukOwnerId = mukProfile.mukUserId
        mukOwnerName = mukProfile.mukName
        var mukCurId = 0
        
        let mukIdRef = MukListing.mukListingsRef.child("\(mukProfile.mukUserId)").child("mukCurListingId")
        mukIdRef.observeSingleEvent(of: .value) { [weak self] mukSnapshot in
            mukCurId = mukSnapshot.value as? Int ?? 0
            mukCurId += 1
            self?.mukListingId = "\(mukCurId)"
            mukIdRef.setValue(mukCurId) { error, reference in
                if let mukCompletion = mukCompletion {
                    mukCompletion(error)
                }
            }
        }
    }
    
    init?(mukSnapshot: DataSnapshot) {
        guard let mukValue = mukSnapshot.value as? [String: AnyObject],
            let mukOwnerId = mukValue[mukOwnerIdKey] as? String,
            let mukOwnerName = mukValue[mukOwnerNameKey] as? String,
            let mukIsPublished = mukValue[mukIsPublishedKey] as? Bool,
            let mukBeds = mukValue[mukBedsKey] as? Int,
            let mukSquareFeet = mukValue[mukSquareFeetKey] as? Int,
            let mukCurPhotoId = mukValue[mukCurPhotoIdKey] as? Int,
            let mukBaths = mukValue[mukBathsKey] as? Double,
            let mukPrice = mukValue[mukPriceKey] as? Double,
            let mukType = mukValue[mukTypeKey] as? String,
            let mukAddress1 = mukValue[mukAddress1Key] as? String,
            let mukCity = mukValue[mukCityKey] as? String,
            let mukState = mukValue[mukStateKey] as? String,
            let mukZipCode = mukValue[mukZipCodeKey] as? String,
            let mukCountry = mukValue[mukCountryKey] as? String,
            let mukDescription = mukValue[mukDescriptionKey] as? String,
            let mukDatePosted = mukValue[mukDatePostedKey] as? Double,
            let mukLatitude = mukValue[mukLatitudeKey] as? Double,
            let mukLongitude = mukValue[mukLongitudeKey] as? Double,
            let mukFeatures = mukValue[mukFeaturesKey] as? [String:Bool]
            else {
                return nil
            }
        
        self.mukListingId = mukSnapshot.key
        self.mukOwnerId = mukOwnerId
        self.mukOwnerName = mukOwnerName
        self.mukIsPublished = mukIsPublished
        self.mukBeds = mukBeds
        self.mukSquareFeet = mukSquareFeet
        self.mukCurPhotoId = mukCurPhotoId
        self.mukBaths = mukBaths
        self.mukPrice = mukPrice
        self.mukType = MukListingType.mukCaseFromString(mukType)
        self.mukAddress1 = mukAddress1
        self.mukCity = mukCity
        self.mukState = mukState
        self.mukZipCode = mukZipCode
        self.mukCountry = mukCountry
        self.mukDescription = mukDescription
        self.mukDatePosted = Date(timeIntervalSince1970: mukDatePosted)
        self.mukLatitude = mukLatitude
        self.mukLongitude = mukLongitude
        self.mukFeatures = mukFeatures
        self.mukPhotos = mukValue[mukPhotosKey] as? [String]
        if self.mukPhotos == nil {
            self.mukPhotos = [String]()
        }
    }
    
    // MARK: Methods
    static func mukAddListing(mukListing: MukListing, mukCompletion: ((Error?) -> Void)? = nil) {
        mukSetListing(mukListing: mukListing, mukCompletion: mukCompletion)
    }
    
    static func mukUpdateListing(mukListing: MukListing, mukCompletion: ((Error?) -> Void)? = nil) {
        mukSetListing(mukListing: mukListing, mukCompletion: mukCompletion)
    }
    
    static func mukDeleteListing(mukListing: MukListing, mukCompletion: ((Error?) -> Void)? = nil) {
        guard let mukProfile = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile,
            mukProfile.mukType == .mukLandlord else {
            return
        }
        
        let mukListingRef = mukListingsRef.child("\(mukProfile.mukUserId)").child(mukListing.mukListingId)
        mukListingRef.removeValue { error1, reference in
            if error1 == nil {
                let mukPhotosRef = Storage.storage().reference().child("images/listing-images")
                let mukListingPhotosRef = mukPhotosRef.child(mukListing.mukListingId)
                mukListingPhotosRef.delete { error2 in
                    mukCompletion?(error2)
                }
            } else {
                mukCompletion?(error1)
            }
        }
    }
    
    func mukLoadPhoto(mukIndex: Int, into mukImageView: UIImageView) {
        guard let mukPhotos = mukPhotos,
            mukIndex >= 0,
            mukIndex < mukPhotos.count
            else {
                return
        }
        
        let mukPhotoPath = mukPhotos[mukIndex]
        let mukPhotoRef = mukPhotosRef.child(mukListingId).child(mukPhotoPath)
        let mukPlaceHolder = UIImage(named: "placeholder")
            
        mukImageView.sd_setImage(with: mukPhotoRef, placeholderImage: mukPlaceHolder)
    }
    
    func mukUploadPhoto(mukPhoto: UIImage, mukCompletion: ((Error?) -> Void)? ) {
        mukCurPhotoId += 1
        
        let mukPhotoRef = mukPhotosRef.child(mukListingId).child("\(mukCurPhotoId).png")
        mukPhotoRef.putData(mukPhoto.pngData()!, metadata: nil) { [weak self] metadata, error1 in
            guard let mukWeakSelf = self else { return }
            
            if error1 == nil {
                mukWeakSelf.mukPhotos?.append("\(mukWeakSelf.mukCurPhotoId).png")
                MukListing.mukUpdateListing(mukListing: mukWeakSelf) { error2 in
                    mukCompletion?(error2)
                }
            } else {
                mukCompletion?(error1)
            }
        }
    }
    
    func mukDeletePhoto(mukIndex: Int, mukCompletion: ((Error?) -> Void)? ) {
        guard let mukPhotos = mukPhotos,
            mukIndex >= 0,
            mukIndex < mukPhotos.count
            else {
                return
        }
        
        let mukPhotoPath = mukPhotos[mukIndex]
        let mukPhotoRef = mukPhotosRef.child(mukListingId).child(mukPhotoPath)
        mukPhotoRef.delete { [weak self] error1 in
            guard let mukWeakSelf = self else { return }
            
            if error1 == nil {
                self?.mukPhotos?.remove(at: mukIndex)
                MukListing.mukUpdateListing(mukListing: mukWeakSelf) { error2 in
                    mukCompletion?(error2)
                }
            } else {
                mukCompletion?(error1)
            }
        }
    }
    
    // MARK: Utilities
    private func mukToAny() -> Any {
        return [
            mukOwnerIdKey: mukOwnerId,
            mukOwnerNameKey: mukOwnerName,
            mukIsPublishedKey: mukIsPublished,
            mukBedsKey: mukBeds,
            mukSquareFeetKey: mukSquareFeet,
            mukCurPhotoIdKey: mukCurPhotoId,
            mukBathsKey: mukBaths,
            mukPriceKey: mukPrice,
            mukTypeKey: MukListingType.mukStringFromCase(mukType),
            mukAddress1Key: mukAddress1,
            mukCityKey: mukCity,
            mukStateKey: mukState,
            mukZipCodeKey: mukZipCode,
            mukCountryKey: mukCountry,
            mukDescriptionKey: mukDescription,
            mukDatePostedKey: mukDatePosted.timeIntervalSince1970,
            mukLatitudeKey: mukLatitude ?? 0.0,
            mukLongitudeKey: mukLongitude ?? 0.0,
            mukFeaturesKey: mukFeatures,
            mukPhotosKey: mukPhotos ?? [String]()
        ]
    }
    
    static private func mukSetListing(mukListing: MukListing, mukCompletion: ((Error?) -> Void)? ) {
        guard let mukProfile = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile,
            mukProfile.mukType == .mukLandlord else {
            return
        }
        
        let mukListingRef = mukListingsRef.child("\(mukProfile.mukUserId)").child(mukListing.mukListingId)
        mukListingRef.setValue(mukListing.mukToAny()) { error, reference in
            if let mukCompletion = mukCompletion {
                mukCompletion(error)
            }
        }
    }
}

//extension MukListing: Hashable {
//    static func == (lhs: MukListing, rhs: MukListing) -> Bool {
//        return lhs.mukListingId == rhs.mukListingId
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(mukListingId)
//    }
//}
