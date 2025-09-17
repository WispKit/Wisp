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
    private init() {}
    
    let contextStackManager = WispContextStackManager()
    private var cancellables: Set<AnyCancellable> = []
    var currentContext: WispContext? {
        contextStackManager.currentContext
    }
    
    var transitioningDelegate: WispTransitioningDelegate? = nil
    
    func handleInteractiveDismissEnded(startFrame: CGRect, initialVelocity: CGPoint) {
        guard let context = currentContext else { return }
        // 컬렉션뷰 구독 초기화
        cancellables = []
        restore(startFrame: startFrame, initialVelocity: initialVelocity, using: consume context)
        contextStackManager.pop()
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
            y: startFrame.height / endFrame.height,
        )
    }
    
    func syncRestoringCardFrameToCell(
        _ card: RestoringCard,
        context: WispContext
    ) {
        guard let destinationIndexPath = context.destinationIndexPath,
              let restoringCell = context.collectionView?.cellForItem(at: destinationIndexPath)
        else {
            return
        }
        restoringCell.alpha = 0
        card.frame = restoringCell.convert(
            restoringCell.contentView.frame,
            to: context.collectionView
        )
        context.sourceViewController?.view.layoutIfNeeded()
    }
    
    func restore(startFrame: CGRect, initialVelocity: CGPoint, using context: WispContext) {
        let restoringCard = RestoringCard()
        // collectionView, 돌아가려는 셀이 존재하지 않는 경우
        guard let collectionView = context.collectionView,
              let destinationIndexPath = context.destinationIndexPath,
              let targetCell = collectionView.cellForItem(at: destinationIndexPath)
        else {
            cancellables = []
            context.collectionView?.makeSelectedCellVisible(indexPath: context.sourceIndexPath)
            restoringCard.setStateAfterRestore()
            restoringCard.transform = .identity
            restoringCard.removeFromSuperview()
            return
        }
        
        if context.isIndexPathChanged {
            collectionView.makeSelectedCellInvisible(indexPath: destinationIndexPath)
            collectionView.makeSelectedCellVisible(indexPath: context.sourceIndexPath)
        }
        
        // addSubView
        collectionView.addSubview(restoringCard)
        collectionView.bringSubviewToFront(restoringCard)
        syncRestoringCardFrameToCell(restoringCard, context: context)
        
        // collection view scrolling(including orthogonal scrolling) subscribing
        let cancellable = context.collectionView?.scrollDetected
            .sink { [weak self] _ in
                guard let self else { return }
                self.syncRestoringCardFrameToCell(restoringCard, context: context)
            }
        cancellable?.store(in: &cancellables)
        
        guard let currentWindow = context.sourceViewController?.view.window else { return }
        
        // restoring card 초기 위치, 크기 설정 위한 사전 계산
        let convertedStartFrame = currentWindow.convert(startFrame, to: collectionView)
        let convertedCellFrame = targetCell.convert(targetCell.contentView.frame, to: collectionView)
        let scaleT = getScaleT(startFrame: startFrame, endFrame: convertedCellFrame)
        let distanceDiff = getDistanceDiff(startFrame: convertedStartFrame, endFrame: convertedCellFrame)
        
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
        let cornerRadiusProportion = max(startFrame.width / convertedCellFrame.width,
                                         startFrame.height / convertedCellFrame.height)
        restoringCard.layer.cornerRadius = context.configuration.layout.finalCornerRadius / cornerRadiusProportion
        
        let cellRecentImage = UIGraphicsImageRenderer(bounds: targetCell.contentView.bounds).image { _ in
            targetCell.contentView.drawHierarchy(in: targetCell.contentView.bounds, afterScreenUpdates: true)
        }
        let imageView = UIImageView(image: cellRecentImage)
        imageView.backgroundColor = targetCell.backgroundConfiguration?.backgroundColor ?? targetCell.backgroundColor
        
        // restoring card snapshot 설정
        restoringCard.setupSnapshots(
            viewSnapshot: context.presentedSnapshot,
            cellSnapshot: imageView
        )
        
        // restoring card 초기 위치 확정
        restoringCard.superview?.layoutIfNeeded()
        
        // ------ animation ------ //
        
        let velocityVector = WispUtil.getRestorationInitialVelocity(
            for: initialVelocity,
            animatingDistance: distanceDiff.inverted()
        )
        let timingParameters = UISpringTimingParameters(dampingRatio: 0.8, initialVelocity: velocityVector)
        let cardRestoringMovingAnimator = UIViewPropertyAnimator(duration: 0.6, timingParameters: timingParameters)
        let cardRestoringSizeAnimator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 1)
        
        cardRestoringMovingAnimator.addAnimations {
            var newCenter = restoringCard.center
            newCenter.x -= distanceDiff.x
            newCenter.y -= distanceDiff.y
            restoringCard.center = newCenter
            currentWindow.layoutIfNeeded()
        }
        
        cardRestoringSizeAnimator.addAnimations {
            restoringCard.switchSnapshots()
            restoringCard.transform = .identity
            restoringCard.layer.cornerRadius = context.configuration.layout.initialCornerRadius
            restoringCard.layer.maskedCorners = context.configuration.layout.initialMaskedCorner
            currentWindow.layoutIfNeeded()
        }
        
        cardRestoringSizeAnimator.addCompletion { [weak self] stoppedPosition in
            restoringCard.setStateAfterRestore()
            context.collectionView?.makeSelectedCellVisible(indexPath: destinationIndexPath)
            restoringCard.transform = .identity
            restoringCard.removeFromSuperview()
            if let cancellable {
                self?.cancellables.remove(cancellable)
            }
        }
        
        cardRestoringMovingAnimator.startAnimation()
        cardRestoringSizeAnimator.startAnimation()
    }
    
}
