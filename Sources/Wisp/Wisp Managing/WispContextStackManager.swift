//
//  CardStackManager.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import Foundation

@MainActor internal class WispContextStackManager {
    
    private var stack: [WispContext] = []

    var currentContext: WispContext? {
        get {
            return stack.last
        }
        set {
            if let newValue {
                _ = stack.popLast()
                stack.append(newValue)
            } else {
                _ = stack.popLast()
            }
        }
    }

    func push(_ context: WispContext) {
        stack.append(context)
    }
    
    func pop() -> WispContext? {
        return stack.popLast()
    }
}
