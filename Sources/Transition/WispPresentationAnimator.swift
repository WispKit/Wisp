//
//  WispPresentationAnimator.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


internal final class WispPresentationAnimator: NSObject {
    
    let animator: UIViewPropertyAnimator
    
    private let context: WispContext
    private let cardContainerView: UIView
    private var startFrame: CGRect
    private let interactor: UIPercentDrivenInteractiveTransition
    
    init(
        animator: UIViewPropertyAnimator,
        cardContainerView: UIView,
        startFrame: CGRect,
        interactor: UIPercentDrivenInteractiveTransition,
        context: WispContext
    ) {
        self.animator = animator
        self.cardContainerView = cardContainerView
        self.startFrame = startFrame
        self.interactor = interactor
        self.context = context
    }
    
}

extension WispPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return context.configuration.animationSpeed.rawValue
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let wispVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        let wispView = wispVC.view!
        
        // Set a dummy frame to prevent the 'UIViewAlertForUnsatisfiableConstraints' symbolic breakpoint.
        // This frame is temporary and not the actual frame of the card.
        // The actual layout is handled by Auto Layout.
        containerView.addSubview(cardContainerView)
        cardContainerView.frame = containerView.bounds
        cardContainerView.addSubview(wispView)
        wispView.frame = cardContainerView.bounds
        
        let configuration = context.configuration
        let presentedAreaInset = context.configuration.presentedAreaInset
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        wispView.translatesAutoresizingMaskIntoConstraints = false
        
        // Setting Initial Position
        let topConstraint = cardContainerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: startFrame.minY)
        let leftConstraint = cardContainerView.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: startFrame.minX)
        let rightConstraint = cardContainerView.rightAnchor.constraint(
            equalTo: containerView.rightAnchor,
            constant: -(containerView.frame.width - startFrame.maxX)
        )
        let bottomConstraint = cardContainerView.bottomAnchor.constraint(
            equalTo: containerView.bottomAnchor,
            constant: -(containerView.frame.height - startFrame.maxY)
        )
        NSLayoutConstraint.activate([topConstraint, leftConstraint, rightConstraint, bottomConstraint,])
        
        let initialSize = startFrame.size
        let finalSize: CGSize = .init(
            width: containerView.frame.width - (presentedAreaInset.left + presentedAreaInset.right),
            height: containerView.frame.height - (presentedAreaInset.top + presentedAreaInset.bottom)
        )
        wispView.widthAnchor.constraint(equalToConstant: finalSize.width).isActive = true
        wispView.heightAnchor.constraint(equalToConstant: finalSize.height).isActive = true
        wispView.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor).isActive = true
        wispView.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor).isActive = true
        wispVC.view.transform = .init(
            scaleX: initialSize.width / finalSize.width,
            y: initialSize.height / finalSize.height
        )
        
        cardContainerView.clipsToBounds = true
        cardContainerView.layer.cornerCurve = .continuous
        cardContainerView.layer.cornerRadius = configuration.initialCornerRadius
        cardContainerView.layer.maskedCorners = configuration.initialMaskedCorner
        containerView.layoutIfNeeded()
        
        animator.addAnimations { [weak self] in
            guard let self else { return }
            topConstraint.constant = presentedAreaInset.top
            leftConstraint.constant = presentedAreaInset.left
            rightConstraint.constant = -presentedAreaInset.right
            bottomConstraint.constant = -presentedAreaInset.bottom
            
            self.cardContainerView.layer.cornerRadius = configuration.finalCornerRadius
            self.cardContainerView.layer.maskedCorners = configuration.finalMaskedCorner
            self.cardContainerView.layer.cornerCurve = .continuous
            wispVC.view.transform = .identity
            containerView.layoutIfNeeded()
        }
        
        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        animator.startAnimation()
        
        // interactivce한 transition이나, 사용자와 지속적으로 상호작용하면서 present하지는 않는다.
        // 단지 뷰가 자동으로 펼쳐지는데, 펼쳐지는 중간에 사용자가 이 뷰를 잡을 수 있는 것.
        // 그래서 처음에는 그냥 자동으로 애니메이션이 실행되도록 구현함.
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.context.collectionView?.cellForItem(at: self.context.indexPath)?.alpha = 0
            self.interactor.finish()
        }
        
    }
    
}
