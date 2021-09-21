//
//  MukLandlordListingDetailsViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/31/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import GooglePlaces

class MukLandlordListingDetailsViewController: MukBaseTableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukDeleteBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var mukHomeButton: UIButton!
    @IBOutlet weak var mukApartmentButton: UIButton!
    @IBOutlet weak var mukRoomButton: UIButton!
    @IBOutlet weak var mukPriceTextField: MukTextField!
    @IBOutlet weak var mukBedsTextField: MukTextField!
    @IBOutlet weak var mukBathsTextField: MukTextField!
    @IBOutlet weak var mukSquareFeetTextField: MukTextField!
    @IBOutlet weak var mukAddressTextField: MukTextField!
    @IBOutlet weak var mukCityTextField: MukTextField!
    @IBOutlet weak var mukStateTextField: MukTextField!
    @IBOutlet weak var mukCountryTextField: MukTextField!
    @IBOutlet weak var mukZipCodeTextField: MukTextField!
    @IBOutlet weak var mukDescriptionTextView: UITextView!
    @IBOutlet weak var mukWasherButton: UIButton!
    @IBOutlet weak var mukDishwasherButton: UIButton!
    @IBOutlet weak var mukInternetButton: UIButton!
    @IBOutlet weak var mukPatioButton: UIButton!
    @IBOutlet weak var mukMicrowaveButton: UIButton!
    @IBOutlet weak var mukGymButton: UIButton!
    @IBOutlet weak var mukPoolButton: UIButton!
    @IBOutlet weak var mukPetsButton: UIButton!
    @IBOutlet weak var mukPhotosCollectionView: UICollectionView!
    @IBOutlet weak var mukPublishButton: UIButton!
    
    // MARK: Constants
    let mukErrorTitle = "Listing Error"
    let mukListingDetailsToPhotoViewer = "ListingDetailsToImageViewer"
    
    // MARK: Variables
    var mukIsEditing = false
    var mukListing: MukListing!
    
    // MARK: Action Methods
    @IBAction func mukFeatureTapped(_ sender: UIButton) {
        mukUpdateFeature(sender)
    }
    
    @IBAction func mukTypeTapped(_ sender: UIButton) {
        mukUpdateListingType(sender)
    }
    
    @IBAction func mukSaveTapped(_ sender: UIBarButtonItem) {
        mukSaveListing()
    }
    
    @IBAction func mukPublishTapped(_ sender: UIButton) {
        if mukListing.mukIsPublished {
            mukListing.mukIsPublished = false
            mukUpdatePublishButtonUI()
        } else {
            mukListing.mukIsPublished = true
            mukUpdatePublishButtonUI()
            mukSaveListing()
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mukIdentifier = segue.identifier {
            if mukIdentifier == mukListingDetailsToPhotoViewer,
                let mukImageViewerVC = segue.destination as? MukImageViewerViewController {
                mukImageViewerVC.mukListing = mukListing
                
                if let mukIndex = (sender as? IndexPath)?.row {
                    mukImageViewerVC.mukCurrentIndex = mukIndex
                }
            }
        }
    }
    
    // MARK: Utilities
    private func mukSetupUI() {
        if mukIsEditing {
            mukDeleteBarButtonItem.isEnabled = true
            title = "Edit Listing"
            
            switch mukListing.mukType {
            case .mukHouse:
                mukUpdateListingTypeUI(mukHomeButton)
            case .mukApartment:
                mukUpdateListingTypeUI(mukApartmentButton)
            case .mukRoom:
                mukUpdateListingTypeUI(mukRoomButton)
            }
            
            mukPriceTextField.text = "\(mukListing.mukPrice)"
            mukBedsTextField.text = "\(mukListing.mukBeds)"
            mukBathsTextField.text = "\(mukListing.mukBaths)"
            mukSquareFeetTextField.text = "\(mukListing.mukSquareFeet)"
            
            mukAddressTextField.text = mukListing.mukAddress1
            mukCityTextField.text = mukListing.mukCity
            mukStateTextField.text = mukListing.mukState
            mukCountryTextField.text = mukListing.mukCountry
            mukZipCodeTextField.text = mukListing.mukZipCode
            mukDescriptionTextView.text = mukListing.mukDescription
            
            mukUpdateFeaturesUI()
            mukUpdatePhotosUI()
            mukUpdatePublishButtonUI()
            
            for mukKey in mukListing.mukFeatures.keys {
                if mukKey == mukListing.mukWasherDryerKey {
                    
                }
            }
        } else {
            title = "Add Listing"
            mukDeleteBarButtonItem.isEnabled = false
            
            mukUpdateListingTypeUI(mukHomeButton)
        }
    }
    
    private func mukUpdateListingTypeUI(_ mukButton: UIButton) {
        let mukCheckedName = "icons8-checked-radio-button-50-purple"
        let mukUncheckedName = "icons8-unchecked-radio-button-50-gray"
        
        mukHomeButton.setImage(UIImage(named: mukUncheckedName), for: .normal)
        mukApartmentButton.setImage(UIImage(named: mukUncheckedName), for: .normal)
        mukRoomButton.setImage(UIImage(named: mukUncheckedName), for: .normal)
        
        mukButton.setImage(UIImage(named: mukCheckedName), for: .normal)
    }
    
    private func mukUpdateFeaturesUI() {
        guard let mukListing = mukListing else { return }
        
        for (mukKey, mukValue) in mukListing.mukFeatures {
            if mukKey == mukListing.mukWasherDryerKey {
                mukUpdateFeatureUI(mukButton: mukWasherButton, mukSelected: mukValue)
            } else if mukKey == mukListing.mukDishwasherKey {
                mukUpdateFeatureUI(mukButton: mukDishwasherButton, mukSelected: mukValue)
            } else if mukKey == mukListing.mukHighSpeedInternetKey {
                mukUpdateFeatureUI(mukButton: mukInternetButton, mukSelected: mukValue)
            } else if mukKey == mukListing.mukPatioBalconyKey {
                mukUpdateFeatureUI(mukButton: mukPatioButton, mukSelected: mukValue)
            } else if mukKey == mukListing.mukMicrowaveKey {
                mukUpdateFeatureUI(mukButton: mukMicrowaveButton, mukSelected: mukValue)
            } else if mukKey == mukListing.mukGymKey {
                mukUpdateFeatureUI(mukButton: mukGymButton, mukSelected: mukValue)
            } else if mukKey == mukListing.mukSwimmingPoolKey {
                mukUpdateFeatureUI(mukButton: mukPoolButton, mukSelected: mukValue)
            } else if mukKey == mukListing.mukPetsKey {
                mukUpdateFeatureUI(mukButton: mukPetsButton, mukSelected: mukValue)
            }
        }
    }
    
    private func mukUpdateFeatureUI(mukButton: UIButton, mukSelected: Bool) {
        let mukCheckedName = "icons8-checked-checkbox-50-purple"
        let mukUncheckedName = "icons8-unchecked-checkbox-50-gray"
        
        if mukSelected {
            mukButton.setImage(UIImage(named: mukCheckedName), for: .normal)
        } else {
            mukButton.setImage(UIImage(named: mukUncheckedName), for: .normal)
        }
    }
    
    private func mukUpdatePublishButtonUI() {
        if mukListing.mukIsPublished {
            mukPublishButton.setTitle("Unpublish", for: .normal)
        } else {
            mukPublishButton.setTitle("Save and Publish", for: .normal)
        }
    }
    
    private func mukUpdateFeature(_ mukButton: UIButton) {
        guard let mukListing = mukListing else { return }
        
        var mukFeatureToggled = false
        if mukButton == mukWasherButton {
            mukFeatureToggled = !mukListing.mukFeatures[mukListing.mukWasherDryerKey]!
            mukListing.mukFeatures[mukListing.mukWasherDryerKey] = mukFeatureToggled
            mukUpdateFeatureUI(mukButton: mukButton, mukSelected: mukFeatureToggled)
        } else if mukButton == mukDishwasherButton {
            mukFeatureToggled = !mukListing.mukFeatures[mukListing.mukDishwasherKey]!
            mukListing.mukFeatures[mukListing.mukDishwasherKey] = mukFeatureToggled
            mukUpdateFeatureUI(mukButton: mukButton, mukSelected: mukFeatureToggled)
        } else if mukButton == mukInternetButton {
            mukFeatureToggled = !mukListing.mukFeatures[mukListing.mukHighSpeedInternetKey]!
            mukListing.mukFeatures[mukListing.mukHighSpeedInternetKey] = mukFeatureToggled
            mukUpdateFeatureUI(mukButton: mukButton, mukSelected: mukFeatureToggled)
        } else if mukButton == mukPatioButton {
            mukFeatureToggled = !mukListing.mukFeatures[mukListing.mukPatioBalconyKey]!
            mukListing.mukFeatures[mukListing.mukPatioBalconyKey] = mukFeatureToggled
            mukUpdateFeatureUI(mukButton: mukButton, mukSelected: mukFeatureToggled)
        } else if mukButton == mukMicrowaveButton {
            mukFeatureToggled = !mukListing.mukFeatures[mukListing.mukMicrowaveKey]!
            mukListing.mukFeatures[mukListing.mukMicrowaveKey] = mukFeatureToggled
            mukUpdateFeatureUI(mukButton: mukButton, mukSelected: mukFeatureToggled)
        } else if mukButton == mukGymButton {
            mukFeatureToggled = !mukListing.mukFeatures[mukListing.mukGymKey]!
            mukListing.mukFeatures[mukListing.mukGymKey] = mukFeatureToggled
            mukUpdateFeatureUI(mukButton: mukButton, mukSelected: mukFeatureToggled)
        } else if mukButton == mukPoolButton {
            mukFeatureToggled = !mukListing.mukFeatures[mukListing.mukSwimmingPoolKey]!
            mukListing.mukFeatures[mukListing.mukSwimmingPoolKey] = mukFeatureToggled
            mukUpdateFeatureUI(mukButton: mukButton, mukSelected: mukFeatureToggled)
        } else if mukButton == mukPetsButton {
            mukFeatureToggled = !mukListing.mukFeatures[mukListing.mukPetsKey]!
            mukListing.mukFeatures[mukListing.mukPetsKey] = mukFeatureToggled
            mukUpdateFeatureUI(mukButton: mukButton, mukSelected: mukFeatureToggled)
        }
    }
    
    private func mukUpdateListingType(_ mukButton: UIButton) {
        if mukButton == mukHomeButton {
            mukListing.mukType = .mukHouse
            mukUpdateListingTypeUI(mukButton)
        } else if mukButton == mukApartmentButton {
            mukListing.mukType = .mukApartment
            mukUpdateListingTypeUI(mukButton)
        } else if mukButton == mukRoomButton {
            mukListing.mukType = .mukRoom
            mukUpdateListingTypeUI(mukButton)
        }
    }
    
    private func mukUpdatePhotosUI() {
        mukPhotosCollectionView.reloadData()
    }
    
    private func mukSaveListing() {
        guard let mukListing = mukListing,
            let mukPrice = mukPriceTextField.mukValidDouble,
            let mukBeds = mukBedsTextField.mukValidInt,
            let mukBaths = mukBathsTextField.mukValidDouble,
            let mukSquareFeet = mukSquareFeetTextField.mukValidInt,
            let mukAddress = mukAddressTextField.mukValidString,
            let mukCity = mukCityTextField.mukValidString,
            let mukState = mukStateTextField.mukValidString,
            let mukCountry = mukCountryTextField.mukValidString,
            let mukZipCode = mukZipCodeTextField.mukValidString,
            let mukDescription = mukDescriptionTextView.text,
            let mukPhotos = mukListing.mukPhotos,
            mukPhotos.count > 0
            else {
                mukShowAlert(mukTitle: mukErrorTitle, mukMessage: "Please Validate all Fields")
                return
        }
        
        mukListing.mukPrice = mukPrice
        mukListing.mukBeds = mukBeds
        mukListing.mukBaths = mukBaths
        mukListing.mukSquareFeet = mukSquareFeet
        mukListing.mukAddress1 = mukAddress
        mukListing.mukCity = mukCity
        mukListing.mukState = mukState
        mukListing.mukCountry = mukCountry
        mukListing.mukZipCode = mukZipCode
        mukListing.mukDescription = mukDescription
        
        mukShowActivityIndicator()
        MukListing.mukUpdateListing(mukListing: mukListing) { [weak self] error in
            self?.mukHideActivityIndicator()
            
            if error == nil {
                self?.mukShowSuccessView(mukMessage: "Saved") {
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                self?.mukShowAlert(mukTitle: self?.mukErrorTitle, mukMessage: "Error Saving to Firebase")
            }
        }
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukAddressTextField.delegate = self
        mukIsEditing = mukListing == nil ? false : true
        
        if !mukIsEditing {
            mukShowActivityIndicator()
            mukListing = MukListing() { [weak self] error in
                self?.mukHideActivityIndicator()
                
                if error != nil {
                    self?.mukShowAlert(mukTitle: self?.mukErrorTitle, mukMessage: "Default Listing Not Created")
                }
            }
        }
        
        mukPhotosCollectionView.dataSource = self
        mukPhotosCollectionView.delegate = self
        
        mukSetupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        mukUpdatePhotosUI()
    }

}

extension MukLandlordListingDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (mukListing.mukPhotos?.count ?? 0) + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let mukPhotoCellIdentifier = "ListingPhotoCell"
        let mukAddCellIdentifier = "AddPhotoCell"
        
        var mukCell: UICollectionViewCell
        if indexPath.item < (mukListing.mukPhotos?.count ?? 0) {
            mukCell = collectionView.dequeueReusableCell(withReuseIdentifier: mukPhotoCellIdentifier, for: indexPath)
            mukCell.layer.borderWidth = 0.0
            
            let mukTag = 1
            if let mukImageView = mukCell.viewWithTag(mukTag) as? UIImageView {
                mukListing.mukLoadPhoto(mukIndex: indexPath.item, into: mukImageView)
            }
        } else {
            mukCell = collectionView.dequeueReusableCell(withReuseIdentifier: mukAddCellIdentifier, for: indexPath)
            mukCell.layer.borderWidth = 1.0
            mukCell.layer.borderColor = CGColor(srgbRed: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        }
        
        return mukCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < (mukListing.mukPhotos?.count ?? 0) {
            performSegue(withIdentifier: mukListingDetailsToPhotoViewer, sender: indexPath)
        } else {
            mukChoosePhoto()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 97.0, height: 97.0)
    }
    
}

extension MukLandlordListingDetailsViewController: UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    // MARK: Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        if let mukChosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            mukShowActivityIndicator()
            mukListing.mukUploadPhoto(mukPhoto: mukChosenImage) { [weak self] error in
                self?.mukHideActivityIndicator()
                
                if error == nil {
                    self?.mukUpdatePhotosUI()
                } else {
                    self?.mukShowAlert(mukTitle: self?.mukErrorTitle, mukMessage: "Error Uploading Image")
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Utilities
    func mukTakePhotoWithCamera() {
        let mukImagePicker = UIImagePickerController()
        mukImagePicker.sourceType = .camera
        mukImagePicker.delegate = self
        mukImagePicker.allowsEditing = true
        
        present(mukImagePicker, animated: true, completion: nil)
    }
    
    func mukChoosePhotoFromLibrary() {
        let mukImagePicker = UIImagePickerController()
        mukImagePicker.sourceType = .photoLibrary
        mukImagePicker.delegate = self
        mukImagePicker.allowsEditing = true
        
        present(mukImagePicker, animated: true, completion: nil)
    }
    
    func mukChoosePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            mukShowPhotoMenu()
        } else {
            mukChoosePhotoFromLibrary()
        }
    }
    
    func mukShowPhotoMenu() {
        let mukAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let mukCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        mukAlert.addAction(mukCancelAction)
        
        let mukPhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {_ in
            self.mukTakePhotoWithCamera()
        })
        mukAlert.addAction(mukPhotoAction)
        
        let mukLibraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: {_ in
            self.mukChoosePhotoFromLibrary()
        })
        mukAlert.addAction(mukLibraryAction)
        
        present(mukAlert, animated: true, completion: nil)
     }
    
}

// MARK: UITextFieldDelegate Methods
extension MukLandlordListingDetailsViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            mukPresentAutoCompleteViewController()
        }
    }
}

// MARK: GMSAutocompleteViewControllerDelegate Methods
extension MukLandlordListingDetailsViewController: GMSAutocompleteViewControllerDelegate {
    
    // MARK: Methods
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        mukProcessPlace(mukPlace: place)
        dismiss(animated: true)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        dismiss(animated: true) { [weak self] in
            self?.mukShowAlert(mukTitle: self?.mukErrorTitle, mukMessage: "Google Place Error Getting Place Data")
        }
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true)
    }
    
    // MARK: Utilities
    func mukPresentAutoCompleteViewController() {
        let mukAutoCompleteVC = GMSAutocompleteViewController()
        mukAutoCompleteVC.delegate = self
        
        let mukFields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.addressComponents.rawValue) |
            UInt(GMSPlaceField.coordinate.rawValue))
        
        let mukFilter = GMSAutocompleteFilter()
        mukFilter.type = .address
        
        mukAutoCompleteVC.placeFields = mukFields
        mukAutoCompleteVC.autocompleteFilter = mukFilter
        
        present(mukAutoCompleteVC, animated: true)
    }
    
    func mukProcessPlace(mukPlace: GMSPlace) {
        var mukStreetNumber = ""
        var mukAddress = ""
        var mukCity = ""
        var mukState = ""
        var mukCountry = ""
        var mukZipCode = ""
        
        if let mukComponents = mukPlace.addressComponents {
            for mukComponent in mukComponents {
                let mukTypes = mukComponent.types
                if mukTypes.contains(kGMSPlaceTypeStreetNumber) {
                    mukStreetNumber = mukComponent.name
                } else if mukTypes.contains(kGMSPlaceTypeRoute) {
                    mukAddress = mukComponent.name
                } else if mukTypes.contains(kGMSPlaceTypeStreetAddress) {
                    mukAddress = mukComponent.name
                } else if mukTypes.contains(kGMSPlaceTypeLocality) {
                    mukCity = mukComponent.name
                } else if mukTypes.contains(kGMSPlaceTypeAdministrativeAreaLevel1) {
                    mukState = mukComponent.name
                } else if mukTypes.contains(kGMSPlaceTypeCountry) {
                    mukCountry = mukComponent.name
                } else if mukTypes.contains(kGMSPlaceTypePostalCode) {
                    mukZipCode = mukComponent.name
                }
            }
        }
        
        mukAddressTextField.text = "\(mukStreetNumber) \(mukAddress)"
        mukCityTextField.text = mukCity
        mukStateTextField.text = mukState
        mukCountryTextField.text = mukCountry
        mukZipCodeTextField.text = mukZipCode
        
        mukListing.mukLatitude = mukPlace.coordinate.latitude
        mukListing.mukLongitude = mukPlace.coordinate.longitude
    }
}
