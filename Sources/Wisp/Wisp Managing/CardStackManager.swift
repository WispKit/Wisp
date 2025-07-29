//
//  CardStackManager.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import Foundation

internal class CardStackManager {
    private var stack: [RestoringCard] = []
    
    func push(_ context: RestoringCard) {
        stack.append(context)
    }
    
    func pop() -> RestoringCard? {
        guard !stack.isEmpty else { return nil }
        return stack.removeLast()
    }

    func currentContext() -> RestoringCard? {
        return stack.last
    }
}
