//
//  GestureDirections.swift
//  Wisp
//
//  Created by 김민성 on 8/9/25.
//

public struct GestureDirections: OptionSet {
    
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let up = GestureDirections(rawValue: 1 << 0)
    public static let left = GestureDirections(rawValue: 1 << 1)
    public static let right = GestureDirections(rawValue: 1 << 2)
    public static let down = GestureDirections(rawValue: 1 << 3)
    
    public static let none: GestureDirections = []
    public static let all: GestureDirections = [.up, .left, .right, .down]
    public static let horizontalOnly: GestureDirections = [.left, .right]
    public static let verticalOnly: GestureDirections = [.up, .down]
    
}
