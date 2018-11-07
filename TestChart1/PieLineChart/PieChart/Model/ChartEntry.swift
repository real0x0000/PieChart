//
//  ChartEntry.swift
//  TestChart1
//
//  Created by ANUWAT SITTICCHAK on 22/10/2561 BE.
//  Copyright © 2561 ANUWAT SITTICHAK. All rights reserved.
//

import UIKit

enum BudgetType: Int {
    case flight = 0
    case hotel = 1
    case meal = 2
    case other = 3
}

struct ChartEntry {
    var budgetType: BudgetType
    var value: Double
    var color: UIColor
    var image: UIImage?
    
    init(budgetType: BudgetType, value: Double, color: UIColor, image: UIImage?) {
        self.budgetType = budgetType
        self.value = value
        self.color = color
        self.image = image
    }
}
