//
//  TumbView.swift
//  TestChart1
//
//  Created by Feyverly on 24/11/2561 BE.
//  Copyright © 2561 ANUWAT SITTICCHAK. All rights reserved.
//

import UIKit

class TumbView: UIView {
    
    @IBOutlet weak var label: UILabel!
    
    var targetView: UIView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return targetView
    }
}
