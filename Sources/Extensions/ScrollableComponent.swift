//
//  ScrollableComponent.swift
//  Wisp
//
//  Created by 김민성 on 8/12/25.
//

import UIKit
import MapKit

internal protocol ScrollableComponent: UIView { }

// MARK: - UIControl

extension UIDatePicker: ScrollableComponent { }
extension UISegmentedControl: ScrollableComponent { }
extension UISlider: ScrollableComponent { }
extension UISwitch: ScrollableComponent { }

// MARK: - MapKit

extension MKMapView: ScrollableComponent { }
