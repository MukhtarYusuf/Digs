//
//  MukListingsViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/30/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class MukListingsViewController: MukBaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukListingsTableView: UITableView!
    @IBOutlet weak var mukListingsMapView: MKMapView!
    @IBOutlet weak var mukAddBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var mukToggleButton: UIButton!
    
    // MARK: Constants
    let mukPublishedKey = "published"
    let mukUnpublishedKey = "unpublished"
    let muk1BedKey = "1Bed"
    let muk2BedKey = "2Bed"
    let muk3BedKey = "3Bed"
    let muk4BedKey = "4Bed"
    let muk1BathKey = "1Bath"
    let muk2BathKey = "2Bath"
    let muk3BathKey = "3Bath"
    let muk4BathKey = "4Bath"
    let mukHouseKey = "house"
    let mukApartmentKey = "apartment"
    let mukRoomKey = "room"

    let mukTopListingsRef = Database.database().reference().child("mukListings")
    let mukProfilesRef = Database.database().reference().child("mukProfiles")
    
    let mukListingCell = "MukListingCell"
    let mukNoResultsCell = "MukNoResultsCell"
    let mukListingsToEditListingDetail = "ListingsToEditListingDetail"
    let mukListingsToListingDetail = "ListingsToListingDetail"
    let mukListingsToSort = "ListingsToSort"
    let mukListingsToFilter = "ListingsToFilter"
    let mukListingsToAvailability = "ListingsToAvailability"
    
    // MARK: Variables
    var mukSearchBar: UISearchBar!
    var mukListingsFixed: [MukListing] = []
    var mukListings: [MukListing] = []
    var mukListingsHandle: DatabaseHandle?
    var mukProfileHandle: DatabaseHandle?
    var mukListingsRef: DatabaseReference?
    var mukProfileRef: DatabaseReference?
    var mukCurrentProfile = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile
    
    var mukSortChoice: MukSortChoice?
    var mukChosenFilters = [String : Bool]()
    var mukChosenPrice = 5001.0
    var mukIsFavorites = false
    var mukIsEmpty = false
    var mukIsShowingList = true
    
    // Sets for easy filtering. Firebase Realtime Database lacks proper "where" filters
    var mukPublishedListings = Set<MukListing>()
    var mukUnpublishedListings = Set<MukListing>()
    var muk1BedListings = Set<MukListing>()
    var muk2BedListings = Set<MukListing>()
    var muk3BedListings = Set<MukListing>()
    var muk4BedListings = Set<MukListing>()
    var muk1BathListings = Set<MukListing>()
    var muk2BathListings = Set<MukListing>()
    var muk3BathListings = Set<MukListing>()
    var muk4BathListings = Set<MukListing>()
    var mukHomeListings = Set<MukListing>()
    var mukApartmentListings = Set<MukListing>()
    var mukRoomListings = Set<MukListing>()
    
    // MARK: Action Methods
    @IBAction func mukToggleTapped(_ sender: UIButton) {
        if mukIsShowingList {
            mukShowMap()
        } else {
            mukShowList()
        }
    }
    
    @objc func mukEditListing(_ sender: UIButton) {
        guard let mukProfile = mukCurrentProfile else { return }
        
        if mukProfile.mukType == .mukTenant {
            performSegue(withIdentifier: mukListingsToListingDetail, sender: sender)
        } else if mukProfile.mukType == .mukLandlord {
            performSegue(withIdentifier: mukListingsToEditListingDetail, sender: sender)
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mukIdentifier = segue.identifier {
            if mukIdentifier == mukListingsToEditListingDetail,
                let mukDestinationVC = segue.destination as? MukLandlordListingDetailsViewController {
                
                if let mukIndexPath = sender as? IndexPath {
                    let mukListing = mukListings[mukIndexPath.row]
                    mukDestinationVC.mukListing = mukListing
                } else if let mukButton = sender as? UIButton {
                    let mukListing = mukListings[mukButton.tag]
                    mukDestinationVC.mukListing = mukListing
                }
            } else if mukIdentifier == mukListingsToListingDetail,
                let mukDestinationVC = segue.destination as? MukTenantListingDetailsViewController {
                
                if let mukIndexPath = sender as? IndexPath {
                    let mukListing = mukListings[mukIndexPath.row]
                    mukDestinationVC.mukListing = mukListing
                } else if let mukButton = sender as? UIButton {
                    let mukListing = mukListings[mukButton.tag]
                    mukDestinationVC.mukListing = mukListing
                }
            } else if mukIdentifier == mukListingsToSort,
                let mukDestinationVC = segue.destination as? MukSortViewController {
                mukDestinationVC.mukDelegate = self
                mukDestinationVC.mukSortChoice = mukSortChoice
            } else if mukIdentifier == mukListingsToFilter,
                let mukDestinationVC = segue.destination as? MukFilterViewController {
                mukDestinationVC.mukDelegate = self
                mukDestinationVC.mukChosenPrice = mukChosenPrice
                mukDestinationVC.mukChosenFilters = mukChosenFilters
            } else if mukIdentifier == mukListingsToAvailability,
                let mukDestinationVC = segue.destination as? MukCheckAvailabilityViewController,
                let mukIndexPath = sender as? IndexPath {
                mukDestinationVC.mukListing = mukListings[mukIndexPath.row]
            }
        }
    }
    
    // MARK: Utilities
    private func mukSetupModels() {
        guard let mukProfile = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile else {
            return
        }
        
        let mukProfileType = mukProfile.mukType
        if mukProfileType == .mukLandlord {
            mukListingsRef = mukTopListingsRef.child(mukProfile.mukUserId)
            mukListingsHandle = mukListingsRef?.observe(.value) { [weak self] snapshot in
                self?.mukListingsFixed.removeAll()
                self?.mukListings.removeAll()
                self?.mukClearSets()
                
                for mukListingChild in snapshot.children {
                    if let mukListingSnapshot = mukListingChild as? DataSnapshot,
                        let mukListing = MukListing(mukSnapshot: mukListingSnapshot) {
                        self?.mukListingsFixed.append(mukListing)
                        self?.mukListings.append(mukListing)
                        self?.mukPopulateSet(with: mukListing)
                    }
                }
                
                self?.mukUpdateUI()
            }
        } else if mukProfileType == .mukTenant {
            // Observe Listings for tenant
            mukListingsRef = mukTopListingsRef
            mukListingsHandle = mukListingsRef?.observe(.value) { [weak self] snapshot in
                self?.mukListingsFixed.removeAll()
                self?.mukListings.removeAll()
                self?.mukClearSets()
                
                for mukLandlordChild in snapshot.children {
                    if let mukLandlordSnapshot = mukLandlordChild as? DataSnapshot {
                        for mukListingChild in mukLandlordSnapshot.children {
                            if let mukChildSnapshot = mukListingChild as? DataSnapshot,
                                let mukListing = MukListing(mukSnapshot: mukChildSnapshot) {
                                if mukListing.mukIsPublished {
                                    self?.mukListingsFixed.append(mukListing)
                                    self?.mukListings.append(mukListing)
                                    self?.mukPopulateSet(with: mukListing)
                                }
                            }
                        }
                        
                        self?.mukUpdateUI()
                    }
                }
            }
            
            // Observe Tenant Profile for Favorites Added
            mukProfileRef = mukProfilesRef.child(mukProfile.mukUserId)
            mukProfileHandle = mukProfileRef?.observe(.value) { [weak self] snapshot in
                self?.mukCurrentProfile = MukProfile(mukSnapshot: snapshot)
                if self?.mukIsFavorites ?? false {
                    self?.mukUpdateFavorites()
                }
                self?.mukUpdateUI()
            }
        }
    }
    
    private func mukUpdateUI() {
        mukListingsTableView.reloadData()
        mukUpdateMapView()
    }
    
    func mukUpdateMapView() {
        let mukCurAnnotations = mukListingsMapView.annotations
        mukListingsMapView.removeAnnotations(mukCurAnnotations)
        mukListingsMapView.addAnnotations(mukListings)
        
        let mukMapRegion = region(for: mukListings)
        mukListingsMapView.setRegion(mukMapRegion, animated: true)
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        switch annotations.count {
        case 0:
            region = MKCoordinateRegion( center: mukListingsMapView.userLocation.coordinate,
                                         latitudinalMeters: 1000, longitudinalMeters: 1000)
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion(center: annotation.coordinate,
                                        latitudinalMeters: 1000, longitudinalMeters: 1000)
        default:
            var topLeft = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90, longitude: -180)
    
            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude, annotation.coordinate.longitude)
                bottomRight.latitude = min(bottomRight.latitude, annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
            }
    
            let centerLatitude = topLeft.latitude - (topLeft.latitude - bottomRight.latitude) / 2
            let centerLongitude = topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2
            let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
    
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude - bottomRight.latitude) *
                                            extraSpace,
                                        longitudeDelta: abs(topLeft.longitude - bottomRight.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        
        return mukListingsMapView.regionThatFits(region)
    }
    
    private func mukShowList() {
        mukListingsMapView.isHidden = true
        mukListingsTableView.isHidden = false
        mukToggleButton.setTitle("Map", for: .normal)
        mukIsShowingList = true
    }
    
    private func mukShowMap() {
        mukListingsTableView.isHidden = true
        mukListingsMapView.isHidden = false
        mukToggleButton.setTitle("List", for: .normal)
        mukIsShowingList = false
    }
    
    // MARK: Utilities - Sort
    private func mukSortListings() {
        guard let mukSortChoice = mukSortChoice else { return }
        
        mukListings.sort { listing1, listing2 in
            switch mukSortChoice {
            case .mukNewest:
                return listing1.mukDatePosted > listing2.mukDatePosted
            case .mukBeds:
                return listing1.mukBeds < listing2.mukBeds
            case .mukBaths:
                return listing1.mukBaths < listing2.mukBaths
            case .mukSquareFeet:
                return listing1.mukSquareFeet < listing2.mukSquareFeet
            case .mukPriceAsc:
                return listing1.mukPrice < listing2.mukPrice
            case .mukPriceDesc:
                return listing1.mukPrice > listing2.mukPrice
            }
        }
    }
    
    // MARK: Utilities - Filter
    private func mukFilterListings() {
        guard let mukProfile = mukCurrentProfile else { return }
        
        var mukFilteredListings = Set<MukListing>()
        for (mukKey, mukValue) in mukChosenFilters {
            if mukKey == mukPublishedKey, mukValue, mukProfile.mukType == .mukLandlord {
                mukFilteredListings.formUnion(mukPublishedListings)
            } else if mukKey == mukUnpublishedKey, mukValue, mukProfile.mukType == .mukLandlord {
                mukFilteredListings.formUnion(mukUnpublishedListings)
            } else if mukKey == muk1BedKey, mukValue {
                mukFilteredListings.formUnion(muk1BedListings)
            } else if mukKey == muk2BedKey, mukValue {
                mukFilteredListings.formUnion(muk2BedListings)
            } else if mukKey == muk3BedKey, mukValue {
                mukFilteredListings.formUnion(muk3BedListings)
            } else if mukKey == muk4BedKey, mukValue {
                mukFilteredListings.formUnion(muk4BedListings)
            } else if mukKey == muk1BathKey, mukValue {
                mukFilteredListings.formUnion(muk1BathListings)
            } else if mukKey == muk2BathKey, mukValue {
                mukFilteredListings.formUnion(muk2BathListings)
            } else if mukKey == muk3BathKey, mukValue {
                mukFilteredListings.formUnion(muk3BathListings)
            } else if mukKey == muk4BathKey, mukValue {
                mukFilteredListings.formUnion(muk4BathListings)
            } else if mukKey == mukHouseKey, mukValue {
                mukFilteredListings.formUnion(mukHomeListings)
            } else if mukKey == mukApartmentKey, mukValue {
                mukFilteredListings.formUnion(mukApartmentListings)
            } else if mukKey == mukRoomKey, mukValue {
                mukFilteredListings.formUnion(mukRoomListings)
            }
        }
            
        mukListings = [MukListing](mukFilteredListings)
        if mukChosenPrice <= 5000.0 {
            mukListings = mukListings.filter { listing in
                listing.mukPrice <= mukChosenPrice
            }
        }
    }
    
    private func mukUpdateFavorites() {
        guard let mukProfile = mukCurrentProfile else { return }
        
        mukListings = mukListingsFixed.filter { listing in
            return mukProfile.mukFavorites?[listing.mukListingId] ?? false
        }
    }
    
    private func mukPopulateSet(with mukListing: MukListing) {
        // Check Published or Unpublished
        if mukListing.mukIsPublished {
            mukPublishedListings.insert(mukListing)
        } else {
            mukUnpublishedListings.insert(mukListing)
        }
        
        // Check Beds
        if mukListing.mukBeds == 1 {
            muk1BedListings.insert(mukListing)
        } else if mukListing.mukBeds == 2 {
            muk2BedListings.insert(mukListing)
        } else if mukListing.mukBeds == 3 {
            muk3BedListings.insert(mukListing)
        } else if mukListing.mukBeds >= 4 {
            muk4BedListings.insert(mukListing)
        }
        
        // Check Baths
        if mukListing.mukBaths == 1 {
            muk1BathListings.insert(mukListing)
        } else if mukListing.mukBaths == 2 {
            muk2BathListings.insert(mukListing)
        } else if mukListing.mukBaths == 3 {
            muk3BathListings.insert(mukListing)
        } else if mukListing.mukBaths >= 4 {
            muk4BathListings.insert(mukListing)
        }
        
        // Check Type
        if mukListing.mukType == .mukHouse {
            mukHomeListings.insert(mukListing)
        } else if mukListing.mukType == .mukApartment {
            mukApartmentListings.insert(mukListing)
        } else if mukListing.mukType == .mukRoom {
            mukRoomListings.insert(mukListing)
        }
    }
    
    private func mukRemoveListingFromSets(mukListing: MukListing) {
        mukPublishedListings.remove(mukListing)
        mukUnpublishedListings.remove(mukListing)
        muk1BedListings.remove(mukListing)
        muk2BedListings.remove(mukListing)
        muk3BedListings.remove(mukListing)
        muk4BedListings.remove(mukListing)
        muk1BathListings.remove(mukListing)
        muk2BathListings.remove(mukListing)
        muk3BathListings.remove(mukListing)
        muk4BathListings.remove(mukListing)
        mukHomeListings.remove(mukListing)
        mukApartmentListings.remove(mukListing)
        mukRoomListings.remove(mukListing)
    }
    
    private func mukClearSets() {
        mukPublishedListings.removeAll()
        mukUnpublishedListings.removeAll()
        muk1BedListings.removeAll()
        muk2BedListings.removeAll()
        muk3BedListings.removeAll()
        muk4BedListings.removeAll()
        muk1BathListings.removeAll()
        muk2BathListings.removeAll()
        muk3BathListings.removeAll()
        muk4BathListings.removeAll()
        mukHomeListings.removeAll()
        mukApartmentListings.removeAll()
        mukRoomListings.removeAll()
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukSearchBar = UISearchBar()
        mukSearchBar.placeholder = "Search (e.g. City, Province)"
        mukSearchBar.searchTextField.backgroundColor = .white
        mukSearchBar.searchTextField.tintColor = .systemBlue
        mukSearchBar.delegate = self
        navigationItem.titleView = mukSearchBar
        
        mukAddBarButtonItem.isEnabled = mukCurrentProfile?.mukType == .mukLandlord
        
        let mukListingNib = UINib(nibName: mukListingCell, bundle: nil)
        mukListingsTableView.register(mukListingNib, forCellReuseIdentifier: mukListingCell)
        
        let mukNoResultsNib = UINib(nibName: mukNoResultsCell, bundle: nil)
        mukListingsTableView.register(mukNoResultsNib, forCellReuseIdentifier: mukNoResultsCell)
        
        mukSetupModels()
        
        mukListingsTableView.rowHeight = 350
        mukListingsTableView.dataSource = self
        mukListingsTableView.delegate = self
        mukListingsMapView.delegate = self
    }
    
    deinit {
        if let mukHandle = mukListingsHandle {
            mukListingsRef?.removeObserver(withHandle: mukHandle)
        }
        if let mukProfileHandle = mukProfileHandle {
            mukProfileRef?.removeObserver(withHandle: mukProfileHandle)
        }
    }
    
}

// MARK: UITableView DataSource, Delegate Methods
extension MukListingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mukListings.count == 0 {
            mukIsEmpty = true
            return 1
        } else {
            mukIsEmpty = false
            return mukListings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var mukCell: UITableViewCell
        
        if mukIsEmpty {
            mukCell = tableView.dequeueReusableCell(withIdentifier: mukNoResultsCell, for: indexPath)
        } else {
            mukCell = tableView.dequeueReusableCell(withIdentifier: mukListingCell, for: indexPath)
            let mukListing = mukListings[indexPath.row]
            
            if let mukCell = mukCell as? MukListingCell {
                mukCell.mukConfigure(with: mukListing)
                mukCell.mukDelegate = self
            }
        }
        
        return mukCell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if mukIsEmpty {
            return nil
        }
        
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let mukProfile = mukCurrentProfile else { return }
        
        if mukProfile.mukType == .mukLandlord {
            performSegue(withIdentifier: mukListingsToEditListingDetail, sender: indexPath)
        } else if mukProfile.mukType == .mukTenant {
            performSegue(withIdentifier: mukListingsToListingDetail, sender: indexPath)
        }
    }
    
}

// MARK: MukSortViewControllerDelegate Methods
extension MukListingsViewController: MukSortViewControllerDelegate {
    func mukDidSelectSort(mukSortChoice: MukSortChoice) {
        self.mukSortChoice = mukSortChoice
        
        mukSortListings()
        mukUpdateUI()
    }
}

// MARK: MukFilterViewControllerDelegate Methods
extension MukListingsViewController: MukFilterViewControllerDelegate {
    func mukDidSelectFilters(mukChosenFilters: [String : Bool], mukChosenPrice: Double) {
        self.mukChosenFilters = mukChosenFilters
        self.mukChosenPrice = mukChosenPrice
        
        mukFilterListings()
        mukUpdateUI()
    }
}

// MARK: MukListingCellDelegate Methods
extension MukListingsViewController: MukListingCellDelegate {
    func mukDidTapPublishButton(_ mukCell: MukListingCell) {
        guard let mukProfile = mukCurrentProfile,
            let mukIndexPath = mukListingsTableView.indexPath(for: mukCell)
            else {
                return
        }
        
        let mukListing = mukListings[mukIndexPath.row]
        if mukProfile.mukType == .mukTenant {
            performSegue(withIdentifier: mukListingsToAvailability, sender: mukIndexPath)
        } else if mukProfile.mukType == .mukLandlord {
            mukListing.mukIsPublished = !mukListing.mukIsPublished
            MukListing.mukUpdateListing(mukListing: mukListing)
        }
    }
    
    func mukDidTapFavoriteButton(_ mukCell: MukListingCell) {
        guard let mukProfile = mukCurrentProfile,
            mukProfile.mukType == .mukTenant,
            let mukIndexPath = mukListingsTableView.indexPath(for: mukCell)
            else {
                return
        }
        
        let mukListing = mukListings[mukIndexPath.row]
        
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
}

// MARK: UISearchBarDelegate Methods
extension MukListingsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        mukFilterListings(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mukFilterListings(with: searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
    
    // MARK: Utilities
    func mukFilterListings(with mukText: String) {
        if mukText.isEmpty {
            mukListings = mukListingsFixed
        } else {
            mukListings = mukListingsFixed.filter { listing in
                let mukStringToSearch = "\(listing.mukCity), \(listing.mukState)"
                return mukStringToSearch.contains(mukText)
            }
        }
        
        mukUpdateUI()
    }
}

// MARK: MKMapView Delegate
extension MukListingsViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MukListing else {
            return nil
        }
        
        let mukIdentifier = "MukListing"
        var mukAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: mukIdentifier)
        if mukAnnotationView == nil {
            let mukPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: mukIdentifier)
            mukPinView.isEnabled = true
            mukPinView.canShowCallout = true
            mukPinView.animatesDrop = false
            // Color R: 163, G: 75, B: 235, A: 1
            mukPinView.pinTintColor = UIColor(red: 163/255, green: 75/255, blue: 235/255, alpha: 1.0)
            
            let mukEditListingButton = UIButton(type: .detailDisclosure)
            mukEditListingButton.addTarget(self, action: #selector(mukEditListing), for: .touchUpInside)
            mukPinView.rightCalloutAccessoryView = mukEditListingButton
            
            mukAnnotationView = mukPinView
        }
        
        if let mukAnnotationView = mukAnnotationView {
            mukAnnotationView.annotation = annotation
            if let mukButton = mukAnnotationView.rightCalloutAccessoryView as? UIButton,
                let mukIndex = mukListings.firstIndex(of: annotation as! MukListing) {
                mukButton.tag = mukIndex
            }
        }
        
        return mukAnnotationView
    }
}
