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
        // Do any additional setup after loading the view, typically from a nib.
        
        
//        flightSlider.setValue(40.0, animated: true)
//        hotelSlider.setValue(30.0, animated: true)
//        mealSlider.setValue(20.0, animated: true)
//        otherSlider.setValue(10.0, animated: true)
//        chartEntries.append(ChartEntry(id: 0, value: 40.0, color: UIColor(red: 34/255.0, green: 156/255.0, blue: 211/255.0, alpha: 1.0), image: UIImage(named: "flight")))
//        chartEntries.append(ChartEntry(id: 1, value: 30.0, color: UIColor(red: 17/255.0, green: 207/255.0, blue: 159/255.0, alpha: 1.0), image: UIImage(named: "hotel")))
//        chartEntries.append(ChartEntry(id: 2, value: 20.0, color: UIColor(red: 227/255.0, green: 110/255.0, blue: 19/255.0, alpha: 1.0), image: UIImage(named: "meal")))
//        chartEntries.append(ChartEntry(id: 3, value: 10.0, color: UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha: 1.0), image: UIImage(named: "other")))
        setupChart()
    }
    
    func setupChart() {
        let flightEntry = ChartEntry(id: 0, value: 40.0, color: UIColor(red: 34/255.0, green: 156/255.0, blue: 211/255.0, alpha: 1.0), image: UIImage(named: "flight"))
        let hotelEntry = ChartEntry(id: 1, value: 30.0, color: UIColor(red: 17/255.0, green: 207/255.0, blue: 159/255.0, alpha: 1.0), image: UIImage(named: "hotel"))
        let mealEntry = ChartEntry(id: 2, value: 20.0, color: UIColor(red: 227/255.0, green: 110/255.0, blue: 19/255.0, alpha: 1.0), image: UIImage(named: "meal"))
        let otherEntry = ChartEntry(id: 3, value: 10.0, color: UIColor(red: 155/255.0, green: 155/255.0, blue: 155/255.0, alpha: 1.0), image: UIImage(named: "other"))
        let entries = [flightEntry, hotelEntry, mealEntry, otherEntry]
        budgetChart.setChartEntries(entries: entries)
        budgetChart.updateChart()
    }
    
}
