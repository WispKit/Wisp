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
        dragPanGesture.maximumNumberOfTouches = 1
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


// MARK: - Gesture Recognizer Handling
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
            let shouldDismiss = (hypotenuse > 230.0 || velocityScalar > (2300.0-hypotenuse*1.5)) && (translation.y > 0.0)
            
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
    
    /// find every subview as scroll view recursively and returns all found scroll views.
    private func findSubScrollViews(in view: UIView) -> Set<UIScrollView> {
        var subScrollViews: Set<UIScrollView> = []
        
        if let scrollView = view as? UIScrollView {
            subScrollViews.insert(scrollView)
        }
        for subview in view.subviews {
            subScrollViews.formUnion(findSubScrollViews(in: subview))
        }
        return subScrollViews
    }
    
}


// MARK: - UIGestureRecognizerDelegate
extension WispPresentationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let view = wispDismissableVC.view!
        let gesturePoint = gestureRecognizer.location(in: view)
        
        let subScrollViews: Set<UIScrollView> = findSubScrollViews(in: view)
        let filteredSubScrollView = subScrollViews.filter { scrollView in
            let scrollViewConvertedFrame = view.convert(scrollView.frame, to: view)
            return scrollViewConvertedFrame.contains(consume gesturePoint)
        }
        let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: view) ?? .zero
        
        /// In the following cases, the `wisp`'s `pan gesture` is recognized:
        /// - There is no `UIScrollView` among the `subviews`.
        /// - All `UIScrollView`s containing the gesture location among the `subviews` are located at the edge opposite to the gesture's direction.
        for subScrollView in filteredSubScrollView {
            if shouldAllowPanGestureAtScrollEdge(of: velocity, with: subScrollView) {
                continue
            } else {
                return false
            }
        }
        return true
    }
    
    /// Determines whether Wisp's gesture can take over from the scroll view's pan gesture
    /// when the scroll view has reached its content boundary.
    /// - Parameters:
    ///   - velocity: The gesture's velocity, used to determine the direction of the pan.
    ///   - scrollView: The scroll view that is recognizing the pan gesture alongside Wisp.
    /// - Returns: Returns `true` if Wisp's pan gesture should be recognized instead of the scroll view's.
    private func shouldAllowPanGestureAtScrollEdge(of velocity: CGPoint, with scrollView: UIScrollView) -> Bool {
        let isPannigToTop = velocity.y < -abs(velocity.x)
        let isPanningToLeft = velocity.x < -abs(velocity.y)
        let isPanningToRight = velocity.x > abs(velocity.y)
        let isPannigToBottom = velocity.y > abs(velocity.x)
        
        let contentSize = scrollView.contentSize
        /// whether scroll view's vertical size exceeds its bounds.
        let contentVerticalScrollable = contentSize.height >= scrollView.bounds.center.y
        /// whether scroll view's horizontal size exceeds its bounds.
        let contentHorizontalScrollable = contentSize.width >= scrollView.bounds.center.x
        
        /// whether the scroll view's content size exceeds its bounds. (not related to `isScrollEnabled` property.)
        let isContentScrollable = contentVerticalScrollable || contentHorizontalScrollable
        
        guard isContentScrollable else {
            return true
        }
        
        // where scroll view is at the edge of specific direction
        let isAtTopEdge = scrollView.contentOffset.y <= -scrollView.contentInset.top
        let isAtLeftEdge = scrollView.contentOffset.x <= -scrollView.contentInset.left
        let isAtRightEdge = scrollView.contentOffset.x >= (contentSize.width-scrollView.bounds.width) + scrollView.contentInset.right
        let isAtBottomEdge = scrollView.contentOffset.y >= (contentSize.height-scrollView.bounds.height) + scrollView.contentInset.bottom
        
        if (isAtTopEdge && isPannigToBottom) ||
            (isAtLeftEdge && isPanningToRight) ||
            (isAtRightEdge && isPanningToLeft) ||
            (isAtBottomEdge && isPannigToTop)
        {
            scrollView.panGestureRecognizer.require(toFail: self.dragPanGesture)
            return true
        } else {
            return false
        }
    }
    
    
}
