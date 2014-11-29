//
//  ShakeView.swift
//  himbo
//
//  Created by Marcus Kida on 29/11/2014.
//  Copyright (c) 2014 Marcus Kida. All rights reserved.
//

import UIKit

enum ShakeDirection {
    case Horizontal, Vertical
}

extension UIView {
    func shake(times: Int, direction: ShakeDirection) {
        shake(times, iteration: 0, direction: 1, shakeDirection: direction, delta: 10, speed: 0.08)
    }
    private func shake(times: Int, iteration: Int, direction: CGFloat, shakeDirection: ShakeDirection, delta: CGFloat, speed: NSTimeInterval) {
        UIView.animateWithDuration(speed, animations: { () -> Void in
            self.layer.setAffineTransform((shakeDirection == ShakeDirection.Horizontal) ? CGAffineTransformMakeTranslation(delta * direction, 0) : CGAffineTransformMakeTranslation(0, delta * direction))
            }) { (finished: Bool) -> Void in
                if iteration >= times {
                    UIView.animateWithDuration(speed, animations: { () -> Void in
                        self.layer.setAffineTransform(CGAffineTransformIdentity)
                    })
                    return
                }
                self.shake((times - 1), iteration: (iteration + 1), direction: (direction * -1), shakeDirection: shakeDirection, delta: delta, speed: speed)
        }
    }
}
