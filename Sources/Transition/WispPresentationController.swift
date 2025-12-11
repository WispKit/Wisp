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
    
    private let sourceViewController: UIViewController
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private let cardContainerView: UIView
    
    private let tapGesture = UITapGestureRecognizer()
    private let tapRecognizingView = UIView()
    
    let dragPanGesture = UIPanGestureRecognizer()
    
    init(
        presentedViewController: UIViewController,
        presenting presentingViewController: UIViewController?,
        source: UIViewController,
        cardContainerView: UIView
    ) {
        self.sourceViewController = source
        self.cardContainerView = cardContainerView
        super.init(
            presentedViewController: presentedViewController,
            presenting: presentingViewController
        )
        self.feedbackGenerator.prepare()
        
        dragPanGesture.delegate = self
    }
    
    override func presentationTransitionWillBegin() {
        guard let containerView else { return }
        containerView.addSubview(tapRecognizingView)
        tapRecognizingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tapRecognizingView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tapRecognizingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tapRecognizingView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tapRecognizingView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        containerView.layoutIfNeeded()
        
        tapGesture.addTarget(self, action: #selector(containerViewDidTapped))
        tapRecognizingView.addGestureRecognizer(tapGesture)
        
        dragPanGesture.allowedScrollTypesMask = [.continuous]
        dragPanGesture.addTarget(self, action: #selector(dragPanGesturehandler))
        dragPanGesture.maximumNumberOfTouches = 1
        cardContainerView.addGestureRecognizer(dragPanGesture)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) { }
    
    override func dismissalTransitionWillBegin() { }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) { }
    
}


// MARK: - Gesture Recognizer Handling
private extension WispPresentationController {
    
    @objc func containerViewDidTapped(_ sender: UITapGestureRecognizer) {
        let noAdditionalVCPresented = presentedViewController.presentedViewController == nil
        let alreadyPresenting = presentedViewController.wisp.state != .presenting
        guard (noAdditionalVCPresented && alreadyPresenting) else {
            return
        }
        let wispPresenter = sourceViewController.wisp
        guard let context = wispPresenter.context else {
            return
        }
        guard context.configuration.gesture.dismissByTap else {
            return
        }
        sourceViewController.wisp.dismissPresentedVC()
    }
    
    @objc func dragPanGesturehandler(_ gesture: UIPanGestureRecognizer) {
        let view = cardContainerView
        // 직전 제스처의 위치로부터 이동 거리(매 change state 호출 시마다 위치 재정렬함.)
        let translation = gesture.translation(in: view)
        /// pan gesture의 시작점으로부터의 거리.
        let hypotenuse = sqrt(pow(translation.x, 2) + pow(translation.y,2))
        let hypotenuseThreshold: CGFloat = 160.0
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
            willBeDismissedIfRelease = (hypotenuse > hypotenuseThreshold) && (translation.y > 0)
            
        default:
            let velocity = gesture.velocity(in: view)
            let velocityScalar = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
            let shouldDismiss = (
                (hypotenuse > hypotenuseThreshold || velocityScalar > (1500.0-hypotenuse*1.5)) &&
                (translation.y > 0.0)
            )
            let noAdditionalVCPresented = presentedViewController.presentedViewController == nil
            let alreadyPresenting = presentedViewController.wisp.state != .presenting
            if (shouldDismiss && noAdditionalVCPresented && alreadyPresenting) {
                sourceViewController.wisp.dismissPresentedVC(withVelocity: velocity)
            } else {
                UIView.springAnimate(withDuration: 0.5, options: .allowUserInteraction) {
                    view.transform = .identity
                    view.layoutIfNeeded()
                }
            }
        }
    }
    
}


// MARK: - Finding Subviews in Specific Condition.
extension WispPresentationController {
    
    /// Recursively finds and returns all subviews of the given view that are of the specified type.
    private func findSubviews<T: UIView>(in view: UIView) -> Set<T> {
        var subViews: Set<T> = []
        
        if let viewInType = view as? T {
            subViews.insert(viewInType)
        }
        for subview in view.subviews {
            subViews.formUnion(findSubviews(in: subview))
        }
        return subViews
    }
    
    /// If one of a view's subviews is `First Responder`, return the `First Responder`. Otherwise, return `nil`.
    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }
        for subview in view.subviews {
            if let firstResponder = findFirstResponder(in: subview) {
                return firstResponder
            }
        }
        return nil
    }
    
}


// MARK: - UIGestureRecognizerDelegate
extension WispPresentationController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view else { return false }
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
        let velocity = panGesture.velocity(in: view)
        
        let wispPresenter = sourceViewController.wisp
        guard let allowedDirections = wispPresenter.context?.configuration.gesture.allowedDirections else { return false }
        guard allowedDirections.contains(velocity.gestureDirections) else { return false }
        
        let gesturePoint = gestureRecognizer.location(in: view)
        
        /// blocks `wisp`'s `pan gesture` when tried to pan `first responder`.
        if let firstResponder = findFirstResponder(in: view),
           firstResponder.isDescendant(of: view),
           let superview = firstResponder.superview {
            let firstResponderConvertedFrame = superview.convert(firstResponder.frame, to: view)

            if firstResponderConvertedFrame.contains(gesturePoint) {
                // If the first responder is a non-editable UITextView, allow the gesture.
                if let textView = firstResponder as? UITextView, !textView.isEditable {
                    return true
                }
                return false
            }
        }
        
        /// blocks `wisp`'s `pan gesture` when tried to pan 'scrollable view components'.
        let subviews: Set<UIView> = findSubviews(in: view)
        let scrollableSubComponents = subviews.filter { $0 is (any ScrollableComponent) }
        for control in scrollableSubComponents {
            if control.isDescendant(of: view){
                let controlConvertedFrame = control.superview?.convert(control.frame, to: cardContainerView) ?? .zero
                if controlConvertedFrame.contains(gesturePoint) {
                    return false
                }
            }
        }
        
        let subScrollViews: Set<UIScrollView> = findSubviews(in: view)
        let filteredSubScrollView = subScrollViews.filter { scrollView in
            guard scrollView.isDescendant(of: view) else { return false }
            let scrollViewConvertedFrame = view.convert(scrollView.frame, to: view)
            return scrollViewConvertedFrame.contains(gesturePoint)
        }
        
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
        let contentSize = scrollView.contentSize
        /// whether scroll view's vertical size exceeds its bounds.
        let contentVerticalScrollable = scrollView.bounds.height <
        contentSize.height + (scrollView.adjustedContentInset.top + scrollView.adjustedContentInset.bottom)
        
        /// whether scroll view's horizontal size exceeds its bounds.
        let contentHorizontalScrollable = scrollView.bounds.width <
        contentSize.width + (scrollView.adjustedContentInset.left + scrollView.adjustedContentInset.right)
        
        /// whether the scroll view's content size exceeds its bounds. (not related to `isScrollEnabled` property.)
        let isContentScrollable = contentVerticalScrollable || contentHorizontalScrollable
        
        guard isContentScrollable else {
            scrollView.panGestureRecognizer.state = .ended
            return true
        }
        
        // where scroll view is at the edge of specific direction
        let isAtTopEdge = scrollView.contentOffset.y <= -scrollView.contentInset.top
        let isAtLeftEdge = scrollView.contentOffset.x <= -scrollView.contentInset.left
        let isAtRightEdge = scrollView.contentOffset.x >= (contentSize.width-scrollView.bounds.width) + scrollView.contentInset.right
        let isAtBottomEdge = scrollView.contentOffset.y >= (contentSize.height-scrollView.bounds.height) + scrollView.contentInset.bottom
        
        if (isAtTopEdge && velocity.gestureDirections == .down) ||
            (isAtLeftEdge && velocity.gestureDirections == .right) ||
            (isAtRightEdge && velocity.gestureDirections == .left) ||
            (isAtBottomEdge && velocity.gestureDirections == .up)
        {
            scrollView.panGestureRecognizer.state = .ended
            return true
        } else {
            return false
        }
    }
    
    
}
