//
//  MukBaseTableViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/31/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukBaseTableViewController: UITableViewController {
    
    // MARK: Variables
    weak var mukIndicator: MukActivityIndicator!
    weak var mukSuccessView: MukSuccessView!
    
    // MARK: Methods
    func mukShowActivityIndicator() {
        mukSetVisibleFrame(for: mukIndicator)
        mukIndicator?.isHidden = false
        mukIndicator?.mukActivityIndicatorView.startAnimating()
    }
    
    func mukHideActivityIndicator() {
        mukIndicator?.isHidden = true
        mukIndicator?.mukActivityIndicatorView.stopAnimating()
    }
    
    func mukShowSuccessView(mukMessage: String? = nil, mukCompletion: (() -> Void)? = nil) {
        mukSetVisibleFrame(for: mukSuccessView)
        mukSuccessView?.mukMessageLabel.text = mukMessage ?? "Success"
        mukSuccessView?.isHidden = false
        mukSuccessView?.alpha = 1.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.mukHideSuccessView(mukCompletion: mukCompletion)
        }
    }
    
    func mukHideSuccessView(mukCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 1.5,
                       animations: {
                        self.mukSuccessView.alpha = 0.0
        }) { completed in
//            if completed {
//                self.mukSuccessView?.isHidden = true
//                self.mukSuccessView?.alpha = 1.0
//                mukCompletion?()
//            }
            self.mukSuccessView?.isHidden = true
            self.mukSuccessView?.alpha = 1.0
            mukCompletion?()
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
    
    // MARK: Utilities
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
    
    private func mukSetVisibleFrame(for mukView: UIView?) {
        guard let mukView = mukView else { return }
        
        let mukVisibleYCenter = tableView.contentOffset.y + tableView.visibleSize.height/2
        let mukVisibleXCenter = tableView.visibleSize.width/2
        
        mukView.center = CGPoint(x: mukVisibleXCenter, y: mukVisibleYCenter)
        mukView.frame.size.width = 90.0
        mukView.frame.size.height = 90.0
    }
    
    // MARK: ViewController Lifecycle
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        mukAddIndicatorSubview()
        mukAddSuccessSubView()
    }
    
}
