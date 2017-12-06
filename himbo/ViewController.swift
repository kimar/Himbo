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

    let defaults = UserDefaults.standard
    
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
        
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.doubleTap(gestureRecognizer:)))
        doubleTap!.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap!)

        let images: [UIImage] = [UIImage(named: "icon-share")!, UIImage(named: "icon-facebook")!, UIImage(named: "icon-twitter")!, UIImage(named: "icon-email")!, UIImage(named: "icon-gallery")!]
        sphereMenu = SphereMenu(startPoint: CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2), submenuImages: images)
        sphereMenu?.delegate = self
        self.view.addSubview(sphereMenu!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.defaults.bool(forKey: "tutorial_shown") {
            self.updateColor(vals: (hue: 0.95, saturation: 0.8, brightness: 0.9))
            return;
        }
        self.showInfo();
    }
    
    private func showInfo() {
        self.infoVisible = true
        self.infoView = nil;
        self.infoView = InfoView(text: "Start\nTutorial", parentView: self.view)
        self.infoView?.show(onHide: { () -> Void in
            self.defaults.set(true, forKey: "tutorial_shown")
            self.infoVisible = false
            self.tutorialRunning = true
            self.tutorial()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if lastTouchPoint == nil {
            lastTouchPoint = touches.first?.location(in: self.view)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !infoVisible {
            updateColor(vals: colorComponents(touches: touches))
            lastTouchPoint = touches.first?.location(in: self.view)
        }
    }
    
    func updateColor(vals: computedValues) {
        self.view.backgroundColor = UIColor(hue: vals.hue, saturation: vals.saturation, brightness: vals.brightness, alpha: 1.0)
    }
    
    private func colorComponents (touches: Set<UITouch>) -> computedValues {
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else {
            return computedValues(0,0,0)
        }
        
        let viewHeight = self.view.frame.height
        let viewWidth = self.view.frame.width

        func computeAttribute () -> CGFloat {
            return ultimateFormula(x: viewWidth, y: location.x)
        }

        // Detect significant change in up/down movement (and set hue accordingly)
        if let last = lastTouchPoint {
            if fabs(location.y - last.y) > 5 && fabs(location.y - last.y) < 100 {
                lastHue = ultimateFormula(x: viewHeight, y: location.y)
            }
        }
        
        // calculate S/B
        var classic = true
        var force: CGFloat = 0.0
        if #available(iOS 9.0, *) {
            if traitCollection.forceTouchCapability == .available {
                classic = false
                force = (touches.first?.force)!
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
            lastBrightness = ultimateFormula(x: viewWidth, y: force * 100)
        }
        
        return (lastHue, lastSaturation, lastBrightness)
    }
    
    private func lastComponents() -> computedValues {
        return (lastHue, lastSaturation, lastBrightness)
    }
    
    private func ultimateFormula(x: CGFloat, y: CGFloat) -> CGFloat {
        return (1 / x) * (x - y)
    }
    
    @objc func doubleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard let exporter = exporter else {
            //fixme: handle non existing exporter
            return
        }
        exporter.flashView { () -> Void in
            if let url = exporter.temporaryBackground() {
                let activity = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                self.present(activity, animated: true, completion: nil)
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
        theTutorial?.start(closure: { (hue, saturation, brightness) -> Void in
            self.updateColor(vals: (hue: hue, saturation: saturation, brightness: brightness))
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
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if let event = event, event.subtype == UIEventSubtype.motionShake {
            if !infoVisible && !tutorialRunning {
                self.showInfo()
            }
        }
    }
}

