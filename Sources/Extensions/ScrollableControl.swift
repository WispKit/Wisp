//
//  ScrollableControl.swift
//  Wisp
//
//  Created by 김민성 on 8/12/25.
//

import UIKit

protocol ScrollableControl: UIControl { }

extension UIDatePicker: ScrollableControl { }
extension UISegmentedControl: ScrollableControl { }
extension UISlider: ScrollableControl { }
extension UISwitch: ScrollableControl { }
