//
//  File.swift
//  Wisp
//
//  Created by 김민성 on 7/29/25.
//

import UIKit

public extension UIViewController {
    
    var wisp: WispPresenter {
        return WispPresenter(presentingVC: self)
    }
    
}
