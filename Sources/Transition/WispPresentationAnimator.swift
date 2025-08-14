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
        return context.configuration.animation.speed.rawValue
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let wispVC = transitionContext.viewController(forKey: .to) else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        let wispView = wispVC.view!
        
        containerView.addSubview(cardContainerView)
        cardContainerView.addSubview(wispView)
        
        let configuration = context.configuration
        let presentedAreaInset = context.configuration.layout.presentedAreaInset
        
        // ⚠️ Switching back to Auto Layout here may cause safe area layout issues,
        // especially when presenting view controllers with navigation bars.
        cardContainerView.translatesAutoresizingMaskIntoConstraints = true
        cardContainerView.frame = startFrame
        
        let initialSize = startFrame.size
        let finalSize: CGSize = .init(
            width: containerView.frame.width - (presentedAreaInset.left + presentedAreaInset.right),
            height: containerView.frame.height - (presentedAreaInset.top + presentedAreaInset.bottom)
        )
        
        wispView.translatesAutoresizingMaskIntoConstraints = false
        let wispViewWidthConstraint = wispView.widthAnchor.constraint(equalToConstant: finalSize.width)
        let wispViewHeightConstraint = wispView.heightAnchor.constraint(equalToConstant: finalSize.height)
        wispViewWidthConstraint.isActive = true
        wispViewHeightConstraint.isActive = true
        
        let wispViewTopConstraint = wispView.topAnchor.constraint(equalTo: cardContainerView.topAnchor)
        let wispViewLeadingConstraint = wispView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor)
        let wispViewTrailingConstraint = wispView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor)
        let wispViewBottomConstraint = wispView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
        
        wispView.centerXAnchor.constraint(equalTo: cardContainerView.centerXAnchor).isActive = true
        wispView.centerYAnchor.constraint(equalTo: cardContainerView.centerYAnchor).isActive = true
        wispVC.view.transform = .init(
            scaleX: initialSize.width / finalSize.width,
            y: initialSize.height / finalSize.height
        )
        
        cardContainerView.clipsToBounds = true
        cardContainerView.layer.cornerCurve = .continuous
        cardContainerView.layer.cornerRadius = configuration.layout.initialCornerRadius
        cardContainerView.layer.maskedCorners = configuration.layout.initialMaskedCorner
        containerView.layoutIfNeeded()
        
        animator.addAnimations { [weak self] in
            guard let self else { return }
            guard let window = containerView.window else { return }
            cardContainerView.frame = .init(
                x: presentedAreaInset.left,
                y: presentedAreaInset.top,
                width: window.bounds.width - (presentedAreaInset.left + presentedAreaInset.right),
                height: window.bounds.height - (presentedAreaInset.top + presentedAreaInset.bottom)
            )
            cardContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.cardContainerView.layer.cornerRadius = configuration.layout.finalCornerRadius
            self.cardContainerView.layer.maskedCorners = configuration.layout.finalMaskedCorner
            self.cardContainerView.layer.cornerCurve = .continuous
            
            wispViewWidthConstraint.isActive = false
            wispViewHeightConstraint.isActive = false
            
            wispViewTopConstraint.isActive = true
            wispViewLeadingConstraint.isActive = true
            wispViewTrailingConstraint.isActive = true
            wispViewBottomConstraint.isActive = true
            
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
