//
//  BudgetChartView.swift
//  TestChart1
//
//  Created by ANUWAT SITTICCHAK on 22/10/2561 BE.
//  Copyright © 2561 ANUWAT SITTICCHAK. All rights reserved.
//

import UIKit

class BudgetChartView: UIView {
    
    var chartEntries: [ChartEntry] = []
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var chartView: PieChart!
    @IBOutlet weak var flightSlider: UISlider!
    @IBOutlet weak var hotelSlider: UISlider!
    @IBOutlet weak var mealSlider: UISlider!
    @IBOutlet weak var otherSlider: UISlider!
    
    @IBAction func slide(_ sender: UISlider) {
        print(chartView.frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        view = loadNib()
        print(UIScreen.main.bounds)
        view.frame = UIScreen.main.bounds
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|",
                                                      options: [],
                                                      metrics: nil,
                                                      views: ["childView": view]))
        chartView.isUserInteractionEnabled = false
    }
    
    func setChartEntries(entries: [ChartEntry]) {
        chartEntries = entries
    }
    
    fileprivate func createModels(entries: [ChartEntry]) -> [PieSliceModel] {
        let sliceModels = entries.map { PieSliceModel(value: $0.value, color: $0.color) }
        return sliceModels
    }
    
    fileprivate func createCustomViewsLayer() -> PieCustomViewsLayer {
        let viewLayer = PieCustomViewsLayer()
        let settings = PieCustomViewsLayerSettings()
        settings.viewRadius = UIScreen.main.bounds.width / 3
        settings.hideOnOverflow = false
        viewLayer.settings = settings
        viewLayer.viewGenerator = createViewGenerator()
        return viewLayer
    }
    
    fileprivate func createTextLayer() -> PiePlainTextLayer {
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 75
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 12)
        textLayerSettings.label.textColor = UIColor.white
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        textLayerSettings.label.textGenerator = {slice in
            return formatter.string(from: slice.data.percentage * 100 as NSNumber).map{"\($0)%"} ?? ""
        }
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }
    
    fileprivate func createViewGenerator() -> (PieSlice, CGPoint) -> UIView {
        return { [weak self] slice, center in
            let container = UIView()
            container.frame.size = CGSize(width: 100, height: 40)
            container.center = center
            let view = UIImageView()
            view.backgroundColor = self?.chartEntries[slice.data.id].color
            view.frame = CGRect(x: 30, y: 0, width: 40, height: 40)
            view.layer.cornerRadius = view.frame.size.height / 2
            container.addSubview(view)
            view.image = self?.chartEntries[slice.data.id].image
            return container
        }
    }
    
    func updateChart() {
        chartView.models = createModels(entries: chartEntries)
        chartView.layers = [createCustomViewsLayer(), createTextLayer()]
    }
    
}

extension BudgetChartView {
    
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
}
