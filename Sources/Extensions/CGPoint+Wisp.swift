//
//  File.swift
//  Wisp
//
//  Created by 김민성 on 8/9/25.
//

import Foundation

internal extension CGPoint {
    
    /// Represents gesture directions based on the `CGPoint` returned by `UIPanGestureRecognizer`'s `velocity(in:)` method.
    var gestureDirections: GestureDirection {
        let isPanningToTop = self.y < -abs(self.x)
        let isPanningToLeft = self.x < -abs(self.y)
        let isPanningToRight = self.x > abs(self.y)
        let isPanningToBottom = self.y > abs(self.x)
        
        var gestures: GestureDirection = .none
        if isPanningToTop { gestures.formUnion(.up) }
        if isPanningToBottom { gestures.formUnion(.down) }
        if isPanningToLeft { gestures.formUnion(.left) }
        if isPanningToRight { gestures.formUnion(.right) }
        
        return gestures
    }
    
}
