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
        shake(times: times, iteration: 0, direction: 1, shakeDirection: direction, delta: 10, speed: 0.08)
    }
    private func shake(times: Int, iteration: Int, direction: CGFloat, shakeDirection: ShakeDirection, delta: CGFloat, speed: TimeInterval) {
        UIView.animate(withDuration: speed, animations: { () -> Void in
            self.layer.setAffineTransform((shakeDirection == ShakeDirection.Horizontal) ? CGAffineTransform(translationX: delta * direction, y: 0) : CGAffineTransform(translationX: 0, y: delta * direction))
            }) { (finished: Bool) -> Void in
                if iteration >= times {
                    UIView.animate(withDuration: speed, animations: { () -> Void in
                        self.layer.setAffineTransform(CGAffineTransform.identity)
                    })
                    return
                }
                self.shake(times: (times - 1), iteration: (iteration + 1), direction: (direction * -1), shakeDirection: shakeDirection, delta: delta, speed: speed)
        }
    }
}
