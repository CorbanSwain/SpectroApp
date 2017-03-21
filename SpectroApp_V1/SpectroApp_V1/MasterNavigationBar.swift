//
//  MasterNavigationBar.swift
//  SpectroApp_V1
//
//  Created by Corban Swain on 3/21/17.
//  Copyright © 2017 CorbanSwain. All rights reserved.
//

import UIKit

class MasterNavigationBar: UINavigationBar {

    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: (superview?.frame.width)!, height: 55)
    }
    
    override func layoutSubviews() {
         super.layoutSubviews()
        setTitleVerticalPositionAdjustment(-2, for: .default)
    }

}
