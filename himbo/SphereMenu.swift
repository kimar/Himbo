//
//  SphereMenu.swift
//  Sphere Menu
//
//  Created by Camilo Morales on 10/21/14.
//  Copyright (c) 2014 Camilo Morales. All rights reserved.
//

import Foundation
import UIKit

@objc protocol SphereMenuDelegate{
    func sphereDidSelected(index:Int)
    @objc optional func sphereDidOpen()
    @objc optional func sphereDidClose()
}

// fixme: make this a struct
class SphereMenu:UIView, UICollisionBehaviorDelegate{
    

    let kItemInitTag:Int = 1001
    let kAngleOffset:CGFloat = CGFloat(Double.pi / 2) / 2.0
    let kSphereLength:CGFloat = 80
    let kSphereDamping:Float = 1.0
    
    var delegate:SphereMenuDelegate?
    var count:Int = 0
    var images:Array<UIImage>?
    var items:Array<UIImageView>?
    var positions:Array<NSValue>?
    
    // animator and behaviors
    var animator:UIDynamicAnimator?
    var collision:UICollisionBehavior?
    var itemBehavior:UIDynamicItemBehavior?
    var snaps:Array<UISnapBehavior>?
    
    var bumper:UIDynamicItem?
    var expanded:Bool?
    
    required init(startPoint:CGPoint, submenuImages:Array<UIImage>){
        self.init()
        self.images = submenuImages;
        self.count = self.images!.count;
        self.center = startPoint;
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.count = 0;
        self.images = Array()
        self.init()
    }
    
    required override init(frame: CGRect) {
        self.count = 0;
        self.images = Array()
        super.init(frame: frame)
    }
    
    override func didMoveToSuperview() {
        self.commonSetup()
    }
    
    
    func commonSetup()
    {
        self.items = Array()
        self.positions = Array()
        self.snaps = Array()
        
        guard let images = images else { return }

        var i = 0
        // setup the items
        for image in images {
            let item = UIImageView(image: image)
            item.tag = kItemInitTag + i;
            item.isUserInteractionEnabled = true;
            self.superview?.addSubview(item)
            
            let position = self.centerForSphereAtIndex(index: i)
            item.center = self.center;
            self.positions?.append(NSValue(cgPoint: position))
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(SphereMenu.tapped(gesture:)))
            item.addGestureRecognizer(tap)
            
            //            let pan = UIPanGestureRecognizer(target: self, action: "panned:")
            //            item.addGestureRecognizer(pan)
            
            item.alpha = 0.0
            self.items?.append(item)
            i += 1
        }
    
        self.superview?.bringSubview(toFront: self)
    
        // setup animator and behavior
        self.animator = UIDynamicAnimator(referenceView: self.superview!)
        self.collision = UICollisionBehavior(items: self.items!)
        self.collision?.translatesReferenceBoundsIntoBoundary = true;
        self.collision?.collisionDelegate = self;
        
        guard let items = items else { return }
        for item in items {
            let snap = UISnapBehavior(item: item, snapTo: self.center)
            snap.damping = CGFloat(kSphereDamping)
            self.snaps?.append(snap)
        }

        self.itemBehavior = UIDynamicItemBehavior(items: self.items!)
        self.itemBehavior?.allowsRotation = false;
        self.itemBehavior?.elasticity = 0.25;
        self.itemBehavior?.density = 0.5;
        self.itemBehavior?.angularResistance = 4;
        self.itemBehavior?.resistance = 10;
        self.itemBehavior?.elasticity = 0.8;
        self.itemBehavior?.friction = 0.5;
    }

    func centerForSphereAtIndex(index:Int) -> CGPoint{
        let firstAngle:CGFloat = CGFloat(Double.pi) /*+ (CGFloat(M_PI_2) - kAngleOffset)*/ + CGFloat(index) * kAngleOffset
        let startPoint = self.center
        let x = startPoint.x + cos(firstAngle) * kSphereLength;
        let y = startPoint.y + sin(firstAngle) * kSphereLength;
        let position = CGPoint(x: x, y: y);
        return position;
    }
    
    func startTapped(gesture:UITapGestureRecognizer){
        self.animator?.removeBehavior(self.collision!)
        self.animator?.removeBehavior(self.itemBehavior!)
        toggle()
    }
    
    func toggle() {
        if (self.expanded == true) {
            self.shrinkSubmenu()
            self.delegate?.sphereDidClose?()
        } else {
            self.expandSubmenu()
            self.delegate?.sphereDidOpen?()
        }
    }

    @objc func tapped(gesture:UITapGestureRecognizer)
    {
        var tag = gesture.view?.tag
        tag? -= Int(kItemInitTag)
        self.delegate?.sphereDidSelected(index: tag!)
        self.shrinkSubmenu()
    }

    func panned(gesture:UIPanGestureRecognizer)
    {
        let touchedView = gesture.view;
        if (gesture.state == UIGestureRecognizerState.began) {
            self.animator?.removeBehavior(self.itemBehavior!)
            self.animator?.removeBehavior(self.collision!)
            self.removeSnapBehaviors()
        } else if (gesture.state == UIGestureRecognizerState.changed) {
            touchedView?.center = gesture.location(in: self.superview)
        } else if (gesture.state == UIGestureRecognizerState.ended) {
            self.bumper = touchedView;
            self.animator?.addBehavior(self.collision!)
            let index = self.indexOfItemInArray(dataArray: self.items!, item: touchedView!)

            if (index >= 0) {
                self.snapToPostionsWithIndex(index: index)
            }

        }
    }
    
    func indexOfItemInArray(dataArray:Array<UIImageView>, item:AnyObject) -> Int{
        var index = -1
        var i = 0
        for thing in dataArray {
            if thing === item {
                index = i
                break
            }
            i += 1
        }
        return index
    }
    
    func shrinkSubmenu(){
        self.animator?.removeBehavior(self.collision!)
        
        for index in 0..<self.count {
            self.snapToStartWithIndex(index: index)
        }

        self.expanded = false;
    }
    
    func expandSubmenu(){
        for index in 0..<self.count {
            self.snapToPostionsWithIndex(index: index)
        }
        self.expanded = true;
    }
    
    func snapToStartWithIndex(index:Int)
    {
        let item = self.items![index]
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            item.alpha = 0.0
        })
        let snap = UISnapBehavior(item: item, snapTo: self.center)
        snap.damping = CGFloat(kSphereDamping)
        let snapToRemove = self.snaps![index];
        self.snaps![index] = snap;
        self.animator?.removeBehavior(snapToRemove)
        self.animator?.addBehavior(snap)
    }
    
    func snapToPostionsWithIndex(index:Int)
    {
        let positionValue:AnyObject = self.positions![index];
        let position = positionValue.cgPointValue
        let item = self.items![index]
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            item.alpha = 1.0
        })
        let snap = UISnapBehavior(item: item, snapTo: position!)
        snap.damping = CGFloat(kSphereDamping)
        let snapToRemove = self.snaps![index];
        self.snaps![index] = snap;
        self.animator?.removeBehavior(snapToRemove)
        self.animator?.addBehavior(snap)
    }

    func removeSnapBehaviors()
    {
        for index in 0...self.snaps!.count {
            self.animator?.removeBehavior(self.snaps![index])
        }
    }
    
    func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
        self.animator?.addBehavior(self.itemBehavior!)

        if (item1 !== self.bumper){
            let index = self.indexOfItemInArray(dataArray: self.items!, item: item1)
            if (index >= 0) {
                self.snapToPostionsWithIndex(index: index)
            }
        }
        
        if (item2 !== self.bumper){
            let index = self.indexOfItemInArray(dataArray: self.items!, item: item2)
            if (index >= 0) {
                self.snapToPostionsWithIndex(index: index)
            }
        }
    }

}

