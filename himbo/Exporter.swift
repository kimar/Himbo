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
    
    func temporaryBackground() -> URL? {
        let image = self.renderedImage()
        let url = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        guard let imageData = UIImagePNGRepresentation(image),
            let aUrl = url
        else {
            return nil
        }
        try? imageData.write(to: aUrl)
        return aUrl
    }
    
    func checkAssetsAuthorization() -> Bool {
        let status = ALAssetsLibrary.authorizationStatus()
        if status == ALAuthorizationStatus.denied {
            self.view.shake(times: 10, direction: ShakeDirection.Horizontal)
            return false
        }
        return true
    }
    
    public func flashView(closure: @escaping () -> Void) {
        self.flashView.alpha = 1.0
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.flashView.alpha = 0.0
            }, completion: { (completed: Bool) -> Void in
                closure()
        })
    }
    
    public func saveToLibrary() {
        self.flashView { () -> Void in
            let image = self.renderedImage()
            ALAssetsLibrary().writeImage(toSavedPhotosAlbum: image.cgImage, orientation: .up, completionBlock: { (url, error) in
                if error != nil {
                    UIAlertView(title: "Error", message: "The Photo could not be saved.", delegate: nil, cancelButtonTitle: "OK").show()
                }
            })
        }
    }
    
    func renderedImage() -> UIImage {
        let bounds = UIScreen.main.bounds
        let scale = UIScreen.main.scale
        let size = CGSize(width: bounds.width * scale, height: bounds.height * scale)
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        return self.imageWithColor(rect: rect, color: self.view.backgroundColor!)
    }
    
    func imageWithColor(rect: CGRect, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        let ctx = UIGraphicsGetCurrentContext()
        ctx!.setFillColor(color.cgColor)
        ctx!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
