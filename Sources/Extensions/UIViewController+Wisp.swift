//
//  File.swift
//  Wisp
//
//  Created by 김민성 on 7/29/25.
//

import UIKit

private var wispKey: UInt8 = 0

public extension UIViewController {
    
    var wisp: WispPresenter {
        if let existing = objc_getAssociatedObject(self, &wispKey) as? WispPresenter {
            return existing
        }
        let newPresenter = WispPresenter(source: self)
        objc_setAssociatedObject(self, &wispKey, newPresenter, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return newPresenter
    }
    
}
