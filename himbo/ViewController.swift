//
//  ViewController.swift
//  Colorig
//
//  Created by Marcus Kida on 19/11/2014.
//  Copyright (c) 2014 Marcus Kida. All rights reserved.
//

import UIKit

typealias computedValues = (hue: CGFloat, saturation: CGFloat, brightness: CGFloat)

class ViewController: UIViewController, SphereMenuDelegate {
    
    @IBOutlet weak var flashView: UIView!

    let defaults = NSUserDefaults.standardUserDefaults()
    
    var doubleTap: UITapGestureRecognizer?
    var lastHue: CGFloat = 0.0
    var lastSaturation: CGFloat = 0.0
    var lastBrightness: CGFloat = 1.0
    var lastTouchPoint: CGPoint?
    
    var infoVisible: Bool = false
    var tutorialRunning: Bool = false
    
    var theTutorial: Tutorial?
    var sphereMenu: SphereMenu?
    var infoView: InfoView?
    var exporter: Exporter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        exporter = Exporter(view: self.view, flashView: self.flashView)
        
        doubleTap = UITapGestureRecognizer(target: self, action: "doubleTap:")
        doubleTap!.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap!)

        let images: [UIImage] = [UIImage(named: "icon-share")!, UIImage(named: "icon-facebook")!, UIImage(named: "icon-twitter")!, UIImage(named: "icon-email")!, UIImage(named: "icon-gallery")!]
        sphereMenu = SphereMenu(startPoint: CGPointMake(CGRectGetWidth(self.view.frame) / 2, CGRectGetHeight(self.view.frame) / 2), submenuImages: images)
        sphereMenu?.delegate = self
        self.view.addSubview(sphereMenu!)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if self.defaults.boolForKey("tutorial_shown") {
            self.updateColor((hue: 0.95, saturation: 0.8, brightness: 0.9))
            return;
        }
        self.showInfo();
    }
    
    private func showInfo() {
        self.infoVisible = true
        self.infoView = nil;
        self.infoView = InfoView(text: "Start\nTutorial", parentView: self.view)
        self.infoView?.show({ () -> Void in
            self.defaults.setBool(true, forKey: "tutorial_shown")
            self.infoVisible = false
            self.tutorialRunning = true
            self.tutorial()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if lastTouchPoint == nil {
            lastTouchPoint = touches.first?.locationInView(self.view)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !infoVisible {
            updateColor(colorComponents(touches))
            lastTouchPoint = touches.first?.locationInView(self.view)
        }
    }
    
    func updateColor(vals: computedValues) {
        self.view.backgroundColor = UIColor(hue: vals.hue, saturation: vals.saturation, brightness: vals.brightness, alpha: 1.0)
    }
    
    private func colorComponents (touches: NSSet) -> computedValues {
        
        let viewHeight = CGRectGetHeight(self.view.frame)
        let viewWidth = CGRectGetWidth(self.view.frame)
        
        let touch = touches.allObjects.first as! UITouch
        let location = touch.locationInView(self.view)
        
        func computeAttribute () -> CGFloat {
            return ultimateFormula(viewWidth, y: location.x)
        }

        // Detect significant change in up/down movement (and set hue accordingly)
        if let last = lastTouchPoint {
            if fabs(location.y - last.y) > 5 && fabs(location.y - last.y) < 100 {
                lastHue = ultimateFormula(viewHeight, y: location.y)
            }
        }
        
        // calculate S/B
        var classic = true
        var force: CGFloat = 0.0
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .Available {
                classic = false
                force = (touches.allObjects.first?.force)!
            }
        }
        
        if classic {
            if location.y <= viewHeight / 2 {
                lastSaturation = computeAttribute()
            } else {
                lastBrightness = computeAttribute()
            }
        } else {
            lastSaturation = computeAttribute()
            lastBrightness = ultimateFormula(viewWidth, y: force * 100)
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
        guard let exporter = exporter else {
            //fixme: handle non existing exporter
            return
        }
        exporter.flashView { () -> Void in
            if let url = exporter.temporaryBackground() {
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self.presentViewController(activity, animated: true, completion: nil)
            }
        }
    }
    
    private func toggleMenu() {
        if let menu = self.sphereMenu {
            menu.toggle()
        }
    }
        
    private func tutorial() {
        theTutorial = Tutorial(view: self.view)
        theTutorial?.start({ (hue, saturation, brightness) -> Void in
            self.updateColor((hue: hue, saturation: saturation, brightness: brightness))
            }, menuToggle: { () -> Void in
                self.toggleMenu()
            }, finished: { () -> Void in
                self.tutorialRunning = false
        })
    }
    
    func sphereDidSelected(index: Int) {
        if index == 4 {
            guard let exporter = exporter else {
                // fixme: handle non existing exporter
                return
            }
            if !exporter.checkAssetsAuthorization() {
                UIAlertView(title: "Error", message: "Please go into your Device's Settings and allow Album Access for himbo. This App will only save the current Wallpaper to your Albums. No Access to this or other Photos is gained.", delegate: nil, cancelButtonTitle: "OK").show()
                return
            }
            exporter.saveToLibrary();
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if let event = event where event.subtype == UIEventSubtype.MotionShake {
            if !infoVisible && !tutorialRunning {
                self.showInfo()
            }
        }
    }
}

