//
//  GestureDirection.swift
//  Wisp
//
//  Created by 김민성 on 8/9/25.
//

public struct GestureDirection: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let up = GestureDirection(rawValue: 1 << 0)
    public static let left = GestureDirection(rawValue: 1 << 1)
    public static let right = GestureDirection(rawValue: 1 << 2)
    public static let down = GestureDirection(rawValue: 1 << 3)
    
    public static let none: GestureDirection = []
    public static let all: GestureDirection = [.up, .left, .right, .down]
    public static let horizontalOnly: GestureDirection = [.left, .right]
    public static let verticalOnly: GestureDirection = [.up, .down]
    
}
