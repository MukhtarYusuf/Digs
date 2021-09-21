//
//  MukSuccessView.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/29/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukSuccessView: UIView {
    // MARK: Outlets
    @IBOutlet var mukContentView: UIView!
    @IBOutlet weak var mukMessageLabel: UILabel!
    
    // MARK: Init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mukSetup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        mukSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        mukSetup()
    }
    
    // MARK: Utilities
    private func mukSetup() {
        isOpaque = false
        mukContentView = Bundle.main.loadNibNamed("MukSuccessView", owner: self, options: nil)?.first as? UIView
        mukContentView.layer.cornerRadius = 15.0
        mukContentView.clipsToBounds = true
        addSubview(mukContentView)
        
        mukContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: mukContentView!, attribute: .leading, relatedBy: .equal,
                           toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mukContentView!, attribute: .trailing, relatedBy: .equal,
                           toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mukContentView!, attribute: .top, relatedBy: .equal,
                           toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: mukContentView!, attribute: .bottom, relatedBy: .equal,
                           toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
    }
}
