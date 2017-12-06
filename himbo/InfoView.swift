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
        
        let width = parentView.frame.width - (kPadding * 2)
        let center = CGPoint(x: self.parentView.frame.width/2, y: self.parentView.frame.height/2)
        
        self.infoView = UIView(frame: CGRect(x: kPadding, y: kPadding, width: width, height: width))
        self.infoView.backgroundColor = UIColor.white
        self.infoView.layer.cornerRadius = self.infoView.frame.height / 2
        self.infoView.center = center
        
        self.infoLabel = UILabel(frame: CGRect(x: kInfoPadding, y: kInfoPadding, width: self.infoView.frame.width - (kInfoPadding * 2), height: self.infoView.frame.height - (kInfoPadding * 2)))
        self.infoLabel.text = text
        self.infoLabel.textColor = UIColor.himboRed()
        self.infoLabel.numberOfLines = 0
        self.infoLabel.textAlignment = NSTextAlignment.center
        self.infoLabel.font = UIFont.boldSystemFont(ofSize: 32.0)
        self.infoView.addSubview(self.infoLabel)
        
        self.animator = UIDynamicAnimator(referenceView: self)
        self.gravity = UIGravityBehavior(items: [self.infoView])
        
        // Halo
        haloLayer = PulsingLayer(pulseColor: UIColor(white: 1.0, alpha: 1.0))
        haloLayer.radius = self.infoView.frame.size.width
        haloLayer.animationDuration = 5
        haloLayer.pulseInterval = 0
        haloLayer.position = CGPoint(x: self.infoView.frame.width/2, y: self.infoView.frame.height/2)
        self.infoView.layer.addSublayer(haloLayer)
        
        self.tapGesture = UITapGestureRecognizer(target: self, action: #selector(InfoView.tap(tapGestureRecognizer:)))
        self.addGestureRecognizer(self.tapGesture!)
        
        self.addSubview(infoView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func show(onHide: @escaping () -> Void) {
        self.onHide = onHide;
        self.parentView.addSubview(self)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1.0
        })
    }
    
    func hide() {
        self.animator.addBehavior(self.gravity)
        UIView.animate(withDuration: 0.8, animations: { () -> Void in
            self.alpha = 0.0
            }, completion: { (finished: Bool) -> Void in
                self.removeFromSuperview()
                self.onHide?();
        })
    }
    
    @objc func tap(tapGestureRecognizer: UITapGestureRecognizer) {
        self.hide()
    }
}
