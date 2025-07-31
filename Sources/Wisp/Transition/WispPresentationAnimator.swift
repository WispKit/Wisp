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
    private var startFrame: CGRect
    private let interactor: UIPercentDrivenInteractiveTransition
    
    init(
        animator: UIViewPropertyAnimator,
        startFrame: CGRect,
        interactor: UIPercentDrivenInteractiveTransition,
        context: WispContext
    ) {
        self.animator = animator
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
        containerView.addSubview(wispView)
        let configuration = context.configuration
        
        wispVC.view.clipsToBounds = true
        wispVC.view.frame = startFrame
        wispVC.view.layer.cornerRadius = configuration.initialCornerRadius
        containerView.layoutIfNeeded()
        /// - Important: 반드시 wispVC.view의 레이아웃을 설정한 뒤에 호출되어야 함.
        wispView.translatesAutoresizingMaskIntoConstraints = false
        
        animator.addAnimations { [weak self] in
            guard let self else { return }
            NSLayoutConstraint.activate([
                wispView.topAnchor.constraint(equalTo: containerView.topAnchor,
                                              constant: configuration.presentedAreaInset.top),
                wispView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor,
                                                  constant: configuration.presentedAreaInset.leading),
                wispView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor,
                                                   constant: -configuration.presentedAreaInset.trailing),
                wispView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor,
                                                 constant: -configuration.presentedAreaInset.bottom),
            ])
            wispVC.view.layer.cornerRadius = configuration.finalCornerRadius
            wispVC.view.layer.maskedCorners = configuration.finalMaskedCorner
            wispVC.view.layer.cornerCurve = .continuous
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
