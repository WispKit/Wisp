//
//  WispPresentationController.swift
//  NoteCard
//
//  Created by 김민성 on 7/21/25.
//

import UIKit

internal class WispPresentationController: UIPresentationController {
    
    private let tapRecognizingView = UIView()
    private let wispDismissableVC: any WispDismissable
    
    private let tapGesture = UITapGestureRecognizer()
    private let dragPanGesture = UIPanGestureRecognizer()
    
    init(
        presentedViewController: any WispDismissable,
        presenting presentingViewController: UIViewController?
    ) {
        self.wispDismissableVC = presentedViewController
        super.init(
            presentedViewController: self.wispDismissableVC,
            presenting: presentingViewController
        )
    }
    
    deinit {
        print("presentation controller deinit")
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
        
        tapGesture.addTarget(self, action: #selector(containerBlurDidTapped))
        tapRecognizingView.addGestureRecognizer(tapGesture)
        
        dragPanGesture.allowedScrollTypesMask = [.continuous]
        dragPanGesture.addTarget(self, action: #selector(dragPanGesturehandler))
        wispDismissableVC.view.addGestureRecognizer(dragPanGesture)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) { }
    
    override func dismissalTransitionWillBegin() { }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        print(#function)
    }
    
}


private extension WispPresentationController {
    
    @objc func containerBlurDidTapped(_ sender: UITapGestureRecognizer) {
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
        let translationTransform = CGAffineTransform(translationX: translation.x, y: yPosition)
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        switch gesture.state {
        case .began:
            break
        case .changed:
            view.transform = scaleTransform.concatenating(translationTransform)
        default:
            let velocity = gesture.velocity(in: view)
            let velocityScalar = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
            let shouldDismiss = (hypotenuse > 130 || velocityScalar > 1000) && (translation.y > 0)
            
            if shouldDismiss {
                (presentedViewController as! WispDismissable).dismissCard()
            } else {
                UIView.springAnimate(withDuration: 0.5, options: .allowUserInteraction) {
                    view.transform = .identity
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.layoutIfNeeded()
                }
            }
        }
    }
    
}
