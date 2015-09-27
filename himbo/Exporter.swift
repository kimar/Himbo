//
//  Exporter.swift
//  himbo
//
//  Created by Marcus Kida on 27/09/2015.
//  Copyright © 2015 Marcus Kida. All rights reserved.
//

import UIKit
import AssetsLibrary

public struct Exporter {
    
    let view: UIView
    let flashView: UIView
    
    init(view: UIView, flashView: UIView) {
        self.view = view
        self.flashView = flashView
    }
    
    func temporaryBackground() -> NSURL? {
        let image = self.renderedImage()
        let path = NSTemporaryDirectory().stringByAppendingString("/himbo.png")
        guard let imageData = UIImagePNGRepresentation(image) else {
            return nil
        }
        imageData.writeToFile(path, atomically: true)
        return NSURL.fileURLWithPath(path)
    }
    
    func checkAssetsAuthorization() -> Bool {
        let status = ALAssetsLibrary.authorizationStatus()
        if status == ALAuthorizationStatus.Denied {
            self.view.shake(10, direction: ShakeDirection.Horizontal)
            return false
        }
        return true
    }
    
    public func flashView(closure: () -> Void) {
        self.flashView.alpha = 1.0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.flashView.alpha = 0.0
            }, completion: { (completed: Bool) -> Void in
                closure()
        })
    }
    
    public func saveToLibrary() {
        self.flashView { () -> Void in
            let image = self.renderedImage()
            ALAssetsLibrary().writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation.Up) { (path: NSURL!, error: NSError!) -> Void in
                if error != nil {
                    UIAlertView(title: "Error", message: "The Photo could not be saved.", delegate: nil, cancelButtonTitle: "OK").show()
                }
            }
        }
    }
    
    func renderedImage() -> UIImage {
        let bounds = UIScreen.mainScreen().bounds
        let scale = UIScreen.mainScreen().scale
        let size = CGSizeMake(bounds.width * scale, CGRectGetHeight(bounds) * scale)
        let rect = CGRectMake(0, 0, size.width, size.height)
        return self.imageWithColor(rect, color: self.view.backgroundColor!)
    }
    
    func imageWithColor(rect: CGRect, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(ctx, color.CGColor)
        CGContextFillRect(ctx, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}