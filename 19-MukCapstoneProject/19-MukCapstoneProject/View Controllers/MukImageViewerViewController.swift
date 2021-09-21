//
//  MukImageViewerViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/2/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukImageViewerViewController: UIPageViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukDeleteButton: UIBarButtonItem!
    
    // MARK: Constants
    let mukCurrentProfile = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile
    let mukChildImageViewerId = "MukChildImageViewerViewController"
    let mukAlertTitle = "Alert"
    
    // MARK: Variables
    var mukListing: MukListing!
    var mukCurrentIndex = 0 {
        didSet {
            mukUpdateTitle()
        }
    }
    var mukOriginalNavColor: UIColor!
    
    @IBAction func mukDeletePhotoTapped(_ sender: UIBarButtonItem) {
        mukDeletePhoto()
    }
    
    // MARK: Utilities
    private func mukCreateChildImageViewer(_ mukIndex: Int) -> MukChildImageViewerViewController? {
        guard let mukStoryboard = storyboard,
            let mukChildImageViewerVC = mukStoryboard.instantiateViewController(withIdentifier: mukChildImageViewerId) as?
                MukChildImageViewerViewController
            else {
                return nil
        }
        
        mukChildImageViewerVC.mukListing = mukListing
        mukChildImageViewerVC.mukIndex = mukIndex
        
        return mukChildImageViewerVC
    }
    
    private func mukUpdateTitle() {
        title = "\(mukCurrentIndex+1) of \(mukListing.mukPhotos?.count ?? mukCurrentIndex)"
    }
    
    private func mukDeletePhoto() {
        mukListing.mukDeletePhoto(mukIndex: mukCurrentIndex) { [weak self] error in
            guard let mukWeakSelf = self else { return }
            
            if error == nil {
                let mukNextValidIndex = mukWeakSelf.mukGetNextValidIndex()
                let mukDirection: NavigationDirection =
                    (mukNextValidIndex < mukWeakSelf.mukCurrentIndex) ? .reverse : .forward
                
                if mukNextValidIndex != -1 {
                    mukWeakSelf.mukCurrentIndex = mukNextValidIndex
                    mukWeakSelf.mukSetViewControllers(mukDirection: mukDirection, mukAnimated: true)
                } else {
                    mukWeakSelf.mukDisplayAlert(mukMessage: "No More Photos") {
                        mukWeakSelf.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                print(error!)
                mukWeakSelf.mukDisplayAlert(mukMessage: "Firebase Error Deleting Image")
            }
        }
    }
    
    private func mukDisplayAlert(mukMessage: String?, mukAction: (() -> Void)? = nil) {
        let mukAlert = UIAlertController(title: mukAlertTitle,
                                         message: mukMessage,
                                         preferredStyle: .alert)
        let mukAction = UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: {_ in
                                        mukAction?()
        })
        
        mukAlert.addAction(mukAction)
        present(mukAlert, animated: true)
    }
    
    private func mukGetNextValidIndex() -> Int {
        guard let mukPhotos = mukListing.mukPhotos,
            mukPhotos.count > 0
            else {
                return -1
        }
        
        var mukValidIndex = mukCurrentIndex
        if mukValidIndex < mukPhotos.count {
            return mukValidIndex
        } else {
            mukValidIndex -= 1
            return mukValidIndex
        }
    }
    
    private func mukSetViewControllers(mukDirection:NavigationDirection, mukAnimated: Bool) {
        if let mukChildImageViewerVC = mukCreateChildImageViewer(mukCurrentIndex) {
            let mukViewControllers = [mukChildImageViewerVC]
        
            setViewControllers(mukViewControllers, direction: mukDirection, animated: mukAnimated, completion: nil)
        }
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mukProfile = mukCurrentProfile {
            mukDeleteButton.isEnabled = mukProfile.mukType == .mukLandlord
        }
        mukUpdateTitle()
        
        tabBarController?.tabBar.isHidden = true

        mukOriginalNavColor = navigationController?.navigationBar.barTintColor
        navigationController?.navigationBar.barTintColor = .black
        
        mukSetViewControllers(mukDirection: .forward, mukAnimated: true)
        dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.barTintColor = mukOriginalNavColor
    }
}

extension MukImageViewerViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let mukChildViewController = viewController as? MukChildImageViewerViewController {
            mukCurrentIndex = mukChildViewController.mukIndex
            
            if mukChildViewController.mukIndex > 0 {
                return mukCreateChildImageViewer(mukChildViewController.mukIndex-1)
            }
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let mukChildViewController = viewController as? MukChildImageViewerViewController {
            mukCurrentIndex = mukChildViewController.mukIndex
            
            if mukChildViewController.mukIndex < (mukListing.mukPhotos?.count ?? 0) - 1 {
                return mukCreateChildImageViewer(mukChildViewController.mukIndex+1)
            }
        }
        
        return nil
    }
}
