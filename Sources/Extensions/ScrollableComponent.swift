//
//  ScrollableComponent.swift
//  Wisp
//
//  Created by 김민성 on 8/12/25.
//

import UIKit

internal protocol ScrollableComponent: UIView { }

extension UIDatePicker: ScrollableComponent { }
extension UISegmentedControl: ScrollableComponent { }
extension UISlider: ScrollableComponent { }
extension UISwitch: ScrollableComponent { }
