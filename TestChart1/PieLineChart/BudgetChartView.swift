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
            if dBudget < (minFlightBudget + minHotelBudget) {
                //alert or do nothing
            }
            else {
                if dBudget < totalBudget {
                    flightBudget = minFlightBudget
                    hotelBudget = minHotelBudget
                }
                totalBudget = dBudget
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
        flightSlider.maximumValue = Float(totalBudget)
        hotelSlider.maximumValue = Float(totalBudget)
        otherSlider.maximumValue = Float(totalBudget)
        otherSlider.value = Float(otherBudget)
        flightSlider.value = Float(flightBudget)
        hotelSlider.value = Float(hotelBudget)
        flightSlider.updateLabelPosition(Float(flightBudget))
        hotelSlider.updateLabelPosition(Float(hotelBudget))
        otherSlider.updateLabelPosition(Float(otherBudget))
        updateDictValue()
    }
    
    func initChartValue(with dict: [BudgetType: BudgetEntry]) {
        var sumBudget: Double = 0.0
        budgetDict = dict
        budgetDict.forEach { (dict) in
            sumBudget += dict.value.budget
        }
        totalBudget = sumBudget
        budgetLabel.text = "\(Int(totalBudget))"
        budgetTextField.text = "\(Int(totalBudget))"
        if let flightEntry = budgetDict[.flight] {
            flightSlider.minimumTrackTintColor = flightEntry.color
            flightSlider.maximumTrackTintColor = flightEntry.color
            flightSlider.maximumValue = Float(totalBudget)
            flightSlider.value = Float(flightEntry.budget)
            minFlightBudget = flightEntry.budget
            flightBudget = flightEntry.budget
            flightSlider.updateLabelPosition(Float(flightEntry.budget))
        }
        if let hotelEntry = budgetDict[.hotel] {
            hotelSlider.minimumTrackTintColor = hotelEntry.color
            hotelSlider.maximumTrackTintColor = hotelEntry.color
            hotelSlider.maximumValue = Float(totalBudget)
            hotelSlider.value = Float(hotelEntry.budget)
            minHotelBudget = hotelEntry.budget
            hotelBudget = hotelEntry.budget
            hotelSlider.updateLabelPosition(Float(hotelEntry.budget))
        }
        if let otherEntry = budgetDict[.other] {
            otherSlider.minimumTrackTintColor = otherEntry.color
            otherSlider.maximumTrackTintColor = otherEntry.color
            otherSlider.maximumValue = Float(totalBudget)
            otherSlider.value = Float(otherEntry.budget)
            otherBudget = otherEntry.budget
            otherSlider.updateLabelPosition(Float(otherEntry.budget))
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
            let tempFlight = Double(flightSlider.value)
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
            let tempHotel = Double(hotelSlider.value)
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
            if otherSlider.value > Float(totalBudget - (flightBudget + hotelBudget)) {
                otherSlider.value = Float(totalBudget - (flightBudget + hotelBudget))
            }
            otherBudget = Double(otherSlider.value)
            let unusedBudget = totalBudget - flightBudget - hotelBudget - otherBudget
            let extraFlightBudget = (unusedBudget / 2).rounded(.up)
            let extraHotelBudget = (unusedBudget / 2).rounded(.down)
            flightBudget = flightBudget + extraFlightBudget
            hotelBudget = hotelBudget + extraHotelBudget
        }
        flightSlider.value = Float(flightBudget)
        hotelSlider.value = Float(hotelBudget)
        otherSlider.value = Float(otherBudget)
        flightSlider.updateLabelPosition(flightSlider.value)
        hotelSlider.updateLabelPosition(hotelSlider.value)
        otherSlider.updateLabelPosition(otherSlider.value)
    }
}
