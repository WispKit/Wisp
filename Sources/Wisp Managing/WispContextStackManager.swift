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
            return getValidCurrentContext()
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
    
    @discardableResult
    func pop() -> WispContext? {
        return stack.popLast()
    }
    
    /// Returns the topmost valid `WispContext` from the stack.
    ///
    /// If the most recent context is invalid (its `viewControllerToPresent`is no longer available),
    /// the method removes it and continues checking down the stack until a valid context is found or the stack is empty.
    ///
    /// - Returns: The topmost valid `WispContext`, or `nil` if the stack is empty.
    private func getValidCurrentContext() -> WispContext? {
        guard let lastItem = stack.last else {
            return nil
        }
        if lastItem.viewControllerToPresent?.presentingViewController != nil {
            return lastItem
        } else {
            self.pop()
            return getValidCurrentContext()
        }
    }
}
