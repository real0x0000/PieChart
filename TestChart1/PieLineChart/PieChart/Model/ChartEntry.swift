//
//  ChartEntry.swift
//  TestChart1
//
//  Created by ANUWAT SITTICCHAK on 22/10/2561 BE.
//  Copyright © 2561 ANUWAT SITTICCHAK. All rights reserved.
//

import UIKit

struct ChartEntry {
    var id: Int
    var value: Double
    var color: UIColor
    var image: UIImage?
    
    init(id: Int, value: Double, color: UIColor, image: UIImage?) {
        self.id = id
        self.value = value
        self.color = color
        self.image = image
    }
}
