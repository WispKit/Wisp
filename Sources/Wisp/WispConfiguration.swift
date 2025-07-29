//
//  WispConfiguration.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


public struct WispConfiguration {
    let animationDuration: TimeInterval
    let cornerRadius: CGFloat

    public static let `default` = WispConfiguration(
        animationDuration: 0.5,
        cornerRadius: 12
    )
}
