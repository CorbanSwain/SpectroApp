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
//        print("resizing navbar! \n\t↳ MasterNavBar.sizeThatFits")
        super.sizeThatFits(size)
//        print("just finished super implementation ... resizing navbar! \n\t↳ MasterNavBar.sizeThatFits")
//        print("returning a size: {\((superview?.frame.width)!),55}  \n\t↳ MasterNavBar.sizeThatFits")
        return CGSize(width: (superview?.frame.width)!, height: 58)
    }
    
    override func layoutSubviews() {
//         print("laying out subviews! \n\t↳ MasterNavBar.layoutSubviews")
        super.layoutSubviews()
        setTitleVerticalPositionAdjustment(-2, for: .default)
    }

}
