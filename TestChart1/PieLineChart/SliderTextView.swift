//
//  SliderTextView.swift
//  TestChart1
//
//  Created by Feyverly on 24/11/2561 BE.
//  Copyright © 2561 ANUWAT SITTICHAK. All rights reserved.
//

import UIKit

protocol SliderTextViewDelegate {
    func valueChanged(_ value: Float, type: BudgetType)
}

class SliderTextView: UIView {
    
    var delegate: SliderTextViewDelegate?
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var slider: BudgetSlider!
    @IBOutlet weak var thumbview: TumbView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    var value : Float {
        get{
            return slider.value
        }
        set{
            DispatchQueue.main.async { [weak self] in
                self?.slider.value = newValue
            }
        }
    }
    
    var maximumValue : Float {
        get{
            return slider.maximumValue
        }
        set{
            slider.maximumValue = newValue
        }
    }
    
    var minimumTrackTintColor : UIColor? {
        get{
            return slider.minimumTrackTintColor
        }
        set{
            slider.minimumTrackTintColor = newValue
        }
    }
    
    var maximumTrackTintColor : UIColor? {
        get{
            return slider.maximumTrackTintColor
        }
        set{
            slider.maximumTrackTintColor = newValue
        }
    }
    
    var sliderType: BudgetType = .other
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
//        updateLabelPosition(sender.value)
        delegate?.valueChanged(sender.value, type: sliderType)
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
        thumbview.layer.masksToBounds = true
        thumbview.layer.cornerRadius = thumbview.frame.height / 2
        thumbview.targetView = slider
        sliderValueChanged(slider)
    }
    
    func getX(slider: UISlider) -> CGFloat {
        let slidertTrack : CGRect = slider.trackRect(forBounds: slider.bounds)
        let sliderFrm : CGRect = slider .thumbRect(forBounds: slider.bounds, trackRect: slidertTrack, value: slider.value)
        return sliderFrm.origin.x + slider.frame.origin.x
    }
    
    func updateLabelPosition(_ value: Float) {
        DispatchQueue.main.async { [weak self] in
            guard let slider = self?.slider else { return }
            let x = Int(round(value))
            self?.thumbview.label.text = "\(x) ฿"
            self?.thumbview.label.layoutIfNeeded()
            self?.thumbview.layoutIfNeeded()
            guard let xPosition = self?.getX(slider: slider) else { return }
            self?.leadingConstraint.constant = xPosition
        }
    }
}

extension SliderTextView {
    
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
}
