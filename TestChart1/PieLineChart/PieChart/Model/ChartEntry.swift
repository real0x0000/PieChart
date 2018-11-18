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
    case other = 2
}

struct BudgetEntry {
    var budgetType: BudgetType
    var budget: Double
    var color: UIColor
    var image: UIImage?
    
    init(budgetType: BudgetType, budget: Double, color: UIColor, image: UIImage?) {
        self.budgetType = budgetType
        self.budget = budget
        self.color = color
        self.image = image
    }
}
