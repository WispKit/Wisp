//
//  WispConfiguration.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

public struct WispConfiguration {
    
    public struct AnimationOptions {
        // Raw value means the duration of presenting animation.
        public enum Speed: Double {
            case slow = 0.8
            case normal = 0.6
            case fast = 0.4
        }

        public var speed: Speed = .normal

        public init() {}
    }
    
    public struct GestureOptions {
        public var allowedDirections: GestureDirection = [.horizontalOnly, .down]
        public var dismissByTap: Bool = true
        
        public init() {}
    }
    
    public struct LayoutOptions {
        public var presentedAreaInset: UIEdgeInsets = .zero
        public var initialCornerRadius: CGFloat = 0
        public var finalCornerRadius: CGFloat = 20
        public var initialMaskedCorner: CACornerMask = [.layerMaxXMaxYCorner,
                                                                      .layerMaxXMinYCorner,
                                                                      .layerMinXMaxYCorner,
                                                                      .layerMinXMinYCorner]
        public var finalMaskedCorner: CACornerMask = [.layerMaxXMaxYCorner,
                                                                    .layerMaxXMinYCorner,
                                                                    .layerMinXMaxYCorner,
                                                                    .layerMinXMinYCorner]
        
        public init() {}
    }
    
    public static let `default` = WispConfiguration.init()
    
    package private(set) var animation = AnimationOptions()
    package private(set) var gesture = GestureOptions()
    package private(set) var layout = LayoutOptions()
    
    private init() {}
    
    public init(configure: (_ config: inout WispConfiguration) -> Void) {
        self.init()
        configure(&self)
    }
    
    public mutating func setAnimation(_ configure: (_ animation: inout AnimationOptions) -> Void) {
        configure(&animation)
    }
    
    public mutating func setGesture(_ configure: (_ gesture: inout GestureOptions) -> Void) {
        configure(&gesture)
    }
    
    public mutating func setLayout(_ configure: (_ layout: inout LayoutOptions) -> Void) {
        configure(&layout)
    }
    
}
