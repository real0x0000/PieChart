//
//  BudgetChartView.swift
//  TestChart1
//
//  Created by ANUWAT SITTICCHAK on 22/10/2561 BE.
//  Copyright © 2561 ANUWAT SITTICHAK. All rights reserved.
//

import UIKit

protocol BudgetChartDelegate {
    func currentBudget(budgetDict: [BudgetType: BudgetEntry])
}

class BudgetChartView: UIView {
    
    var totalBudget: Double = 0.0
    var minFlightBudget: Double = 0.0
    var minHotelBudget: Double = 0.0
    var flightBudget: Double = 0.0
    var hotelBudget: Double = 0.0
    var otherBudget: Double = 0.0
    var budgetDict: [BudgetType: BudgetEntry] = [:]
    var delegate: BudgetChartDelegate?
    
    @IBAction func editBudget(_ sender: UIButton) {
        editBudgetView.isHidden = false
        budgetView.isHidden = true
        editBudgetButtonView.isHidden = true
    }
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var chartView: PieChart!
    @IBOutlet weak var flightSlider: UISlider!
    @IBOutlet weak var hotelSlider: UISlider!
    @IBOutlet weak var otherSlider: UISlider!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var editBudgetButton: UIButton!
    @IBOutlet weak var editBudgetButtonView: UIView!
    @IBOutlet weak var budgetView: UIView!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var editBudgetView: UIView!
    
    @IBAction func slideValueChanged(_ sender: UISlider) {
        switch sender {
        case flightSlider:
            if flightSlider.value < Float(minFlightBudget) {
                flightSlider.value = Float(minFlightBudget)
            }
            else if flightSlider.value > Float(totalBudget - hotelBudget) {
                flightSlider.value = Float(totalBudget - hotelBudget)
            }
            flightBudget = Double(flightSlider.value)
            otherSlider.value = Float(totalBudget - flightBudget - hotelBudget)
            otherBudget = totalBudget - flightBudget - hotelBudget
        case hotelSlider:
            if hotelSlider.value < Float(minHotelBudget) {
                hotelSlider.value = Float(minHotelBudget)
            }
            else if hotelSlider.value > Float(totalBudget - flightBudget) {
                hotelSlider.value = Float(totalBudget - flightBudget)
            }
            hotelBudget = Double(hotelSlider.value)
            otherSlider.value = Float(totalBudget - flightBudget - hotelBudget)
            otherBudget = totalBudget - flightBudget - hotelBudget
        case otherSlider:
            if otherSlider.value > Float(totalBudget - (flightBudget + hotelBudget)) {
                otherSlider.value = Float(totalBudget - (flightBudget + hotelBudget))
            }
            otherBudget = Double(otherSlider.value)
        default:
            break
        }
        updateDictValue()
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
        chartView.animDuration = 0.0001
        editBudgetView.isHidden = true
        flightSlider.isUserInteractionEnabled = true
        hotelSlider.isUserInteractionEnabled = true
        otherSlider.isUserInteractionEnabled = true
        flightSlider.isContinuous = false
        hotelSlider.isContinuous = false
        otherSlider.isContinuous = false
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(BudgetChartView.doneKeyboardInput))
        toolBar.items = [flexSpace, doneButton]
        budgetTextField.inputAccessoryView = toolBar
    }
    
    @objc func doneKeyboardInput() {
        self.view.endEditing(true)
        if let budgetInput = budgetTextField.text {
            if let dBudget = Double(budgetInput) {
                if dBudget < (minFlightBudget + minHotelBudget) {
                    
                }
                else {
                    if dBudget < totalBudget {
                        flightBudget = minFlightBudget
                        hotelBudget = minHotelBudget
                    }
                    totalBudget = dBudget
                    reCalculateBudget()
                }
                budgetTextField.text = "\(totalBudget)"
                budgetLabel.text = "\(totalBudget)"
                editBudgetView.isHidden = true
                budgetView.isHidden = false
                editBudgetButtonView.isHidden = false
            }
        }
    }
    
    func reCalculateBudget() {
        otherBudget = totalBudget - flightBudget - hotelBudget
        flightSlider.maximumValue = Float(totalBudget)
        hotelSlider.maximumValue = Float(totalBudget)
        otherSlider.maximumValue = Float(totalBudget)
        otherSlider.value = Float(otherBudget)
        flightSlider.value = Float(flightBudget)
        hotelSlider.value = Float(hotelBudget)
        updateDictValue()
    }
    
    func initChartValue(with dict: [BudgetType: BudgetEntry]) {
        var sumBudget: Double = 0.0
        budgetDict = dict
        budgetDict.forEach { (dict) in
            sumBudget += dict.value.budget
        }
        totalBudget = sumBudget
        budgetLabel.text = "\(totalBudget)"
        budgetTextField.text = "\(totalBudget)"
        if let flightEntry = budgetDict[.flight] {
            flightSlider.minimumTrackTintColor = flightEntry.color
            flightSlider.maximumTrackTintColor = flightEntry.color
            flightSlider.maximumValue = Float(totalBudget)
            flightSlider.value = Float(flightEntry.budget)
            minFlightBudget = flightEntry.budget
            flightBudget = flightEntry.budget
        }
        if let hotelEntry = budgetDict[.hotel] {
            hotelSlider.minimumTrackTintColor = hotelEntry.color
            hotelSlider.maximumTrackTintColor = hotelEntry.color
            hotelSlider.maximumValue = Float(totalBudget)
            hotelSlider.value = Float(hotelEntry.budget)
            minHotelBudget = hotelEntry.budget
            hotelBudget = hotelEntry.budget
        }
        if let otherEntry = budgetDict[.other] {
            otherSlider.minimumTrackTintColor = otherEntry.color
            otherSlider.maximumTrackTintColor = otherEntry.color
            otherSlider.maximumValue = Float(totalBudget)
            otherSlider.value = Float(otherEntry.budget)
        }
    }
    
    fileprivate func createModels(budgetDict: [BudgetType: BudgetEntry]) -> [PieSliceModel] {
        let sliceModels = budgetDict.map { PieSliceModel(value: $0.value.budget, color: $0.value.color) }
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
        return { slice, center in
            let container = UIView()
            container.frame.size = CGSize(width: 100, height: 40)
            container.center = center
            let view = UIImageView()
            view.backgroundColor = Array(self.budgetDict)[slice.data.id].value.color
            let entry = Array(self.budgetDict)[slice.data.id].value
            view.backgroundColor = entry.color
            view.frame = CGRect(x: 30, y: 0, width: 40, height: 40)
            view.layer.cornerRadius = view.frame.size.height / 2
            container.addSubview(view)
            view.image = entry.image?.withRenderingMode(.alwaysTemplate)
            view.tintColor = UIColor.white
            return container
        }
    }
    
    func updateDictValue() {
        budgetDict[.flight]?.budget = flightBudget
        budgetDict[.hotel]?.budget = hotelBudget
        budgetDict[.other]?.budget = otherBudget
        delegate?.currentBudget(budgetDict: budgetDict)
        updateChart()
    }
    
    func updateChart() {
        chartView.clear()
        chartView.models = createModels(budgetDict: budgetDict)
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
