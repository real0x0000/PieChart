//
//  SliderTextView.swift
//  TestChart1
//
//  Created by Feyverly on 24/11/2561 BE.
//  Copyright © 2561 ANUWAT SITTICCHAK. All rights reserved.
//

import UIKit

class SliderTextView: UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var thumbview: TumbView!
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        let x = Int(round(sender.value))
        thumbview.label.text = "\(x)"
        thumbview.center = setUISliderThumbValueWithLabel(slider: sender)
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
        thumbview.targetView = slider
    }
    
    func setUISliderThumbValueWithLabel(slider: UISlider) -> CGPoint {
        let slidertTrack : CGRect = slider.trackRect(forBounds: slider.bounds)
        let sliderFrm : CGRect = slider .thumbRect(forBounds: slider.bounds, trackRect: slidertTrack, value: slider.value)
        return CGPoint(x: sliderFrm.origin.x + slider.frame.origin.x + 8, y: slider.center.y)
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

