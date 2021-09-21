//
//  MukTenantListingDetailsViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/6/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase

class MukTenantListingDetailsViewController: MukBaseTableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukImageView: UIImageView!
    @IBOutlet weak var mukNumberLabel: UILabel!
    @IBOutlet weak var mukPriceLabel: UILabel!
    @IBOutlet weak var mukSeparatorView: UIView!
    @IBOutlet weak var mukTypeLabel: UILabel!
    @IBOutlet weak var mukBedLabel: UILabel!
    @IBOutlet weak var mukBathLabel: UILabel!
    @IBOutlet weak var mukSquareFeetLabel: UILabel!
    @IBOutlet weak var mukAddressLabel: UILabel!
    @IBOutlet weak var mukCityLabel: UILabel!
    @IBOutlet weak var mukStateLabel: UILabel!
    @IBOutlet weak var mukZipCodeLabel: UILabel!
    @IBOutlet weak var mukDescriptionLabel: UILabel!
    @IBOutlet weak var mukFavoriteButton: UIButton!
    
    @IBOutlet weak var mukWasherView: UIView!
    @IBOutlet weak var mukInternetView: UIView!
    @IBOutlet weak var mukMicrowaveView: UIView!
    @IBOutlet weak var mukPoolView: UIView!
    @IBOutlet weak var mukDishwasherView: UIView!
    @IBOutlet weak var mukPatioView: UIView!
    @IBOutlet weak var mukGymView: UIView!
    @IBOutlet weak var mukPetsView: UIView!
    @IBOutlet var mukTapGesture: UITapGestureRecognizer!
    
    // MARK: Constants
    let mukTopListingsRef = Database.database().reference().child("mukListings")
    let mukProfilesRef = Database.database().reference().child("mukProfiles")
    
    let mukListingDetailToAvailability = "ListingDetailToAvailability"
    let mukListingDetailsToImageViewer = "ListingDetailsToImageViewer"
    
    // MARK: Variables
    var mukListingRef: DatabaseReference?
    var mukProfileRef: DatabaseReference?
    
    var mukListing: MukListing!
    var mukCurrentProfile = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile
    var mukListingsHandle: DatabaseHandle?
    var mukProfileHandle: DatabaseHandle?
    
    // MARK: UITableView Delegate Methods
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let mukHeader = view as! UITableViewHeaderFooterView
        mukHeader.contentView.backgroundColor = .white
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let mukHeader = view as! UITableViewHeaderFooterView
        mukHeader.contentView.backgroundColor = .white
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 28.0
    }
    
    // MARK: Action Methods
    @IBAction func mukImageViewTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: mukListingDetailsToImageViewer, sender: nil)
    }
    
    @IBAction func mukFavoriteTapped(_ sender: UIButton) {
        guard let mukProfile = mukCurrentProfile else { return }
        
        if mukProfile.mukFavorites == nil {
            mukProfile.mukFavorites = [String : Bool]()
        }
        
        if mukProfile.mukFavorites![mukListing.mukListingId] ?? false {
            mukProfile.mukFavorites![mukListing.mukListingId] = nil
        } else {
            mukProfile.mukFavorites![mukListing.mukListingId] = true
        }
        
        MukProfile.mukUpdateProfile(mukProfile: mukProfile)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mukIdentifier = segue.identifier {
            if mukIdentifier == mukListingDetailToAvailability,
                let mukDestinationVC = segue.destination as? MukCheckAvailabilityViewController {
                mukDestinationVC.mukListing = mukListing
            } else if mukIdentifier == mukListingDetailsToImageViewer,
                let mukDestinationVC = segue.destination as? MukImageViewerViewController {
                mukDestinationVC.mukListing = mukListing
            }
        }
    }
    
    // MARK: Utilities
    private func mukUpdateUI() {
        mukListing.mukLoadPhoto(mukIndex: 0, into: mukImageView)
        mukNumberLabel.text = "1 of \(mukListing.mukPhotos?.count ?? 1)"
        mukPriceLabel.text = "$\(mukListing.mukPrice)"
        mukSeparatorView.layer.cornerRadius = mukSeparatorView.frame.width/2
        mukTypeLabel.text = MukListingType.mukStringFromCase(mukListing.mukType)
        mukBedLabel.text = "\(mukListing.mukBeds) Bed,"
        mukBathLabel.text = "\(mukListing.mukBaths) Bath,"
        mukSquareFeetLabel.text = "\(mukListing.mukSquareFeet) Sqft"
        mukAddressLabel.text = "\(mukListing.mukAddress1),"
        mukCityLabel.text = "\(mukListing.mukCity),"
        mukStateLabel.text = "\(mukListing.mukState)."
        mukZipCodeLabel.text = mukListing.mukZipCode
        mukDescriptionLabel.text = mukListing.mukDescription
        
        mukUpdateFavoriteButton()
        
        for (mukKey, mukValue) in mukListing.mukFeatures {
            if mukKey == mukListing.mukWasherDryerKey, !mukValue {
                mukWasherView.isHidden = true
            } else if mukKey == mukListing.mukHighSpeedInternetKey, !mukValue {
                mukInternetView.isHidden = true
            } else if mukKey == mukListing.mukMicrowaveKey, !mukValue {
                mukMicrowaveView.isHidden = true
            } else if mukKey == mukListing.mukSwimmingPoolKey, !mukValue {
                mukPoolView.isHidden = true
            } else if mukKey == mukListing.mukDishwasherKey, !mukValue {
                mukDishwasherView.isHidden = true
            } else if mukKey == mukListing.mukPatioBalconyKey, !mukValue {
                mukPatioView.isHidden = true
            } else if mukKey == mukListing.mukGymKey, !mukValue {
                mukGymView.isHidden = true
            } else if mukKey == mukListing.mukPetsKey, !mukValue {
                mukPetsView.isHidden = true
            }
        }
    }
    
    private func mukUpdateFavoriteButton() {
        guard let mukProfile = mukCurrentProfile else { return }
        
        if mukProfile.mukFavorites?[mukListing.mukListingId] ?? false {
            mukFavoriteButton.setImage(UIImage(named: "heart-purple"), for: .normal)
        } else {
            mukFavoriteButton.setImage(UIImage(named: "heart-gray"), for: .normal)
        }
    }
    
    private func mukSetupObservers() {
        mukListingRef = mukTopListingsRef.child(mukListing.mukOwnerId).child(mukListing.mukListingId)
        mukListingsHandle = mukListingRef?.observe(.value) { [weak self] snapshot in
            self?.mukListing = MukListing(mukSnapshot: snapshot)
            self?.mukUpdateUI()
        }
        
        if let mukProfile = mukCurrentProfile {
            mukProfileRef = mukProfilesRef.child(mukProfile.mukUserId)
            mukProfileHandle = mukProfileRef?.observe(.value) { [weak self] snapshot in
                self?.mukCurrentProfile = MukProfile(mukSnapshot: snapshot)
                self?.mukUpdateFavoriteButton()
            }
        }
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukSetupObservers()
    }
    
    deinit {
        if let mukListingHandle = mukListingsHandle {
            mukListingRef?.removeObserver(withHandle: mukListingHandle)
        }
        if let mukProfileHandle = mukProfileHandle {
            mukProfileRef?.removeObserver(withHandle: mukProfileHandle)
        }
    }
}
