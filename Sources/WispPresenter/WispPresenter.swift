//
//  WispPresenter.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import Combine
import UIKit

public protocol WispPresenterDelegate: AnyObject {
    func wispWillRestore()
    func wispDidRestore()
}

public final class WispPresenter {
    
    public weak var delegate: (any WispPresenterDelegate)?
    
    private weak var hostViewController: UIViewController?
    private weak var previousPresenter: WispPresenter? = nil
    private weak var nextPresenter: WispPresenter? = nil
    
    internal private(set) var context: WispContext? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    private var transitioningDelegate: WispTransitioningDelegate? = nil
    
    internal init(host: UIViewController) {
        self.hostViewController = host
    }
    
}


// MARK: - Public Presentation
public extension WispPresenter {
    
    @MainActor func present(
        _ viewControllerToPresent: UIViewController,
        collectionView: WispableCollectionView,
        at indexPath: IndexPath,
        configuration: WispConfiguration = .default
    ) {
        guard let hostViewController else { return }
        guard hostViewController.view.containsAsSubview(collectionView) else {
            print("Collection view is not subview of presenting view controller's view.")
            print("Custom transition will be cancelled and run modal presentation.")
            viewControllerToPresent.modalPresentationStyle = .formSheet
            hostViewController.present(viewControllerToPresent, animated: true)
            return
        }
        
        /// 바로 직전의 예외처리로 인한 modal presentation을 `dismiss`하고 난 직후 바로 다른 VC를 `present`하려고 할 때,
        /// `dismiss`가 완전히 끝나기 전인 경우,
        /// (`present`되는 시점에 `presentingViewController`의 `presentedViewController` 가 존재하면)
        /// 의도한 custom transition 대신 `.fullScreen` 방식으로 transition되는 문제 발생.
        /// 시스템이 자동으로 fullscreen transition을 채택하는 것 같다.
//        guard sourceViewController.presentedViewController == nil else { return }
        
        let selectedCell = collectionView.cellForItem(at: indexPath)
        let cellSnapshot = selectedCell?.snapshotView(afterScreenUpdates: false)
        
        let wispContext = WispContext(
            sourceViewController: hostViewController,
            viewControllerToPresent: viewControllerToPresent,
            collectionView: collectionView,
            sourceIndexPath: indexPath,
            destinationIndexPath: indexPath,
            sourceCellSnapshot: cellSnapshot,
            presentedSnapshot: nil,
            configuration: configuration
        )
        
        self.context = wispContext
        let wispTransitioningDelegate = WispTransitioningDelegate(
            context: wispContext,
        )
        self.transitioningDelegate = wispTransitioningDelegate
        
        viewControllerToPresent.modalPresentationStyle = .custom
        viewControllerToPresent.transitioningDelegate = wispTransitioningDelegate
        let nextPresenter = viewControllerToPresent.wisp
        self.nextPresenter = nextPresenter
        nextPresenter.previousPresenter = self
        
        hostViewController.view.endEditing(true)
        hostViewController.present(viewControllerToPresent, animated: true)
    }
    
}


// MARK: - Public Dismissal
public extension WispPresenter {
    
    @MainActor
    func dismiss(to indexPath: IndexPath? = nil, animated: Bool = true, autoFallback: Bool = false) {
        guard let hostViewController else {
            return
        }
        
        // validating if the vc to be dismissed is presented by `Wisp`
        guard let actualVCToDismiss = hostViewController.presentingViewController?.presentedViewController,
              let previousPresenter = actualVCToDismiss.wisp.previousPresenter,
              let previousContext = previousPresenter.context,
              actualVCToDismiss == previousContext.viewControllerToPresent
        else {
            if autoFallback {
                hostViewController.dismiss(animated: animated)
            } else {
                print("""
                      Warning: Attempted to dismiss a view controller that was not presented with Wisp. No action was taken.
                      You can either set `autoFallback: true` to allow Wisp to automatically fallback to a standard UIKit dismissal,
                      or call the standard `dismiss(animated:completion:)` method directly on the view controller to handle dismissal explicitly.
                      """)
            }
            return
        }
        
        // switching previousPresenter's context to apply the `indexPath` parameter.
        if let newDestinationIndexPath = indexPath {
            var indexPathUpdatedContext = previousContext
            indexPathUpdatedContext.destinationIndexPath = indexPath ?? indexPathUpdatedContext.sourceIndexPath
            previousPresenter.context = indexPathUpdatedContext
        }
        
        if animated {
            previousPresenter.dismissPresentedVC()
        } else {
            hostViewController.dismiss(animated: false)
            previousPresenter.context?.collectionView?.makeSelectedCellVisible(indexPath: previousContext.sourceIndexPath)
        }
    }
    
    @MainActor
    func setDestinationIndex(to indexPath: IndexPath) {
        guard let hostViewController else {
            return
        }
        
        guard let actualVCToDismiss = hostViewController.presentingViewController?.presentedViewController,
              let previousPresenter = actualVCToDismiss.wisp.previousPresenter,
              let previousContext = previousPresenter.context,
              actualVCToDismiss == previousContext.viewControllerToPresent
        else {
            return
        }
        var indexPathUpdatedContext = previousContext
        indexPathUpdatedContext.destinationIndexPath = indexPath
        previousPresenter.context = indexPathUpdatedContext
    }
    
}


internal extension WispPresenter {
    
    func dismissPresentedVC(withVelocity initialVelocity: CGPoint = .zero) {
        guard let context,
              let viewControllerToDismiss = context.viewControllerToPresent
        else {
            return
        }
        
        guard let transitioningDelegate else {
            context.collectionView?.makeSelectedCellVisible(indexPath: context.sourceIndexPath)
            viewControllerToDismiss.dismiss(animated: true)
            return
        }
        
        if viewControllerToDismiss.isBeingPresented {
            transitioningDelegate.presentingAnimator.stopAnimation(false)
            transitioningDelegate.presentingAnimator.finishAnimation(at: .current)
        }
        
        Task {
            await startWispDismissing(with: initialVelocity)
        }
    }
    
}


private extension WispPresenter {
    
    @MainActor func startWispDismissing(with initialVelocity: CGPoint) {
        guard let context,
              let viewControllerToDismiss = context.viewControllerToPresent
        else {
            return
        }
        
        let snapshot = viewControllerToDismiss.view.snapshotView(afterScreenUpdates: true)
        self.context?.setPresentedSnapshot(snapshot)
        guard let cardContainerView = viewControllerToDismiss.view.superview else {
            return
        }
        startCardRestoring(startFrame: cardContainerView.frame, initialVelocity: initialVelocity)
        viewControllerToDismiss.dismiss(animated: false)
        
    }
    
}


private extension WispPresenter {
    
    func startCardRestoring(startFrame: CGRect, initialVelocity: CGPoint) {
        // 컬렉션뷰 구독 초기화
        cancellables = []
        delegate?.wispWillRestore()
        restore(startFrame: startFrame, initialVelocity: initialVelocity)
    }
    
}


// MARK: - Restoring 관련
private extension WispPresenter {
    
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
    
    func restore(startFrame: CGRect, initialVelocity: CGPoint) {
        guard let context else {
            return
        }
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
            restoringCard.setStateAfterRestore()
            context.collectionView?.makeSelectedCellVisible(indexPath: destinationIndexPath)
            restoringCard.transform = .identity
            restoringCard.removeFromSuperview()
            if let cancellable {
                self?.cancellables.remove(cancellable)
            }
            self?.delegate?.wispDidRestore()
        }
        
        cardRestoringMovingAnimator.startAnimation()
        cardRestoringSizeAnimator.startAnimation()
    }
    
}
