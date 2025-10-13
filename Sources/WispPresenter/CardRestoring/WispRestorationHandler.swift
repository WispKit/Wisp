//
//  File.swift
//  Wisp
//
//  Created by 김민성 on 10/12/25.
//

import Combine
import UIKit

internal final class WispRestorationHandler {
    
    private weak var delegate: WispPresenterDelegate?
    
    private var cancellables: Set<AnyCancellable> = []
    
    internal init(delegate: WispPresenterDelegate? = nil) {
        self.delegate = delegate
    }
    
    private func getDistanceDiff(startFrame: CGRect, endFrame: CGRect) -> CGPoint {
        return .init(
            x: startFrame.center.x - endFrame.center.x,
            y: startFrame.center.y - endFrame.center.y
        )
    }
    
    private func getScaleT(startFrame: CGRect, endFrame: CGRect) -> CGAffineTransform {
        return.init(
            scaleX: startFrame.width / endFrame.width,
            y: startFrame.height / endFrame.height,
        )
    }
    
    private func syncRestoringCardFrameToCell(_ card: RestoringCard, context: WispContext) {
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
    
    func restore(startFrame: CGRect, initialVelocity: CGPoint, context: WispContext, completion: (() -> Void)?) {
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
        
        guard let currentWindow = context.sourceViewController?.view.window else {
            return
        }
        
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
        
        let isAnimationFast = context.configuration.animation.speed == .fast
        let dampingRatio = isAnimationFast ? 1.0 : 0.8
        let movingDuration = context.configuration.animation.speed.rawValue
        let sizeDuration = isAnimationFast ? movingDuration : (movingDuration + 0.1)
        
        let timingParameters = UISpringTimingParameters(dampingRatio: dampingRatio, initialVelocity: velocityVector)
        let cardRestoringMovingAnimator = UIViewPropertyAnimator(duration: movingDuration, timingParameters: timingParameters)
        let cardRestoringSizeAnimator = UIViewPropertyAnimator(duration: sizeDuration, dampingRatio: 1)
        
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
            guard let self else { return }
            restoringCard.setStateAfterRestore()
            context.collectionView?.makeSelectedCellVisible(indexPath: destinationIndexPath)
            restoringCard.transform = .identity
            restoringCard.removeFromSuperview()
            if let cancellable {
                self.cancellables.remove(cancellable)
            }
            self.delegate?.wispDidRestore()
            completion?()
        }
        
        cardRestoringMovingAnimator.startAnimation()
        cardRestoringSizeAnimator.startAnimation()
    }
    
}
