//
//  PieViewLayer.swift
//  PieCharts
//
//  Created by Ivan Schuetz on 30/12/2016.
//  Copyright © 2016 Ivan Schuetz. All rights reserved.
//

import UIKit

open class PieCustomViewsLayerSettings {
    
    public var viewRadius: CGFloat?
    public var lineWidth: CGFloat = 5
    public var chartOffset: CGFloat = 0
    public var segment1Length: CGFloat = 15
    public var segment2Length: CGFloat = 0
    
    public var hideOnOverflow = true // NOTE: Considers only space defined by angle with origin at the center of the pie chart. Arcs (inner/outer radius) are ignored.
    
    public init() {}
}

open class PieCustomViewsLayer: PieChartLayer {
    
    public weak var chart: PieChart?
    
    public var settings: PieCustomViewsLayerSettings = PieCustomViewsLayerSettings()
    
    public var onNotEnoughSpace: ((UIView, CGSize) -> Void)?
    
    fileprivate var sliceViews = [PieSlice: (CALayer, UIView)]()
    
    public var animator: PieViewLayerAnimator = AlphaPieViewLayerAnimator()
    public var lineAnimator: PieLineTextLayerAnimator = AlphaPieLineTextLayerAnimator()
    
    public var viewGenerator: ((PieSlice, CGPoint) -> UIView)?
    
    public init() {}
    
    public func onEndAnimation(slice: PieSlice) {
        addItems(slice: slice)
    }
    
    public func addItems(slice: PieSlice) {
        guard sliceViews[slice] == nil else {return}
        
        let p1 = slice.view.calculatePosition(angle: slice.view.midAngle, p: slice.view.center, offset: slice.view.outerRadius + settings.chartOffset)
        let p2 = slice.view.calculatePosition(angle: slice.view.midAngle, p: slice.view.center, offset: slice.view.outerRadius + settings.segment1Length)
        
        let angle = slice.view.midAngle.truncatingRemainder(dividingBy: (CGFloat.pi * 2))
        let isRightSide = angle >= 0 && angle <= (CGFloat.pi / 2) || (angle > (CGFloat.pi * 3 / 2) && angle <= CGFloat.pi * 2)
        
        let p3 = CGPoint(x: p2.x + (isRightSide ? settings.segment2Length : -settings.segment2Length), y: p2.y)
        
        let lineLayer = createLine(p1: p1, p2: p2, p3: p3, lineColor: slice.data.model.color)
        chart?.container.addSublayer(lineLayer)
        lineAnimator.animate(lineLayer)
        
        let center = settings.viewRadius.map{slice.view.midPoint(radius: $0)} ?? slice.view.arcCenter
        
        guard let view = viewGenerator?(slice, center) else {print("Need a view generator to create views!"); return}
        
        let size = view.frame.size
        
        let availableSize = CGSize(width: slice.view.maxRectWidth(center: center, height: size.height), height: size.height)
        
        if !settings.hideOnOverflow || availableSize.contains(size) {
            
            view.center = center
            
            chart?.addSubview(view)
            
        } else {
            onNotEnoughSpace?(view, availableSize)
        }
        
        animator.animate(view)
        
        sliceViews[slice] = (lineLayer, view)
    }
    
    public func createLine(p1: CGPoint, p2: CGPoint, p3: CGPoint, lineColor: UIColor = .black) -> CALayer {
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = lineColor.cgColor
        layer.fillColor = lineColor.cgColor
        layer.borderWidth = settings.lineWidth
        layer.lineWidth = settings.lineWidth
        
        return layer
    }
    
    public func onSelected(slice: PieSlice, selected: Bool) {
//        guard let label = sliceViews[slice] else {print("Invalid state: slice not in dictionary"); return}
//        
//        let p = slice.view.calculatePosition(angle: slice.view.midAngle, p: label.center, offset: selected ? slice.view.selectedOffset : -slice.view.selectedOffset)
//        UIView.animate(withDuration: 0.15) {
//            label.center = p
//        }
    }
    
    public func clear() {
        for (_, layerView) in sliceViews {
            layerView.0.removeFromSuperlayer()
            layerView.1.removeFromSuperview()
        }
        sliceViews.removeAll()
    }
}
