//
//  Tutorial.swift
//  himbo
//
//  Created by Marcus Kida on 30/11/2014.
//  Copyright (c) 2014 Marcus Kida. All rights reserved.
//

import UIKit

typealias aClosure = (_ hue: CGFloat, _ saturation: CGFloat, _ brightness: CGFloat) -> Void

// fixme: make this a struct
class Tutorial: NSObject {
    
    private var parentView: UIView!
    private var haloView: UIView!
    private var haloLayer: PulsingLayer!
    
    private let kMovementDuration = 1.5
    private let kTapDuration = 0.3
    
    private var menuToggle: (() -> Void)?
    private var finished: (() -> Void)?
    
    private var kHue: CGFloat = 0.0
    private var kSat: CGFloat = 0.0
    private var kBri: CGFloat = 0.0
    
    init(view: UIView) {
        super.init()
        self.parentView = view
        UIColor.himboRed().getHue(&kHue, saturation: &kSat, brightness: &kBri, alpha: nil)
    }
    
    func hasForceTouch () -> Bool {
        if #available(iOS 9, *) {
            if parentView.traitCollection.forceTouchCapability == .available {
                return true
            }
        }
        return false
    }
    
    func conditionalHue () -> CGFloat {
        if hasForceTouch() {
            return kHue
        }
        return 0.6
    }
    
    func start(closure: @escaping aClosure, menuToggle: @escaping () -> Void, finished: @escaping () -> Void) {
        
        self.menuToggle = menuToggle
        self.finished = finished
        
        haloLayer = PulsingLayer(pulseColor: UIColor(white: 1.0, alpha: 1.0))
        haloLayer.radius = 90.0
        haloLayer.animationDuration = 1
        haloLayer.pulseInterval = 0
        
        haloView = UIView(frame: CGRect(x: 65, y: 65, width: 50, height: 50))
        haloLayer.position = CGPoint(x: haloView.frame.height/2, y: haloView.frame.width/2)
        haloView.layer.addSublayer(haloLayer)

        haloView.backgroundColor = .white
        haloView.layer.cornerRadius = haloView.frame.height / 2
        
        parentView.addSubview(haloView)
        
        // down / up
        UIView.animate(withDuration: kMovementDuration, animations: { () -> Void in
            self.haloView.transform = CGAffineTransform(translationX: 0, y: self.parentView.frame.size.height - 130)
            closure(0.6, self.kSat, self.kBri)
            }, completion: { (finished: Bool) -> Void in
                if self.hasForceTouch() {
                    return self.forceTouch(closure: closure)
                }
                self.step1(closure: closure)
        })
    }
    
    // right
    func step1(closure: @escaping aClosure) {
        UIView.animate(withDuration: kMovementDuration, animations: { () -> Void in
            self.haloView.transform = CGAffineTransform(translationX: self.parentView.frame.size.width - 130, y: self.parentView.frame.size.height - 130)
            closure(self.conditionalHue(), self.kSat, 0.1)
            }, completion: { (finished: Bool) -> Void in
                self.step2(closure: closure)

        })
    }
    
    // left
    func step2(closure: @escaping aClosure) {
        UIView.animate(withDuration: kMovementDuration, animations: { () -> Void in
            self.haloView.transform = CGAffineTransform(translationX: 0, y: self.parentView.frame.size.height - 130)
            closure(self.conditionalHue(), self.kSat, self.kBri)
            }, completion: { (finished: Bool) -> Void in
                self.step3(closure: closure)
        })
    }
    
    // right (saturation)
    func step3(closure: @escaping aClosure) {
        self.haloView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: kMovementDuration, animations: { () -> Void in
            self.haloView.transform = CGAffineTransform(translationX: self.parentView.frame.size.width - 130, y: 0)
            closure(self.conditionalHue(), 0.1, self.kBri)
            }, completion: { (finished: Bool) -> Void in
                self.step4(closure: closure)
        })
    }
    
    // left (saturation)
    func step4(closure: @escaping aClosure) {
        UIView.animate(withDuration: kMovementDuration, animations: { () -> Void in
            self.haloView.transform = CGAffineTransform.identity
            closure(self.conditionalHue(), self.kSat, self.kBri)
            }, completion: { (finished: Bool) -> Void in
                self.step5(closure: closure)
        })
    }
    
    func forceTouch(closure: @escaping aClosure) {
        UIView.animate(withDuration: kMovementDuration, animations: { () -> Void in
            self.haloView.transform = CGAffineTransform.identity
            closure(self.kHue, self.kSat, self.kBri)
            }, completion: { (finished: Bool) -> Void in
                UIView.animate(withDuration: self.kMovementDuration, animations: { () -> Void in
                    self.haloView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                    closure(self.kHue, self.kSat, 0.1)
                    }, completion: { (finished: Bool) -> Void in
                        UIView.animate(withDuration: self.kMovementDuration, animations: { () -> Void in
                            self.haloView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                            closure(self.kHue, self.kSat, self.kBri)
                            }, completion: { (finished: Bool) -> Void in
                                self.step3(closure: closure)
                        })
            })

        })
    }
    
    // Move to center and do double tap
    func step5(closure: @escaping aClosure) {
        self.haloView.center = CGPoint(x: self.parentView.frame.width / 2, y: self.parentView.frame.height / 2)
        UIView.animate(withDuration: kMovementDuration) {
            self.stepTap(closure: closure, done: { step2 in
                self.stepTap(closure: step2, done: { step3 in
                    self.step7(closure: step3)
                })
            })
        }
    }
    
    // Tap
    func stepTap(closure: @escaping aClosure, done: @escaping (_ doneClosure: @escaping aClosure) -> Void) {
        UIView.animate(withDuration: kTapDuration, animations: { () -> Void in
            self.haloView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            }, completion: { (finished: Bool) -> Void in
                UIView.animate(withDuration: self.kTapDuration, animations: { () -> Void in
                    self.haloView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: { (finished: Bool) -> Void in
                        done(closure)
                })
        })
    }
    
    func step7(closure: @escaping aClosure) {
        self.menuToggle?()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.5) {
            self.stepTap(closure: closure, done: { (doneClosure) -> Void in
                self.stepTap(closure: closure, done: { (doneClosure) -> Void in
                    self.step8(closure: closure)
                })
            })
        }
    }
    
    func step8(closure: aClosure) {
        self.menuToggle?()
        self.step9(closure: closure)
    }
    
    // Remove haloView, end Tutorial
    func step9(closure: aClosure) {
        self.haloView.removeFromSuperview()
        self.finished?()
    }
}
