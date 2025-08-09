//
//  File.swift
//  Wisp
//
//  Created by 김민성 on 8/9/25.
//

import UIKit

public extension WispConfiguration {
    
    // MARK: - Deprecated Initializer
    @available(*, deprecated, message: "\nUse the new DSL-based configuration. For detailed usage, please refer to the Wisp GitHub README.")
    init(
        animationSpeed: AnimationOptions.Speed = .normal,
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
        self.init {
            $0.setAnimation { animation in
                animation.speed = animationSpeed
            }
            $0.setLayout { layout in
                layout.presentedAreaInset = presentedAreaInset
                layout.initialCornerRadius = initialCornerRadius
                layout.finalCornerRadius = finalCornerRadius
                layout.initialMaskedCorner = initialMaskedCorner
                layout.finalMaskedCorner = finalMaskedCorner
            }
        }
    }
    
    // MARK: - Deprecated Properties
    @available(*, deprecated, message: "Use animation.speed instead.")
    var animationSpeed: AnimationOptions.Speed {
        get { animation.speed }
    }
    
    @available(*, deprecated, message: "Use layout.presentedAreaInset instead.")
    var presentedAreaInset: UIEdgeInsets {
        get { layout.presentedAreaInset }
    }
    
    @available(*, deprecated, message: "Use layout.initialCornerRadius instead.")
    var initialCornerRadius: CGFloat {
        get { layout.initialCornerRadius }
    }
    
    @available(*, deprecated, message: "Use layout.finalCornerRadius instead.")
    var finalCornerRadius: CGFloat {
        get { layout.finalCornerRadius }
    }
    
    @available(*, deprecated, message: "Use layout.initialMaskedCorner instead.")
    var initialMaskedCorner: CACornerMask {
        get { layout.initialMaskedCorner }
    }
    
    @available(*, deprecated, message: "Use layout.finalMaskedCorner instead.")
    var finalMaskedCorner: CACornerMask {
        get { layout.finalMaskedCorner }
    }
    
}
