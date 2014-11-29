//
//  ViewController.swift
//  Colorig
//
//  Created by Marcus Kida on 19/11/2014.
//  Copyright (c) 2014 Marcus Kida. All rights reserved.
//

import UIKit
import AssetsLibrary

typealias computedValues = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat)

class ViewController: UIViewController {
    
    @IBOutlet weak var flashView: UIView!

    var doubleTap: UITapGestureRecognizer?
    var lastHue: CGFloat = 0.0
    var lastSaturation: CGFloat = 0.0
    var lastBrightness: CGFloat = 1.0
    var lastTouchPoint: CGPoint?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        doubleTap = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTap!.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if lastTouchPoint == nil {
            lastTouchPoint = touches.allObjects.first?.locationInView(self.view)
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        updateColor(colorComponents(touches))
        lastTouchPoint = touches.allObjects.first?.locationInView(self.view)
    }
    
    func updateColor(vals: computedValues) {
        self.view.backgroundColor = UIColor(hue: vals.hue, saturation: vals.saturation, brightness: vals.brightness, alpha: 1.0)
    }
    
    private func colorComponents (touches: NSSet) -> computedValues {
        let viewHeight = CGRectGetHeight(self.view.frame)
        let viewWidth = CGRectGetWidth(self.view.frame)
        
        let touch = touches.allObjects.first as UITouch
        let location = touch.locationInView(self.view)

        // Detect significant change in up/down movement (and set hue accordingly)
        if let last = lastTouchPoint {
            if fabs(location.y - last.y) > 5 && fabs(location.y - last.y) < 100 {
                lastHue = ultimateFormula(viewHeight, y: location.y)
            }
        }
        
        if location.y <= viewHeight / 2 {
            lastSaturation = ultimateFormula(viewWidth, y: location.x)
        } else {
            lastBrightness = ultimateFormula(viewWidth, y: location.x)
        }
        
        return (lastHue, lastSaturation, lastBrightness)
    }
    
    private func lastComponents() -> computedValues {
        return (lastHue, lastSaturation, lastBrightness)
    }
    
    private func ultimateFormula(x: CGFloat, y: CGFloat) -> CGFloat {
        return (1 / x) * (x - y)
    }
    
    func doubleTap(gestureRecognizer: UITapGestureRecognizer) {
        flashView.alpha = 1.0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.flashView.alpha = 0.0
            }, completion: { (completed: Bool) -> Void in
            self.saveToLibrary()
        })
    }
    
    private func saveToLibrary() {
        let bounds = UIScreen.mainScreen().bounds
        let scale = UIScreen.mainScreen().scale
        let size = CGSizeMake(bounds.width * scale, CGRectGetHeight(bounds) * scale)
        let rect = CGRectMake(0, 0, size.width, size.height)
        let image = imageWithColor(rect, color: self.view.backgroundColor!)
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation.Up) { (path: NSURL!, error: NSError!) -> Void in
            if error != nil {
                UIAlertView(title: "Error", message: "The Photo could not be saved.", delegate: nil, cancelButtonTitle: "OK")
            }
        }
    }
    
    private func imageWithColor(rect: CGRect, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextFillRect(ctx, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

