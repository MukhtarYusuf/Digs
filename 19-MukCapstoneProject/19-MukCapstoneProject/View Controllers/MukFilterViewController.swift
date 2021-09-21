//
//  MukFilterViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/3/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

protocol MukFilterViewControllerDelegate: class {
    func mukDidSelectFilters(mukChosenFilters: [String:Bool], mukChosenPrice: Double)
}

class MukFilterViewController: MukBaseTableViewController {
    
    // MARK: Outlets
    @IBOutlet weak var mukPublishedSwitch: UISwitch!
    @IBOutlet weak var mukUnpublishedSwitch: UISwitch!
    @IBOutlet weak var mukPriceLabel: UILabel!
    @IBOutlet weak var mukPriceSlider: UISlider!
    @IBOutlet weak var muk1BedSwitch: UISwitch!
    @IBOutlet weak var muk2BedSwitch: UISwitch!
    @IBOutlet weak var muk3BedSwitch: UISwitch!
    @IBOutlet weak var muk4BedSwitch: UISwitch!
    @IBOutlet weak var muk1BathSwitch: UISwitch!
    @IBOutlet weak var muk2BathSwitch: UISwitch!
    @IBOutlet weak var muk3BathSwitch: UISwitch!
    @IBOutlet weak var muk4BathSwitch: UISwitch!
    @IBOutlet weak var mukHouseSwitch: UISwitch!
    @IBOutlet weak var mukApartmentSwitch: UISwitch!
    @IBOutlet weak var mukRoomSwitch: UISwitch!
    
    // MARK: Constants
    let mukProfile = (UIApplication.shared.delegate as! AppDelegate).mukCurrentProfile
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
    
    // MARK: Variables
    weak var mukDelegate: MukFilterViewControllerDelegate?
    var mukChosenPrice = 5001.0
    var mukDefaultFilters = [String : Bool]()
    var mukChosenFilters = [String : Bool]()
    
    // MARK: UITableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let mukProfile = mukProfile, mukProfile.mukType == .mukTenant, section == 0 {
            return 0
        }
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    // MARK: UITableView Delegete Methods
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let mukProfile = mukProfile, mukProfile.mukType == .mukTenant, section == 0 {
            return 0.1
        }
        
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let mukProfile = mukProfile, mukProfile.mukType == .mukTenant, section == 0 {
            return 0.1
        }
        
        return super.tableView(tableView, heightForFooterInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let mukProfile = mukProfile, mukProfile.mukType == .mukTenant, section == 0 {
            let mukHeader = view as! UITableViewHeaderFooterView
            mukHeader.textLabel?.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let mukProfile = mukProfile, mukProfile.mukType == .mukTenant, section == 0 {
            let mukFooter = view as! UITableViewHeaderFooterView
            mukFooter.textLabel?.isHidden = true
        }
    }
    
    // MARK: Action Methods
    @IBAction func mukResetFiltersTapped(_ sender: UIBarButtonItem) {
        mukChosenPrice = 5001.0
        mukChosenFilters = mukDefaultFilters
        
        mukUpdateUI()
    }
    
    @IBAction func mukDoneTapped(_ sender: UIBarButtonItem) {
        mukDelegate?.mukDidSelectFilters(mukChosenFilters: mukChosenFilters, mukChosenPrice: mukChosenPrice)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func mukSliderChanged(_ sender: UISlider) {
        let mukSliderValue = sender.value
        mukChosenPrice = Double(mukSliderValue)
        mukUpdatePriceLabel()
    }
    
    @IBAction func mukSwitchTapped(_ sender: UISwitch) {
        if sender == mukPublishedSwitch {
            mukChosenFilters[mukPublishedKey] = sender.isOn
        } else if sender == mukUnpublishedSwitch {
            mukChosenFilters[mukUnpublishedKey] = sender.isOn
        } else if sender == muk1BedSwitch {
            mukChosenFilters[muk1BedKey] = sender.isOn
        } else if sender == muk2BedSwitch {
            mukChosenFilters[muk2BedKey] = sender.isOn
        } else if sender == muk3BedSwitch {
            mukChosenFilters[muk3BedKey] = sender.isOn
        } else if sender == muk4BedSwitch {
            mukChosenFilters[muk4BedKey] = sender.isOn
        } else if sender == muk1BathSwitch {
            mukChosenFilters[muk1BathKey] = sender.isOn
        } else if sender == muk2BathSwitch {
            mukChosenFilters[muk2BathKey] = sender.isOn
        } else if sender == muk3BathSwitch {
            mukChosenFilters[muk3BathKey] = sender.isOn
        } else if sender == muk4BathSwitch {
            mukChosenFilters[muk4BathKey] = sender.isOn
        } else if sender == mukHouseSwitch {
            mukChosenFilters[mukHouseKey] = sender.isOn
        } else if sender == mukApartmentSwitch {
            mukChosenFilters[mukApartmentKey] = sender.isOn
        } else if sender == mukRoomSwitch {
            mukChosenFilters[mukRoomKey] = sender.isOn
        }
    }
    
    // MARK: Utilities
    private func mukUpdateUI() {
        mukPriceSlider.setValue(Float(mukChosenPrice), animated: true)
        mukUpdatePriceLabel()
        
        for (mukKey, mukValue) in mukChosenFilters {
            if mukKey == mukPublishedKey {
                mukPublishedSwitch.setOn(mukValue, animated: true)
            } else if mukKey == mukUnpublishedKey {
                mukUnpublishedSwitch.setOn(mukValue, animated: true)
            } else if mukKey == muk1BedKey {
                muk1BedSwitch.setOn(mukValue, animated: true)
            } else if mukKey == muk2BedKey {
                muk2BedSwitch.setOn(mukValue, animated: true)
            } else if mukKey == muk3BedKey {
                muk3BedSwitch.setOn(mukValue, animated: true)
            } else if mukKey == muk4BedKey {
                muk4BedSwitch.setOn(mukValue, animated: true)
            } else if mukKey == muk1BathKey {
                muk1BathSwitch.setOn(mukValue, animated: true)
            } else if mukKey == muk2BathKey {
                muk2BathSwitch.setOn(mukValue, animated: true)
            } else if mukKey == muk3BathKey {
                muk3BathSwitch.setOn(mukValue, animated: true)
            } else if mukKey == muk4BathKey {
                muk4BathSwitch.setOn(mukValue, animated: true)
            } else if mukKey == mukHouseKey {
                mukHouseSwitch.setOn(mukValue, animated: true)
            } else if mukKey == mukApartmentKey {
                mukApartmentSwitch.setOn(mukValue, animated: true)
            } else if mukKey == mukRoomKey {
                mukRoomSwitch.setOn(mukValue, animated: true)
            }
        }
    }
    
    private func mukUpdatePriceLabel() {
        mukPriceLabel.text = "$1 - $\(Int(mukChosenPrice))"
        if mukChosenPrice > 5000.0 {
            mukPriceLabel.text = "$1 - $\(Int(mukChosenPrice))+"
        }
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukDefaultFilters = [
            mukPublishedKey: true,
            mukUnpublishedKey: true,
            muk1BedKey: true,
            muk2BedKey: true,
            muk3BedKey: true,
            muk4BedKey: true,
            muk1BathKey: true,
            muk2BathKey: true,
            muk3BathKey: true,
            muk4BathKey: true,
            mukHouseKey: true,
            mukApartmentKey: true,
            mukRoomKey: true
        ]
        
        if mukChosenFilters.count == 0 {
            mukChosenFilters = mukDefaultFilters
        }
        
        mukUpdateUI()
    }
}
