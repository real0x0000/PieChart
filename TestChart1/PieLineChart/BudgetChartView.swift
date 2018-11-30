//
//  BudgetChartView.swift
//  TestChart1
//
//  Created by ANUWAT SITTICHAK on 22/10/2561 BE.
//  Copyright © 2561 ANUWAT SITTICHAK. All rights reserved.
//

import UIKit

protocol BudgetChartDelegate {
    func currentBudget(budgetDict: [BudgetType: BudgetEntry])
}

class BudgetChartView: UIView {
    
    var isValueChanged = false
    var totalBudget: Double = 0.0
    var minFlightBudget: Double = 0.0
    var minHotelBudget: Double = 0.0
    var totalStep = 0
    
    var flightBudget: Double = 0.0 {
        didSet{
            if !isValueChanged {
                isValueChanged = flightBudget != oldValue
            }
        }
    }
    var hotelBudget: Double = 0.0 {
        didSet{
            if !isValueChanged {
                isValueChanged = hotelBudget != oldValue
            }
        }
    }
    var otherBudget: Double = 0.0 {
        didSet{
            if !isValueChanged {
                isValueChanged = otherBudget != oldValue
            }
        }
    }
    var stepValue = 100
    var budgetDict: [BudgetType: BudgetEntry] = [:]
    var delegate: BudgetChartDelegate?
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var chartView: PieChart!
    @IBOutlet weak var flightSlider: SliderTextView!
    @IBOutlet weak var hotelSlider: SliderTextView!
    @IBOutlet weak var otherSlider: SliderTextView!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var editBudgetButton: UIButton!
    @IBOutlet weak var editBudgetButtonView: UIView!
    @IBOutlet weak var budgetView: UIView!
    @IBOutlet weak var budgetTextField: UITextField!
    @IBOutlet weak var editBudgetView: UIView!
    
    @IBAction func editBudget(_ sender: UIButton) {
        editBudgetView.isHidden = false
        budgetView.isHidden = true
        editBudgetButtonView.isHidden = true
        budgetTextField.becomeFirstResponder()
    }
    
    @objc func sliderDidEndSliding() {
        if isValueChanged {
            isValueChanged = false
            updateDictValue()
        }
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
        flightSlider.slider.addTarget(self, action: #selector(BudgetChartView.sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        hotelSlider.slider.addTarget(self, action: #selector(BudgetChartView.sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        otherSlider.slider.addTarget(self, action: #selector(BudgetChartView.sliderDidEndSliding), for: [.touchUpInside, .touchUpOutside])
        flightSlider.sliderType = .flight
        flightSlider.delegate = self
        hotelSlider.sliderType = .hotel
        hotelSlider.delegate = self
        otherSlider.sliderType = .other
        otherSlider.delegate = self
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(BudgetChartView.doneKeyboardInput))
        toolBar.items = [flexSpace, doneButton]
        budgetTextField.inputAccessoryView = toolBar
        budgetTextField.delegate = self
    }
    
    @objc func doneKeyboardInput() {
        self.view.endEditing(true)
        if let budgetInput = budgetTextField.text, let dBudget = Double(budgetInput) {
            let absBudget = roundAbsoluteStep(value: dBudget)
            if absBudget < (minFlightBudget + minHotelBudget) {
                //alert or do nothing
            }
            else {
                if absBudget < totalBudget {
                    flightBudget = minFlightBudget
                    hotelBudget = minHotelBudget
                }
                totalBudget = absBudget
                reCalculateBudget()
            }
            budgetTextField.text = "\(Int(totalBudget))"
            budgetLabel.text = "\(Int(totalBudget))"
            editBudgetView.isHidden = true
            budgetView.isHidden = false
            editBudgetButtonView.isHidden = false
        }
    }
    
    func reCalculateBudget() {
        otherBudget = totalBudget - flightBudget - hotelBudget
        flightSlider.maximumValue = Float(Int(totalBudget) / stepValue)
        hotelSlider.maximumValue = Float(Int(totalBudget) / stepValue)
        otherSlider.maximumValue = Float(Int(totalBudget) / stepValue)
        otherSlider.value = Float(Int(otherBudget) / stepValue)
        flightSlider.value = Float(Int(flightBudget) / stepValue)
        hotelSlider.value = Float(Int(hotelBudget) / stepValue)
        flightSlider.updateLabelPosition(flightSlider.value, step: stepValue)
        hotelSlider.updateLabelPosition(hotelSlider.value, step: stepValue)
        otherSlider.updateLabelPosition(otherSlider.value, step: stepValue)
        updateDictValue()
    }
    
    func initChartValue(with dict: [BudgetType: BudgetEntry]) {
        var sumBudget: Double = 0.0
        budgetDict = dict
        budgetDict.forEach { (dict) in
            sumBudget += dict.value.budget
        }
        totalBudget = sumBudget
        totalStep = Int(totalBudget) / stepValue
        budgetLabel.text = "\(Int(totalBudget))"
        budgetTextField.text = "\(Int(totalBudget))"
        if let flightEntry = budgetDict[.flight] {
            flightSlider.minimumTrackTintColor = flightEntry.color
            flightSlider.maximumTrackTintColor = flightEntry.color
            flightSlider.maximumValue = Float(totalStep)
            flightSlider.value = Float(Int(flightEntry.budget) / stepValue)
            minFlightBudget = flightEntry.budget
            flightBudget = flightEntry.budget
            flightSlider.updateLabelPosition(Float(flightSlider.value), step: stepValue)
        }
        if let hotelEntry = budgetDict[.hotel] {
            hotelSlider.minimumTrackTintColor = hotelEntry.color
            hotelSlider.maximumTrackTintColor = hotelEntry.color
            hotelSlider.maximumValue = Float(totalStep)
            hotelSlider.value = Float(Int(hotelEntry.budget) / stepValue)
            minHotelBudget = hotelEntry.budget
            hotelBudget = hotelEntry.budget
            hotelSlider.updateLabelPosition(Float(hotelSlider.value), step: stepValue)
        }
        if let otherEntry = budgetDict[.other] {
            otherSlider.minimumTrackTintColor = otherEntry.color
            otherSlider.maximumTrackTintColor = otherEntry.color
            otherSlider.maximumValue = Float(totalStep)
            otherSlider.value = Float(Int(otherEntry.budget) / stepValue)
            otherBudget = otherEntry.budget
            otherSlider.updateLabelPosition(Float(otherSlider.value), step: stepValue)
        }
        updateChart()
    }
    
    fileprivate func createModels(budgetDict: [BudgetType: BudgetEntry]) -> [PieSliceModel] {
        let sliceModels = budgetDict.filter({$0.value.budget > 0}).map { PieSliceModel(value: $0.value.budget, color: $0.value.color) }
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
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
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
            let array = Array(self.budgetDict.filter({$0.value.budget > 0}))
            view.backgroundColor = array[slice.data.id].value.color
            let entry = array[slice.data.id].value
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
    
    func roundAbsoluteStep(value: Double) -> Double {
        let mod = Int(value) % stepValue
        if mod >= (stepValue / 2) {
            return value + Double(stepValue - mod)
        }
        else {
            return value - Double(mod)
        }
    }
    
}

extension BudgetChartView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }
        guard let textFieldString = textField.text as NSString? else { return false }
        let newString = textFieldString.replacingCharacters(in: range, with: string)
        let intRegex = "^[1-9][0-9]*$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", intRegex)
        return predicate.evaluate(with: newString)
    }
    
}

extension BudgetChartView: SliderTextViewDelegate {
    func valueChanged(_ value: Float, type: BudgetType) {
        switch type {
        case .flight:
            let tempFlight = Double(Int(flightSlider.value) * stepValue)
            if tempFlight < minFlightBudget {
                flightBudget = minFlightBudget
                otherBudget = totalBudget - flightBudget - hotelBudget
            }
            else {
                let tempOther = totalBudget - tempFlight - hotelBudget
                if tempOther < 0 {
                    let tempHotel = hotelBudget + tempOther
                    if tempHotel < minHotelBudget {
                        hotelBudget = minHotelBudget
                        otherBudget = 0
                        flightBudget = totalBudget - minHotelBudget
                    }
                    else {
                        hotelBudget = tempHotel
                        otherBudget = 0
                        flightBudget = totalBudget - hotelBudget
                    }
                }
                else {
                    flightBudget = Double(tempFlight)
                    otherBudget = tempOther
                }
            }
        case .hotel:
            let tempHotel = Double(Int(hotelSlider.value) * stepValue)
            if tempHotel < minHotelBudget {
                hotelBudget = minHotelBudget
                otherBudget = totalBudget - flightBudget - hotelBudget
            }
            else {
                let tempOther = totalBudget - flightBudget - tempHotel
                if tempOther < 0 {
                    let tempFlight = flightBudget + tempOther
                    if tempFlight < minFlightBudget {
                        flightBudget = minFlightBudget
                        otherBudget = 0
                        hotelBudget = totalBudget - minFlightBudget
                    }
                    else {
                        flightBudget = tempFlight
                        otherBudget = 0
                        hotelBudget = totalBudget - flightBudget
                    }
                }
                else {
                    hotelBudget = Double(tempHotel)
                    otherBudget = tempOther
                }
            }
        case .other:
            var tempOther = Double(Int(otherSlider.value) * stepValue)
            if tempOther > totalBudget - (flightBudget + hotelBudget) {
                tempOther = totalBudget - (flightBudget + hotelBudget)
            }
            otherBudget = Double(tempOther)
            let unusedBudget = totalBudget - flightBudget - hotelBudget - otherBudget
            flightBudget = flightBudget + (unusedBudget / 2)
            hotelBudget = hotelBudget + (unusedBudget / 2)
        }
        flightSlider.value = Float(Int(flightBudget) / stepValue)
        hotelSlider.value = Float(Int(hotelBudget) / stepValue)
        otherSlider.value = Float(Int(otherBudget) / stepValue)
        flightSlider.updateLabelPosition(flightSlider.value, step: stepValue)
        hotelSlider.updateLabelPosition(hotelSlider.value, step: stepValue)
        otherSlider.updateLabelPosition(otherSlider.value, step: stepValue)
    }
}
