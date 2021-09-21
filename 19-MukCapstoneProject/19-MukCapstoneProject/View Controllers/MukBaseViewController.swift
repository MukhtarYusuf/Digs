//
//  MukBaseViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/28/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukBaseViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mukScrollView: UIScrollView!
    
    // MARK: Variables
    weak var mukActiveTextField: UITextField!
    weak var mukIndicator: MukActivityIndicator!
    weak var mukSuccessView: MukSuccessView!
    
    // MARK: UITextFieldDelegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        mukActiveTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        mukActiveTextField = nil
    }
    
    // MARK: Action Methods
    @objc private func mukDissmissKeyboard(mukSender: UITapGestureRecognizer) {
        mukActiveTextField?.resignFirstResponder()
    }
    
    // MARK: Methods
    func mukShowActivityIndicator() {
        mukIndicator?.isHidden = false
        mukIndicator?.mukActivityIndicatorView.startAnimating()
    }
    
    func mukHideActivityIndicator() {
        mukIndicator?.isHidden = true
        mukIndicator?.mukActivityIndicatorView.stopAnimating()
    }
    
    func mukShowSuccessView(mukMessage: String? = nil, mukCompletion: (() -> Void)? = nil) {
        mukSuccessView?.mukMessageLabel.text = mukMessage ?? "Success"
        mukSuccessView?.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.mukHideSuccessView(mukCompletion: mukCompletion)
        }
    }
    
    func mukHideSuccessView(mukCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 1.5,
                       animations: {
                        self.mukSuccessView.alpha = 0.0
        }) { completed in
            if completed {
                self.mukSuccessView?.isHidden = true
                self.mukSuccessView?.alpha = 1.0
                mukCompletion?()
            }
        }
    }
    
    func mukShowAlert(mukTitle: String?, mukMessage: String?) {
        let mukAlert = UIAlertController(title: mukTitle,
                                         message: mukMessage,
                                         preferredStyle: .alert)
        let mukAction = UIAlertAction(title: "Ok", style: .default)
        
        mukAlert.addAction(mukAction)
        present(mukAlert, animated: true)
    }
    
    // MARK: Keyboard Notifications
    @objc func mukHandleKeyboardDidShow(mukNotification: Notification) {
        guard let mukValue = mukNotification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let mukScrollView = mukScrollView,
            let mukTextField = mukActiveTextField
            else {
                return
        }
        
        let mukKbSize = mukValue.cgRectValue.size
        let mukContentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: mukKbSize.height, right: 0.0)
        
        mukScrollView.contentInset = mukContentInsets
        mukScrollView.scrollIndicatorInsets = mukContentInsets
        
        var mukViewRect = self.view.frame
        mukViewRect.size.height -= mukKbSize.height
        
        if mukViewRect.contains(mukTextField.frame.origin) {
            mukScrollView.scrollRectToVisible(mukTextField.frame, animated: true)
        }
    }
    
    @objc func mukHandleKeyboardWillHide(mukNotification: Notification) {
        let mukContentInsets = UIEdgeInsets.zero
        mukScrollView?.contentInset = mukContentInsets
        mukScrollView?.scrollIndicatorInsets = mukContentInsets
    }
    
    // MARK: Utilities
    private func mukRegisterKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mukHandleKeyboardDidShow(mukNotification:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mukHandleKeyboardWillHide(mukNotification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func mukAddTapGestureToRootView() {
        let mukTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mukDissmissKeyboard(mukSender:)))
        mukTapGestureRecognizer.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(mukTapGestureRecognizer)
    }
    
    private func mukAddIndicatorSubview() {
        if self.mukIndicator != nil {
            return
        }
        
        let mukIndicator = MukActivityIndicator()
        mukIndicator.center = view.center
        mukIndicator.bounds.size.width = 90.0
        mukIndicator.bounds.size.height = 90.0
        
        view.addSubview(mukIndicator)
        self.mukIndicator = mukIndicator
        self.mukIndicator.isHidden = true
    }
    
    private func mukAddSuccessSubView() {
        if self.mukSuccessView != nil {
            return
        }
        
        let mukSuccessView = MukSuccessView()
        mukSuccessView.center = view.center
        mukSuccessView.bounds.size.width = 90.0
        mukSuccessView.bounds.size.height = 90.0
        
        view.addSubview(mukSuccessView)
        self.mukSuccessView = mukSuccessView
        self.mukSuccessView.isHidden = true
    }
    
    func mukSetupTextFieldDelegates() {
        
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukRegisterKeyboardNotifications()
        mukAddTapGestureToRootView()
        mukSetupTextFieldDelegates()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        mukScrollView?.contentSize = mukScrollView.frame.size
        mukAddIndicatorSubview()
        mukAddSuccessSubView()
    }
    
    @IBAction func testSuccess(_ sender: UIButton) {
//        mukShowSuccessView(mukMessage: nil)
        mukShowAlert(mukTitle: "Error", mukMessage: "Could Not do Something")
    }
}
