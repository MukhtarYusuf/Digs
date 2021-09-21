//
//  MukEditProfileViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/7/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit
import Firebase

class MukEditProfileViewController: MukBaseTableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukProfileImageView: UIImageView!
    @IBOutlet weak var mukNameTextField: MukTextField!
    @IBOutlet weak var mukEmailTextField: MukTextField!
    @IBOutlet weak var mukPhoneTextField: MukTextField!
    
    // MARK: Constants
    let mukCurrentUser = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentUser
    let mukCurrentProfile = (UIApplication.shared.delegate as? AppDelegate)?.mukCurrentProfile
    let mukAlertTitle = "Alert"
    
    // MARK: Actions
    @IBAction func mukSaveTapped(_ sender: UIBarButtonItem) {
        mukSave()
    }
    
    @IBAction func mukDeleteTapped(_ sender: UIBarButtonItem) {
        let mukAlert = UIAlertController(title: mukAlertTitle,
                                         message: "Are you sure you want to delete your profile?",
                                         preferredStyle: .alert)
        let mukDeleteAction = UIAlertAction(title: "Delete",
                                            style: .destructive,
                                            handler: { [weak self] action in
                                                self?.mukDelete()
        })
        mukAlert.addAction(mukDeleteAction)
        
        let mukCancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        mukAlert.addAction(mukCancelAction)
        
        present(mukAlert, animated: true)
    }
    
    @IBAction func mukProfileImageTapped(_ sender: UITapGestureRecognizer) {
        mukChoosePhoto()
    }
    
    
    // MARK: Utilities
    private func mukUpdateUI() {
        guard let mukUser = mukCurrentUser, let mukProfile = mukCurrentProfile else { return }
        
        mukProfile.mukLoadPhoto(into: mukProfileImageView)
        mukNameTextField.text = mukProfile.mukName
        mukPhoneTextField.text = mukProfile.mukPhoneNo
        mukEmailTextField.text = mukUser.mukEmail
    }
    
    private func mukSave() {
        guard let mukProfile = mukCurrentProfile,
            let mukName = mukNameTextField.mukValidString,
            let mukEmail = mukEmailTextField.mukValidString
            else {
                mukShowAlert(mukTitle: mukAlertTitle, mukMessage: "Please validate fields")
                return
        }
        
        mukProfile.mukName = mukName
        mukProfile.mukPhoneNo = mukPhoneTextField.text ?? ""
        
        mukShowActivityIndicator()
        MukProfile.mukUpdateProfile(mukProfile: mukProfile) { [weak self] error in
            guard let mukWeakSelf = self else { return }
            
            if error != nil {
                mukWeakSelf.mukHideActivityIndicator()
                mukWeakSelf.mukShowAlert(mukTitle: mukWeakSelf.mukAlertTitle, mukMessage: "Firebase Save Error")
            } else {
                if let mukPhoto = mukWeakSelf.mukProfileImageView.image {
                    mukProfile.mukUploadPhoto(mukImage: mukPhoto) { error in
                        if error != nil {
                            mukWeakSelf.mukHideActivityIndicator()
                            mukWeakSelf.mukShowAlert(mukTitle: mukWeakSelf.mukAlertTitle, mukMessage: "Firebase Save Error")
                        } else {
                            Auth.auth().currentUser?.updateEmail(to: mukEmail) { error in
                                mukWeakSelf.mukHideActivityIndicator()
                                if error != nil {
                                    mukWeakSelf.mukShowAlert(mukTitle: mukWeakSelf.mukAlertTitle,
                                                             mukMessage: "Firebase Save Error")
                                } else {
                                    mukWeakSelf.mukShowSuccessView(mukMessage: "Saved") {
                                        mukWeakSelf.navigationController?.popViewController(animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func mukDelete() {
        guard let mukProfile = mukCurrentProfile else { return }
        
        mukShowActivityIndicator()
        MukProfile.mukDeleteProfile(mukProfile: mukProfile) { [weak self] error in
            guard let mukWeakSelf = self else { return }
            
            mukWeakSelf.mukHideActivityIndicator()
            if error != nil {
                mukWeakSelf.mukShowAlert(mukTitle: mukWeakSelf.mukAlertTitle, mukMessage: "Firebase Delete Error")
            } else {
                mukWeakSelf.mukShowSuccessView(mukMessage: "Deleted!") {
                    mukWeakSelf.navigationController?.tabBarController?.presentingViewController?.dismiss(animated: true)
                }
            }
        }
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukProfileImageView.layer.cornerRadius = mukProfileImageView.frame.width / 2
        mukProfileImageView.layer.borderWidth = 5.0
        mukProfileImageView.layer.borderColor = CGColor(srgbRed: 0.9,
                                                        green: 0.9, blue: 0.9, alpha: 1.0)
        
        mukUpdateUI()
    }
}

extension MukEditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Image Picker Delegates
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info:
        [UIImagePickerController.InfoKey : Any]) {
        
        dismiss(animated: true, completion: nil)
        
        if let mukChosenImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
            let mukProfile = mukCurrentProfile {
            mukShowActivityIndicator()
            mukProfile.mukUploadPhoto(mukImage: mukChosenImage) { [weak self] error in
                self?.mukHideActivityIndicator()
                if error != nil {
                    self?.mukShowAlert(mukTitle: self?.mukAlertTitle, mukMessage: "Firebase Upload Error")
                } else {
                    self?.mukProfileImageView.image = mukChosenImage
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

