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
    var haloView: UIView!
    var haloLayer: PulsingLayer!

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
    
    override func viewDidAppear(animated: Bool) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.tutorial()
        }
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
        
        if !checkAssetsAuthorization() {
            UIAlertView(title: "Error", message: "Please go into your Device's Settings and allow Album Access for himbo. This App will only save the current Wallpaper to your Albums. No Access to this or other Photos is gained.", delegate: nil, cancelButtonTitle: "OK").show()
            return
        }
        
        flashView.alpha = 1.0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.flashView.alpha = 0.0
            }, completion: { (completed: Bool) -> Void in
                self.saveToLibrary()
        })
    }
    
    func checkAssetsAuthorization() -> Bool {
        let status = ALAssetsLibrary.authorizationStatus()
        if status != ALAuthorizationStatus.Authorized {
            self.view.shake(10, direction: ShakeDirection.Horizontal)
            return false
        }
        return true
    }
    
    private func saveToLibrary() {
        let bounds = UIScreen.mainScreen().bounds
        let scale = UIScreen.mainScreen().scale
        let size = CGSizeMake(bounds.width * scale, CGRectGetHeight(bounds) * scale)
        let rect = CGRectMake(0, 0, size.width, size.height)
        let image = imageWithColor(rect, color: self.view.backgroundColor!)
        ALAssetsLibrary().writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation.Up) { (path: NSURL!, error: NSError!) -> Void in
            if error != nil {
                UIAlertView(title: "Error", message: "The Photo could not be saved.", delegate: nil, cancelButtonTitle: "OK").show()
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
    
    private func tutorial() {
        haloLayer = PulsingLayer(pulseColor: UIColor(white: 1.0, alpha: 1.0))
        haloLayer.radius = 60.0
        haloLayer.animationDuration = 1
        haloLayer.pulseInterval = 0
        
        haloView = UIView(frame: CGRectMake(50, 50, 25, 25));
        haloView.layer.addSublayer(haloLayer)
        self.view.addSubview(haloView)
        
        UIView.animateWithDuration(5.0, animations: { () -> Void in
            self.haloView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height - 100)
            self.updateColor((hue: 0.9, saturation: 1.0, brightness: 1.0))
            }) { (finished: Bool) -> Void in
            UIView.animateWithDuration(5.0, animations: { () -> Void in
                self.haloView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width - 100, self.view.frame.size.height - 100)
                self.updateColor((hue: 0.9, saturation: 1.0, brightness: 0.1))
                }, completion: { (finished: Bool) -> Void in
                UIView.animateWithDuration(5.0, animations: { () -> Void in
                    self.haloView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.size.height - 100)
                    self.updateColor((hue: 0.9, saturation: 1.0, brightness: 1.0))
                    }, completion: { (finished: Bool) -> Void in
                        self.haloView.transform = CGAffineTransformIdentity
                        UIView.animateWithDuration(5.0, animations: { () -> Void in
                            self.haloView.transform = CGAffineTransformMakeTranslation(self.view.frame.size.width - 100, 0)
                            self.updateColor((hue: 0.9, saturation: 0.1, brightness: 1.0))
                            }, completion: { (finished: Bool) -> Void in
                                UIView.animateWithDuration(5.0, animations: { () -> Void in
                                    self.haloView.transform = CGAffineTransformIdentity
                                    self.updateColor((hue: 0.9, saturation: 1.0, brightness: 1.0))
                                    }, completion: { (finished: Bool) -> Void in
                                        self.haloView.removeFromSuperview()
                                })
                        })
                })
            })
        }
    }
}

