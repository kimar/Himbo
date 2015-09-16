//
//  InfoView.swift
//  himbo
//
//  Created by Marcus Kida on 30/11/2014.
//  Copyright (c) 2014 Marcus Kida. All rights reserved.
//

import UIKit

class InfoView: UIView {
    
    private let kPadding: CGFloat = 50.0
    private let kInfoPadding: CGFloat = 10.0
    
    private var parentView: UIView!
    private var infoView: UIView!
    private var infoLabel: UILabel!
    
    private var onHide: (() -> Void)?
    private var tapGesture: UITapGestureRecognizer?
    
    private var haloLayer: PulsingLayer!
    
    // UIKitDynamics
    var gravity: UIGravityBehavior!
    var animator: UIDynamicAnimator!
    
    convenience init(text: String, parentView: UIView) {
        self.init(frame: parentView.frame)
        
        self.parentView = parentView
        
        self.backgroundColor = UIColor.himboRed()
        self.alpha = 0.0
        
        let width = CGRectGetWidth(parentView.frame) - (kPadding * 2)
        let center = CGPointMake(CGRectGetWidth(self.parentView.frame)/2, CGRectGetHeight(self.parentView.frame)/2)
        
        self.infoView = UIView(frame: CGRectMake(kPadding, kPadding, width, width))
        self.infoView.backgroundColor = UIColor.whiteColor()
        self.infoView.layer.cornerRadius = CGRectGetHeight(self.infoView.frame) / 2
        self.infoView.center = center
        
        self.infoLabel = UILabel(frame: CGRectMake(kInfoPadding, kInfoPadding, CGRectGetWidth(self.infoView.frame) - (kInfoPadding * 2), CGRectGetHeight(self.infoView.frame) - (kInfoPadding * 2)))
        self.infoLabel.text = text
        self.infoLabel.textColor = UIColor.himboRed()
        self.infoLabel.numberOfLines = 0
        self.infoLabel.textAlignment = NSTextAlignment.Center
        self.infoLabel.font = UIFont.boldSystemFontOfSize(32.0)
        self.infoView.addSubview(self.infoLabel)
        
        self.animator = UIDynamicAnimator(referenceView: self)
        self.gravity = UIGravityBehavior(items: [self.infoView])
        
        // Halo
        haloLayer = PulsingLayer(pulseColor: UIColor(white: 1.0, alpha: 1.0))
        haloLayer.radius = self.infoView.frame.size.width
        haloLayer.animationDuration = 5
        haloLayer.pulseInterval = 0
        haloLayer.position = CGPointMake(CGRectGetWidth(self.infoView.frame)/2, CGRectGetHeight(self.infoView.frame)/2)
        self.infoView.layer.addSublayer(haloLayer)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: "tap:")
        self.addGestureRecognizer(self.tapGesture!)
        
        self.addSubview(infoView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(onHide: () -> Void) {
        self.onHide = onHide;
        self.parentView.addSubview(self)
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.alpha = 1.0
        })
    }
    
    func hide() {
        self.animator.addBehavior(self.gravity)
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            self.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
                self.removeFromSuperview()
                self.onHide?();
        })
    }
    
    func tap(tapGestureRecognizer: UITapGestureRecognizer) {
        self.hide()
    }
}
