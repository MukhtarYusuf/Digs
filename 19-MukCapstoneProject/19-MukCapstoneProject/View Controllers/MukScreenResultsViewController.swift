//
//  MukScreenResultsViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/8/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukScreenResultsViewController: MukBaseViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukContentView: UIView!
    
    
    // MARK: Action Methods
    @IBAction func mukCloseTapped(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true)
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukContentView.layer.cornerRadius = 16.0
    }
}
