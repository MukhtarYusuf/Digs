//
//  MukTextField.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 3/29/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukTextField: UITextField {
    
    // MARK: Computed Properties
    var mukValidString: String? {
        guard let mukString = text, !mukString.isEmpty else { return nil }
        
        return mukString
    }
    var mukValidInt: Int? {
        guard let mukString = text, !mukString.isEmpty else { return nil }
        
        return Int(mukString)
    }
    var mukValidDouble: Double? {
        guard let mukString = text, !mukString.isEmpty else { return nil }
        
        return Double(mukString)
    }
    
    // MARK: Lifecycle
//    override func awakeFromNib() {
//        super.awakeFromNib()
//
//        if isSecureTextEntry {
//            if #available(iOS 12, *) {
//                textContentType = .oneTimeCode
//            } else {
//                textContentType = .init(rawValue: "")
//            }
//        }
//    }
}
