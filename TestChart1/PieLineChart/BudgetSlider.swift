//
//  BudgetSlider.swift
//  TestChart1
//
//  Created by Anuwat Sittichak on 25/11/2561 BE.
//  Copyright © 2561 ANUWAT SITTICHAK. All rights reserved.
//

import UIKit

class BudgetSlider: UISlider {
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = super.trackRect(forBounds: bounds)
        newBounds.size.height = 5
        return newBounds
    }
    
}
