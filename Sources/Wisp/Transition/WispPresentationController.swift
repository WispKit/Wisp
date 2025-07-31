//
//  WispPresentationController.swift
//  NoteCard
//
//  Created by 김민성 on 7/21/25.
//

import UIKit

internal class WispPresentationController: UIPresentationController {
    
    private var willBeDismissedIfRelease: Bool = false {
        didSet {
            if willBeDismissedIfRelease != oldValue {
                feedbackGenerator.impactOccurred()
            }
        }
    }
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private let blurAnimator = UIViewPropertyAnimator(
        duration: 2,
        controlPoint1: .init(x: 0, y: 0.3),
        controlPoint2: .init(x: 0.65, y: 0.23)
    )
    let tapRecognizingBlurView = UIVisualEffectView(effect: nil)
    private let wispDismissableVC: any WispPresented
    
    private let tapGesture = UITapGestureRecognizer()
    let dragPanGesture = UIPanGestureRecognizer()
    
    init(
        presentedViewController: any WispPresented,
        presenting presentingViewController: UIViewController?
    ) {
        self.wispDismissableVC = presentedViewController
        super.init(
            presentedViewController: self.wispDismissableVC,
            presenting: presentingViewController
        )
        self.blurAnimator.pausesOnCompletion = true
        self.feedbackGenerator.prepare()
        
        dragPanGesture.delegate = self
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView else { return }
        containerView.addSubview(tapRecognizingBlurView)
        tapRecognizingBlurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tapRecognizingBlurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tapRecognizingBlurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tapRecognizingBlurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tapRecognizingBlurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        containerView.layoutIfNeeded()
        
        tapGesture.addTarget(self, action: #selector(containerBlurDidTapped))
        tapRecognizingBlurView.addGestureRecognizer(tapGesture)
        
        dragPanGesture.allowedScrollTypesMask = [.continuous]
        dragPanGesture.addTarget(self, action: #selector(dragPanGesturehandler))
        wispDismissableVC.view.addGestureRecognizer(dragPanGesture)
        
        blurAnimator.addAnimations { [weak self] in
            self?.tapRecognizingBlurView.effect = UIBlurEffect(style: .regular)
        }
        blurAnimator.startAnimation()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.blurAnimator.stopAnimation(true)
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) { }
    
    override func dismissalTransitionWillBegin() {
        blurAnimator.stopAnimation(true)
        blurAnimator.fractionComplete = 0
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) { }
    
}


private extension WispPresentationController {
    
    @objc func containerBlurDidTapped(_ sender: UITapGestureRecognizer) {
        blurAnimator.stopAnimation(true)
        tapRecognizingBlurView.effect = nil
        wispDismissableVC.dismissCard()
    }
    
    @objc func dragPanGesturehandler(_ gesture: UIPanGestureRecognizer) {
        let view = wispDismissableVC.view!
        // 직전 제스처의 위치로부터 이동 거리(매 change state 호출 시마다 위치 재정렬함.)
        let translation = gesture.translation(in: view)
        /// pan gesture의 시작점으로부터의 거리.
        let hypotenuse = sqrt(pow(translation.x, 2) + pow(translation.y,2))
        let scaleValue = 1.0 + 0.3 * (exp(-(abs(translation.x)/400.0 + translation.y/500.0)) - 1.0)
        let scale = min(1.05, max(0.7, scaleValue))
        let yPosition = translation.y < 0 ? translation.y / 3 : translation.y
        let translationTransform = CGAffineTransform(
            translationX: translation.x * pow(scale, 2) ,
            y: yPosition * pow(scale, 2)
        )
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        switch gesture.state {
        case .began:
            break
        case .changed:
            view.transform = scaleTransform.concatenating(translationTransform)
            willBeDismissedIfRelease = (hypotenuse > 230) && (translation.y > 0)
            
        default:
            let velocity = gesture.velocity(in: view)
            let velocityScalar = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
            let shouldDismiss = (hypotenuse > 230 || velocityScalar > 1000) && (translation.y > 0)
            
            if shouldDismiss {
                wispDismissableVC.dismissCard()
            } else {
                UIView.springAnimate(withDuration: 0.5, options: .allowUserInteraction) {
                    view.transform = .identity
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.layoutIfNeeded()
                }
            }
        }
    }
    
    private func findScrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        for subview in view.subviews {
            if let scroll = findScrollView(in: subview) {
                return scroll
            }
        }
        return nil
    }
    
}


extension WispPresentationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        print(#function)
        let view = wispDismissableVC.view!
        guard let scrollView = findScrollView(in: view) else { return true }
        
        let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: view) ?? .zero
        
        // 아래로 끌기 + 스크롤뷰가 최상단이면 → dismiss 허용
        
        let isPanningDown = velocity.y > abs(velocity.x)
        let isPanningUp = -velocity.y > abs(velocity.x)
        let isScrollViewTopEdge = scrollView.contentOffset.y <= 0
        let isPanningHorizontal = abs(velocity.x) > abs(velocity.y)
        
        if isPanningHorizontal {
            return true
        }
        if !isScrollViewTopEdge {
            return false
        }
        if isScrollViewTopEdge && isPanningDown {
            return true
        }
        if isScrollViewTopEdge && isPanningUp {
            return false
        }
        return false
    }
    
}
