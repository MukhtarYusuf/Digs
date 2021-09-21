//
//  MukListingCell.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/30/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

protocol MukListingCellDelegate: class {
    func mukDidTapPublishButton(_ mukCell: MukListingCell)
    func mukDidTapFavoriteButton(_ mukCell: MukListingCell)
}

class MukListingCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var mukListingImage: UIImageView!
    @IBOutlet weak var mukPriceLabel: UILabel!
    @IBOutlet weak var mukTypeLabel: UILabel!
    @IBOutlet weak var mukBedLabel: UILabel!
    @IBOutlet weak var mukBathLabel: UILabel!
    @IBOutlet weak var mukSquareFeetLabel: UILabel!
    @IBOutlet weak var mukAddressLabel: UILabel!
    @IBOutlet weak var mukCityLabel: UILabel!
    @IBOutlet weak var mukStateLabel: UILabel!
    @IBOutlet weak var mukZipCodeLabel: UILabel!
    @IBOutlet weak var mukCircleSeparatorView: UIView!
    @IBOutlet weak var mukPublishedIndicatorView: UIView!
    @IBOutlet weak var mukFavoriteButton: UIButton!
    @IBOutlet weak var mukPublishButton: UIButton!
    
    // MARK: Variables
    weak var mukDelegate: MukListingCellDelegate?
    
    // MARK: Computed Properties
    var mukCurrentProfile: MukProfile? {
        return (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile
    }
    
    // MARK: Action Methods
    @IBAction func mukPublishButtonTapped(_ sender: UIButton) {
        mukDelegate?.mukDidTapPublishButton(self)
    }
    
    @IBAction func mukFavoriteButtonTapped(_ sender: UIButton) {
        mukDelegate?.mukDidTapFavoriteButton(self)
    }
    
    // MARK: Methods
    func mukConfigure(with mukListing: MukListing) {
        guard let mukProfile = mukCurrentProfile else { return }
        
        mukListing.mukLoadPhoto(mukIndex: 0, into: mukListingImage)
        mukPriceLabel.text = "$\(mukListing.mukPrice)/month"
        mukTypeLabel.text = MukListingType.mukStringFromCase(mukListing.mukType)
        mukBedLabel.text = "\(mukListing.mukBeds) Bed,"
        mukBathLabel.text = "\(mukListing.mukBaths) Baths,"
        mukSquareFeetLabel.text = "\(mukListing.mukSquareFeet) Sqft"
        mukAddressLabel.text = mukListing.mukAddress1
        mukCityLabel.text = "\(mukListing.mukCity),"
        mukStateLabel.text = "\(mukListing.mukState)."
        mukZipCodeLabel.text = mukListing.mukZipCode
        
        if mukProfile.mukType == .mukLandlord {
            let mukPublishedColor = UIColor(displayP3Red: 0.0,
                                            green: 0.86,
                                            blue: 0.0,
                                            alpha: 1.0)
            let mukUnPublishedColor = UIColor(displayP3Red: 0.31,
                                              green: 0.31,
                                              blue: 0.31,
                                              alpha: 1.0)
            if mukListing.mukIsPublished {
                mukPublishedIndicatorView.backgroundColor = mukPublishedColor
                mukPublishButton.setTitle("UnPublish", for: .normal)
            } else {
                mukPublishedIndicatorView.backgroundColor = mukUnPublishedColor
                mukPublishButton.setTitle("Publish", for: .normal)
            }
        } else if mukProfile.mukType == .mukTenant {
            mukPublishedIndicatorView.isHidden = true
            
            mukFavoriteButton.isHidden = false
            if mukProfile.mukFavorites?[mukListing.mukListingId] ?? false {
                mukFavoriteButton.setImage(UIImage(named: "heart-purple"), for: .normal)
            } else {
                mukFavoriteButton.setImage(UIImage(named: "heart-gray"), for: .normal)
            }
            
            mukPublishButton.setTitle("Check Availability", for: .normal)
        }
    }
    
    // MARK: Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mukListingImage.layer.cornerRadius = 9.0
        mukCircleSeparatorView.layer.cornerRadius = mukCircleSeparatorView.frame.width / 3.0
        mukPublishedIndicatorView.layer.cornerRadius = mukPublishedIndicatorView.frame.width / 3.0
        mukPublishButton.layer.cornerRadius = 9.0
    }
}
