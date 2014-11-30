//
//  Tutorial.swift
//  himbo
//
//  Created by Marcus Kida on 30/11/2014.
//  Copyright (c) 2014 Marcus Kida. All rights reserved.
//

import UIKit

class Tutorial: NSObject {
    
    private var parentView: UIView!
    private var haloView: UIView!
    private var haloLayer: PulsingLayer!
    
    init(view: UIView) {
        super.init()
        self.parentView = view
    }
    
    func start(closure: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) -> Void) {
        haloLayer = PulsingLayer(pulseColor: UIColor(white: 1.0, alpha: 1.0))
        haloLayer.radius = 60.0
        haloLayer.animationDuration = 1
        haloLayer.pulseInterval = 0
        
        haloView = UIView(frame: CGRectMake(50, 50, 25, 25));
        haloView.layer.addSublayer(haloLayer)
        parentView.addSubview(haloView)
        
        UIView.animateWithDuration(5.0, animations: { () -> Void in
            self.haloView.transform = CGAffineTransformMakeTranslation(0, self.parentView.frame.size.height - 100)
            closure(hue: 0.9, saturation: 1.0, brightness: 1.0)
            }) { (finished: Bool) -> Void in
                self.step1(closure)
        }
    }
    
    func step1(closure: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) -> Void) {
        UIView.animateWithDuration(5.0, animations: { () -> Void in
            self.haloView.transform = CGAffineTransformMakeTranslation(self.parentView.frame.size.width - 100, self.parentView.frame.size.height - 100)
            closure(hue: 0.9, saturation: 1.0, brightness: 0.1)
            }, completion: { (finished: Bool) -> Void in
                self.step2(closure)
        })
    }
    
    func step2(closure: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) -> Void) {
        UIView.animateWithDuration(5.0, animations: { () -> Void in
            self.haloView.transform = CGAffineTransformMakeTranslation(0, self.parentView.frame.size.height - 100)
            closure(hue: 0.9, saturation: 1.0, brightness: 1.0)
            }, completion: { (finished: Bool) -> Void in
                self.step3(closure)
        })
    }
    
    func step3(closure: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) -> Void) {
        self.haloView.transform = CGAffineTransformIdentity
        UIView.animateWithDuration(5.0, animations: { () -> Void in
            self.haloView.transform = CGAffineTransformMakeTranslation(self.parentView.frame.size.width - 100, 0)
            closure(hue: 0.9, saturation: 0.1, brightness: 1.0)
            }, completion: { (finished: Bool) -> Void in
                self.step4(closure)
        })
    }
    
    func step4(closure: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat) -> Void) {
        UIView.animateWithDuration(5.0, animations: { () -> Void in
            self.haloView.transform = CGAffineTransformIdentity
            closure(hue: 0.9, saturation: 1.0, brightness: 1.0)
            }, completion: { (finished: Bool) -> Void in
                self.haloView.removeFromSuperview()
        })
    }
}