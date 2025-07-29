//
//  WispConfiguration.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


public struct WispConfiguration {
    let animationDuration: TimeInterval
    let backgroundDimColor: UIColor
    let hapticsEnabled: Bool
    let cornerRadius: CGFloat
    // ...

    public static let `default` = WispConfiguration(
        animationDuration: 0.5,
        backgroundDimColor: .black.withAlphaComponent(0.2),
        hapticsEnabled: true,
        cornerRadius: 12
    )
}
