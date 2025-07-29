//
//  WispManager.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

import Combine

@MainActor final internal class WispManager {
    
    static let shared = WispManager()
    
    let cardRestoringSizeAnimator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 1)
    let cardRestoringMovingAnimator = UIViewPropertyAnimator(duration: 0.6, dampingRatio: 0.8)
    
    private init() {}
    
    private let cardStackManager = CardStackManager()
    private let restoringCard = RestoringCard()
    private var cancellables: Set<AnyCancellable> = []
    internal var activeContext: WispContext?
    
    func handleInteractiveDismissEnded(startFrame: CGRect) {
        guard let context = activeContext else { return }
        // 컬렉션뷰 구독 초기화
        cancellables = []
        restore(startFrame: startFrame, using: consume context)
        activeContext = nil
    }
    
}


// MARK: - Restoring 관련
private extension WispManager {
    
    func getDistanceDiff(startFrame: CGRect, endFrame: CGRect) -> CGPoint {
        return .init(
            x: startFrame.center.x - endFrame.center.x,
            y: startFrame.center.y - endFrame.center.y
        )
    }
    
    func getScaleT(startFrame: CGRect, endFrame: CGRect) -> CGAffineTransform {
        return.init(
            scaleX: startFrame.width / endFrame.width,
            y: startFrame.height / endFrame.height
        )
    }
    
    func syncRestoringCardFrameToCell(
        _ card: RestoringCard,
        context: WispContext
    ) {
        print(#function)
        guard let restoringCell = context.collectionView?.cellForItem(at: context.indexPath) else {
            return
        }
        guard let currentWindow = context.sourceViewController?.view.window else {
            return
        }
        restoringCell.alpha = 0
        card.frame = restoringCell.convert(
            restoringCell.contentView.frame,
            to: currentWindow
        )
        currentWindow.layoutIfNeeded()
    }
    
    func restore(startFrame: CGRect, using context: WispContext) {
        cardRestoringSizeAnimator.stopAnimation(false)
        cardRestoringSizeAnimator.finishAnimation(at: .current)
        cardRestoringMovingAnimator.stopAnimation(false)
        cardRestoringMovingAnimator.finishAnimation(at: .current)
        
        // addSubView
        context.sourceViewController?.view.addSubview(restoringCard)
        context.sourceViewController?.view.bringSubviewToFront(restoringCard)
        syncRestoringCardFrameToCell(restoringCard, context: context)
        
        // collection view scrolling subscribing
        context.collectionView?.scrollDetected.sink { [weak self] _ in
            guard let self else { return }
            self.syncRestoringCardFrameToCell(self.restoringCard, context: context)
        }.store(in: &cancellables)
        
        guard let currentWindow = context.sourceViewController?.view.window else { return }
        
        // 돌아가려는 셀이 존재하지 않는 경우
        guard let targetCell = context.collectionView?.cellForItem(at: context.indexPath) else {
            cancellables = []
            context.collectionView?.makeSelectedCellVisible(indexPath: context.indexPath)
            self.restoringCard.setStateAfterRestore()
            self.restoringCard.transform = .identity
            self.restoringCard.removeFromSuperview()
            return
        }
        
        // restoring card 초기 위치, 크기 설정 위한 사전 계산
        let convertedCellFrame = targetCell.convert(targetCell.contentView.frame, to: currentWindow)
        let scaleT = getScaleT(startFrame: startFrame, endFrame: convertedCellFrame)
        let distanceDiff = getDistanceDiff(startFrame: startFrame, endFrame: convertedCellFrame)
        
        // restoring card 초기 위치, 크기 설정
        restoringCard.center.x += distanceDiff.x
        restoringCard.center.y += distanceDiff.y
        restoringCard.transform = scaleT
        
        // restoring card 초기 디자인 설정 - 기본
        restoringCard.blurView.effect = UIBlurEffect(style: .regular)
        restoringCard.isHidden = false
        restoringCard.alpha = 1
        restoringCard.clipsToBounds = true
        
        // restoring card 초기 디자인 설정 - 커스텀, WispConfiguration 활용하는 방향으로 구현
        restoringCard.layer.cornerRadius = 20
        
        // restoring card snapshot 설정
        restoringCard.setupSnapshots(
            viewSnapshot: context.presentedSnapshot,
            cellSnapshot: context.sourceCellSnapshot
        )
        
        // restoring card 초기 위치 확정
        restoringCard.superview?.layoutIfNeeded()
        
        // ------ animation ------ //
        
        cardRestoringMovingAnimator.addAnimations { [weak self] in
            self?.restoringCard.center.x -= distanceDiff.x
            self?.restoringCard.center.y -= distanceDiff.y
            currentWindow.layoutIfNeeded()
        }
        
        cardRestoringSizeAnimator.addAnimations {[weak self] in
            self?.restoringCard.switchSnapshots()
            self?.restoringCard.transform = .identity
            currentWindow.layoutIfNeeded()
        }
        
        cardRestoringSizeAnimator.addCompletion { [weak self] stoppedPosition in
            self?.restoringCard.setStateAfterRestore()
            context.collectionView?.makeSelectedCellVisible(indexPath: context.indexPath)
            self?.restoringCard.transform = .identity
            self?.restoringCard.removeFromSuperview()
            self?.cancellables = []
        }
        
        cardRestoringMovingAnimator.startAnimation()
        cardRestoringSizeAnimator.startAnimation()
    }
    
}
