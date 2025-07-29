//
//  WispPresentationAnimator.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


internal final class WispPresentationAnimator: NSObject {
    
    var startFrame: CGRect
    let interactor: UIPercentDrivenInteractiveTransition
    
    init(startFrame: CGRect, interactor: UIPercentDrivenInteractiveTransition) {
        self.startFrame = startFrame
        self.interactor = interactor
    }
    
}

extension WispPresentationAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: any UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let wispVC = transitionContext.viewController(forKey: .to) as! WispPresented
        let wispView = wispVC.view!
        containerView.addSubview(wispView)
        
        wispVC.setViewShowingInitialState(startFrame: startFrame)
        containerView.layoutIfNeeded()
        wispView.layoutIfNeeded()
        /// - Important: 반드시 setViewShowingInitialState 메서드 뒤에 호출되어야 함.
        wispView.translatesAutoresizingMaskIntoConstraints = false
        
        /// - Important: Interactivce한 트랜지션을 위해서는 UIView.animate를 사용해야 함.
        /// UIViewPropertyAnimator를 사용하면 interactive한 애니메이션이 제대로 동작하지 않음 주의.
        UIView.springAnimate(
            withDuration: transitionDuration(using: transitionContext),
            options: .allowUserInteraction,
            animations: {
                NSLayoutConstraint.activate([
                    wispView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: wispVC.presentedAreaInset.top),
                    wispView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: wispVC.presentedAreaInset.leading),
                    wispView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -wispVC.presentedAreaInset.trailing),
                    wispView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -wispVC.presentedAreaInset.bottom),
                ])
                wispVC.setViewShowingFinalState()
                containerView.layoutIfNeeded()
            },
            completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        )
        
        // interactivce한 transition이나, 사용자와 지속적으로 상호작용하면서 present하지는 않는다.
        // 단지 뷰가 자동으로 펼쳐지는데, 펼쳐지는 중간에 사용자가 이 뷰를 잡을 수 있는 것.
        // 그래서 처음에는 그냥 자동으로 애니메이션이 실행되도록 구현함.
        DispatchQueue.main.async { [weak self] in
            self?.interactor.finish()
        }
        
    }
    
}
