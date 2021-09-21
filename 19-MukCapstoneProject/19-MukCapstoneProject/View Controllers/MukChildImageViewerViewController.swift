//
//  MukImageViewerViewController.swift
//  19-MukCapstoneProject
//
//  Created by Mukhtar Yusuf on 4/2/21.
//  Copyright © 2021 Mukhtar Yusuf. All rights reserved.
//

import UIKit

class MukChildImageViewerViewController: MukBaseViewController {
    // MARK: Outlets
    @IBOutlet weak var mukImageScrollView: UIScrollView!
    @IBOutlet weak var mukImageView: UIImageView!
    
    // MARK: Variables
    var mukListing: MukListing! // Pass the whole object to facilitate loading and deletion
    var mukIndex = 0
    
    // MARK: Utilities
    private func mukSetMinScaleForSize(_ mukSize: CGSize) {
        let mukWidthScale = mukSize.width / mukImageView.bounds.width
        let mukHeightScale = mukSize.height / mukImageView.bounds.height
        let mukMinScale = min(mukWidthScale, mukHeightScale)
        
        mukImageScrollView.minimumZoomScale = mukMinScale
        mukImageScrollView.maximumZoomScale = 2.0
        mukImageScrollView.zoomScale = mukMinScale
    }
    
    // MARK: ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mukImageScrollView.delegate = self
        mukListing.mukLoadPhoto(mukIndex: mukIndex, into: mukImageView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        mukSetMinScaleForSize(view.bounds.size)
    }
    
}

extension MukChildImageViewerViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mukImageView
    }
}
