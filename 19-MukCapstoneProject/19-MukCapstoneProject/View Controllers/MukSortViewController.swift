//
//  MukSortViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/3/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

enum MukSortChoice: String, CaseIterable {
    case mukNewest = "Newest"
    case mukBeds = "Bedrooms"
    case mukBaths = "Bathrooms"
    case mukSquareFeet = "Square Feet"
    case mukPriceAsc = "Price (Ascending)"
    case mukPriceDesc = "Price (Descending)"
}

protocol MukSortViewControllerDelegate: class {
    func mukDidSelectSort(mukSortChoice: MukSortChoice)
}

class MukSortViewController: MukBaseTableViewController {
    
    // MARK: Variables
    var mukSortChoice: MukSortChoice?
    weak var mukDelegate: MukSortViewControllerDelegate?
    
    // MARK: UITableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MukSortChoice.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mukCell = tableView.dequeueReusableCell(withIdentifier: "SortCell", for: indexPath)
        let mukTitle = MukSortChoice.allCases[indexPath.row].rawValue
        
        mukCell.textLabel?.text = mukTitle
        if let mukSelected = mukSortChoice,
            let mukIndex = MukSortChoice.allCases.firstIndex(of: mukSelected),
            mukIndex == indexPath.row {
            mukCell.accessoryType = .checkmark
        }
        
        return mukCell
    }
    
    // MARK: UITableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        mukSortChoice = MukSortChoice.allCases[indexPath.row]
        tableView.reloadData()
        
        mukDelegate?.mukDidSelectSort(mukSortChoice: mukSortChoice!) // Already populated sort choice
        navigationController?.popViewController(animated: true)
    }
    
}
