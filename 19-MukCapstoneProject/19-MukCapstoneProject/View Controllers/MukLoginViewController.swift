//
//  MukLoginViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/29/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase

class MukLoginViewController: MukBaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukHeaderLabel: UILabel!
    @IBOutlet weak var mukEmailTextField: MukTextField!
    @IBOutlet weak var mukPasswordTextField: MukTextField!
    
    // MARK: Constants
    let mukLoginToSignUp = "LoginToSignUp"
    let mukLoginToHome = "LoginToHome"
    let mukErrorTitle = "Log In Error"
    let mukListingsNavigationController = "MukListingsNavigationController"
    let mukMessagesNavigationController = "MukMessagesNavigationController"
    let mukMoreNavigationController = "MukMoreNavigationController"
    let mukScreenNavigationController = "MukScreenNavigationController"
    
    // MARK: Variables
    var mukCurrentProfile: MukProfile?
    var mukProfileType: MukProfileType = .mukTenant
    
    // MARK: MukBaseViewController Methods
    override func mukSetupTextFieldDelegates() {
        super.mukSetupTextFieldDelegates()
        
        mukEmailTextField.delegate = self
        mukPasswordTextField.delegate = self
    }
    
    // MARK: Action Methods
    @IBAction func mukBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mukLogIn(_ sender: UIButton) {
        mukDoLogin()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mukIdentifier = segue.identifier {
            if mukIdentifier == mukLoginToSignUp, let mukSignupVC = segue.destination as? MukSignupViewController {
                mukSignupVC.mukProfileType = mukProfileType
            } else if mukIdentifier == mukLoginToHome, let mukTabBarVC = segue.destination as? UITabBarController {
                if let mukProfile = mukCurrentProfile {
                    if mukProfile.mukType == .mukTenant {
                        mukTabBarVC.viewControllers = mukViewControllersForTenant()
                    } else if mukProfile.mukType == .mukLandlord {
                        mukTabBarVC.viewControllers = mukViewControllersForLandlord()
                    }
                }
            }
        }
    }
    
    // MARK: Utilities
    private func mukUpdateUI() {
        switch mukProfileType {
        case .mukTenant:
            mukHeaderLabel.text = "Tenant Login"
        case .mukLandlord:
            mukHeaderLabel.text = "Landlord Login"
        }
    }
    
    private func mukDoLogin() {
        guard let mukEmail = mukEmailTextField.mukValidString,
            let mukPassword = mukPasswordTextField.mukValidString
            else {
                mukShowAlert(mukTitle: mukErrorTitle, mukMessage: "Please make sure input is valid")
                return
        }
        
        mukShowActivityIndicator()
        Auth.auth().signIn(withEmail: mukEmail, password: mukPassword) { [weak self] auth, error in
            guard let mukWeakSelf = self else { return }
            
            mukWeakSelf.mukHideActivityIndicator()
            if error != nil {
                mukWeakSelf.mukShowAlert(mukTitle: mukWeakSelf.mukErrorTitle, mukMessage: "Invalid email or password")
                return
            } else {
                guard let mukUser = auth?.user else { return }
                
                let mukProfileRef = Database.database().reference().child("mukProfiles").child(mukUser.uid)
                mukProfileRef.observeSingleEvent(of: .value) { snapshot in
                    mukWeakSelf.mukCurrentProfile = MukProfile(mukSnapshot: snapshot)
                    mukWeakSelf.performSegue(withIdentifier: mukWeakSelf.mukLoginToHome, sender: nil)
                }
            }
        }
    }
    
    private func mukGetNavListingsVC(mukTitle: String,
                                     mukImage: String,
                                     mukSelectedImage: String,
                                     mukIsFavorites: Bool) -> UIViewController? {
        guard let mukStoryboard = storyboard else { return nil }
        
        let mukNavListingsVC = mukStoryboard.instantiateViewController(identifier: mukListingsNavigationController)
        let mukListingsTabTitle = mukTitle
        let mukListingsTabImage = UIImage(named: mukImage)
        let mukListingsTabSelectedImage = UIImage(named: mukSelectedImage)
        
        let mukListingsTabBarItem = UITabBarItem(title: mukListingsTabTitle,
                                                 image: mukListingsTabImage, selectedImage: mukListingsTabSelectedImage)
        mukNavListingsVC.tabBarItem = mukListingsTabBarItem
        
        if let mukNavVC = mukNavListingsVC as? UINavigationController,
            let mukListingsVC = mukNavVC.viewControllers[0] as? MukListingsViewController {
            mukListingsVC.mukIsFavorites = mukIsFavorites
        }
        
        return mukNavListingsVC
    }
    
    private func mukGetNavMessagesVC() -> UIViewController? {
        guard let mukStoryboard = storyboard else { return nil }
        
        let mukNavMessagesVC = mukStoryboard.instantiateViewController(identifier: mukMessagesNavigationController)
        let mukMessagesTabTitle = "Messages"
        let mukMessagesTabImage = UIImage(named: "messages-gray")
        let mukMessagesSelectedImage = UIImage(named: "messages-purple")
        
        let mukMessagesTabBarItem = UITabBarItem(title: mukMessagesTabTitle,
                                                 image: mukMessagesTabImage,
                                                 selectedImage: mukMessagesSelectedImage)
        mukNavMessagesVC.tabBarItem = mukMessagesTabBarItem
        
        return mukNavMessagesVC
    }
    
    private func mukGetNavScreenVC() -> UIViewController? {
        guard let mukStoryboard = storyboard else { return nil }
        
        let mukNavScreenVC = mukStoryboard.instantiateViewController(identifier: mukScreenNavigationController)
        let mukScreenTabTitle = "Screening"
        let mukScreenTabImage = UIImage(named: "search-client-gray")
        let mukScreenSelectedImage = UIImage(named: "search-client-purple")
        
        let mukScreenTabBarItem = UITabBarItem(title: mukScreenTabTitle,
                                                 image: mukScreenTabImage,
                                                 selectedImage: mukScreenSelectedImage)
        mukNavScreenVC.tabBarItem = mukScreenTabBarItem
        
        return mukNavScreenVC
    }
    
    private func mukGetNavMoreVC() -> UIViewController? {
        guard let mukStoryboard = storyboard else { return nil }
        
        let mukNavMoreVC = mukStoryboard.instantiateViewController(identifier: mukMoreNavigationController)
        let mukMoreTabTitle = "More"
        let mukMoreTabImage = UIImage(named: "menu-gray")
        let mukMoreSelectedImage = UIImage(named: "menu-purple")
        
        let mukMoreTabBarItem = UITabBarItem(title: mukMoreTabTitle,
                                                 image: mukMoreTabImage,
                                                 selectedImage: mukMoreSelectedImage)
        mukNavMoreVC.tabBarItem = mukMoreTabBarItem
        
        return mukNavMoreVC
    }
    
    private func mukViewControllersForTenant() -> [UIViewController] {
        var mukControllers: [UIViewController] = []
        
        if let mukNavListingsVC = mukGetNavListingsVC(mukTitle: "Search",
                                                      mukImage: "search-gray",
                                                      mukSelectedImage: "search-purple",
                                                      mukIsFavorites: false) {
            mukControllers.append(mukNavListingsVC)
        }
        if let mukNavMessagesVC = mukGetNavMessagesVC() {
            mukControllers.append(mukNavMessagesVC)
        }
        if let mukNavFavoritesVC = mukGetNavListingsVC(mukTitle: "Favorites",
                                                      mukImage: "heart-gray",
                                                      mukSelectedImage: "heart-purple",
                                                      mukIsFavorites: true) {
            mukControllers.append(mukNavFavoritesVC)
        }
        if let mukNavMoreVC = mukGetNavMoreVC() {
            mukControllers.append(mukNavMoreVC)
        }
        
        return mukControllers
    }
    
    private func mukViewControllersForLandlord() -> [UIViewController] {
        var mukControllers: [UIViewController] = []
        
        if let mukNavListingsVC = mukGetNavListingsVC(mukTitle: "Home",
                                                      mukImage: "home-gray",
                                                      mukSelectedImage: "home-purple",
                                                      mukIsFavorites: false) {
            mukControllers.append(mukNavListingsVC)
        }
        if let mukNavMessagesVC = mukGetNavMessagesVC() {
            mukControllers.append(mukNavMessagesVC)
        }
        if let mukNavScreenVC = mukGetNavScreenVC() {
            mukControllers.append(mukNavScreenVC)
        }
        if let mukNavMoreVC = mukGetNavMoreVC() {
            mukControllers.append(mukNavMoreVC)
        }
        
        return mukControllers
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukUpdateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let mukProfile = mukCurrentProfile {
            // TODO: Perform Segue with identifier here
        }
    }
}
