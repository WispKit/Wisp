//
//  WispConfiguration.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


public struct WispConfiguration {
    
    public enum AnimationSpeed: Double {
        case slow = 0.8
        case normal = 0.6
        case fast = 0.4
    }
    
    public static let `default` = WispConfiguration(
        animationSpeed: .normal,
        initialCornerRadius: 20,
        finalCornerRadius: 37
    )
    
    let animationSpeed: AnimationSpeed
    let presentedAreaInset: UIEdgeInsets
    let initialCornerRadius: CGFloat
    let finalCornerRadius: CGFloat
    let initialMaskedCorner: CACornerMask
    let finalMaskedCorner: CACornerMask
    
    public init(
        animationSpeed: AnimationSpeed = .normal,
        presentedAreaInset: UIEdgeInsets = .zero,
        initialCornerRadius: CGFloat = 0,
        finalCornerRadius: CGFloat = 20,
        initialMaskedCorner: CACornerMask = [.layerMaxXMaxYCorner,
                                            .layerMaxXMinYCorner,
                                            .layerMinXMaxYCorner,
                                            .layerMinXMinYCorner],
        finalMaskedCorner: CACornerMask = [.layerMaxXMaxYCorner,
                                           .layerMaxXMinYCorner,
                                           .layerMinXMaxYCorner,
                                           .layerMinXMinYCorner]
    ) {
        self.animationSpeed = animationSpeed
        self.presentedAreaInset = presentedAreaInset
        self.initialCornerRadius = initialCornerRadius
        self.finalCornerRadius = finalCornerRadius
        self.initialMaskedCorner = initialMaskedCorner
        self.finalMaskedCorner = finalMaskedCorner
    }
    
}
