//
//  File.swift
//  Wisp
//
//  Created by 김민성 on 9/15/25.
//

import UIKit

public extension UICollectionViewCompositionalLayout {
    
    static var wisp: WispLayoutMakerType {
        return WispLayoutMaker()
    }
    
}
