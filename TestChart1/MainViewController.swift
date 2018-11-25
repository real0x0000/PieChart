//
//  ViewController.swift
//  TestChart1
//
//  Created by ANUWAT SITTICHAK on 22/10/2561 BE.
//  Copyright © 2561 ANUWAT SITTICCHAK. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var budgetChart: BudgetChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChart()
    }
    
    func setupChart() {
        let flightEntry = BudgetEntry(budgetType: .flight, budget: 12000.0, color: UIColor(red: 34/255.0, green: 156/255.0, blue: 211/255.0, alpha: 1.0), image: UIImage(named: "flight"))
        let hotelEntry = BudgetEntry(budgetType: .hotel, budget: 10000.0, color: UIColor(red: 17/255.0, green: 207/255.0, blue: 159/255.0, alpha: 1.0), image: UIImage(named: "hotel"))
        let otherEntry = BudgetEntry(budgetType: .other, budget: 8000.0, color: UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha: 1.0), image: UIImage(named: "other"))
        let unusedBudget = BudgetEntry(budgetType: .unused, budget: 0.0, color: UIColor(red: 155/255.0, green: 155/255.0, blue: 1/255.0, alpha: 1.0), image: UIImage(named: "unused"))
        var dict: [BudgetType: BudgetEntry] = [:]
        dict[.flight] = flightEntry
        dict[.hotel] = hotelEntry
        dict[.other] = otherEntry
        dict[.unused] = unusedBudget
        budgetChart.delegate = self
        budgetChart.initChartValue(with: dict)
    }
    
}

extension MainViewController: BudgetChartDelegate {
    
    func currentBudget(budgetDict: [BudgetType : BudgetEntry]) {
        print(budgetDict)
    }
    
}
