//
//  File.swift
//  Wisp
//
//  Created by 김민성 on 9/11/25.
//

import CoreGraphics

enum WispUtil {
    
    static func getRestorationInitialVelocity(
        for gestureVelocity: CGPoint,
        animatingDistance distance: CGPoint
    ) -> CGVector {
        var animationVelocity = CGVector.zero
        let xDistance = distance.x
        let yDistance = distance.y
        if xDistance != 0 {
            animationVelocity.dx = gestureVelocity.x / xDistance
        }
        if yDistance != 0 {
            animationVelocity.dy = gestureVelocity.y / yDistance
        }
        return animationVelocity
    }
    
}
