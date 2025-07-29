//
//  WispCardViewController.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

// MARK: - Deprecated

class WispCardViewController: UIViewController {
    
    let rootView: WispCardView
    private let tapGesture = UITapGestureRecognizer()
    private let dragPanGesture = UIPanGestureRecognizer()
    
    init(
        cardInset: NSDirectionalEdgeInsets,
        usingSafeArea: Bool = false
    ) {
        self.rootView = WispCardView(cardInset: cardInset, usingSafeArea: usingSafeArea)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupGestures()
    }
    
}

extension WispCardViewController {
    
    private func setupGestures() {
        tapGesture.addTarget(self, action: #selector(backgroundBlurTapped))
        dragPanGesture.addTarget(self, action: #selector(dragPanGesturehandler))
        dragPanGesture.allowedScrollTypesMask = [.continuous]
        
        rootView.card.addGestureRecognizer(dragPanGesture)
    }
    
    @objc private func backgroundBlurTapped(_ sender: UITapGestureRecognizer) {
        dismissCard()
    }
    
    @objc private func dragPanGesturehandler(_ gesture: UIPanGestureRecognizer) {
        // 직전 제스처의 위치로부터 이동 거리(매 change state 호출 시마다 위치 재정렬함.)
        let translation = gesture.translation(in: view)
        /// pan gesture의 시작점으로부터의 거리.
        let hypotenuse = sqrt(pow(translation.x, 2) + pow(translation.y,2))
        let scaleValue = 1.0 + 0.3 * (exp(-(abs(translation.x)/400.0 + translation.y/100.0)) - 1.0)
        let scale = min(1.05, max(0.7, scaleValue))
        
        let yPosition = translation.y < 0 ? translation.y / 3 : translation.y
        let translationTransform = CGAffineTransform(translationX: translation.x, y: yPosition)
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        switch gesture.state {
        case .began:
            break
        case .changed:
            rootView.card.transform = scaleTransform.concatenating(translationTransform)
        default:
            let velocity = gesture.velocity(in: view)
            let velocityScalar = sqrt(pow(velocity.x, 2) + pow(velocity.y, 2))
            let shouldDismiss = (hypotenuse > 130 || velocityScalar > 1000) && (translation.y > 0)
            
            if shouldDismiss {
                dismissCard()
            } else {
                UIView.springAnimate(withDuration: 0.5, options: .allowUserInteraction) { [weak self] in
                    guard let self else { return }
                    self.rootView.card.transform = .identity
                    self.rootView.card.translatesAutoresizingMaskIntoConstraints = false
                    self.rootView.layoutIfNeeded()
                }
            }
        }
    }
    
    private func dismissCard() {
        dragPanGesture.state = .cancelled
        
        WispManager.shared.handleInteractiveDismissEnded(startFrame: rootView.card.frame)
        dismiss(animated: false)
        rootView.card.alpha = 0
        rootView.isHidden = true
    }
    
}



// 키보드 esc 키 입력 감지
extension WispCardViewController {
    
    /*
     https://developer.apple.com/documentation/UIKit/handling-key-presses-made-on-a-physical-keyboard#Detect-a-key-press
     */
    // Handle someone pressing a key on a physical keyboard.
    override func pressesBegan(_ presses: Set<UIPress>,
                               with event: UIPressesEvent?) {
        
        var didHandleEvent = false
        
        for press in presses {
            
            // Get the pressed key.
            guard let key = press.key else { continue }
            
            if key.charactersIgnoringModifiers == UIKeyCommand.inputEscape {
                // Someone pressed the escape key.
                // Respond to the key-press event.
                didHandleEvent = true
                dismissCard()
            }
        }
        
        if didHandleEvent == false {
            // If someone presses a key that you're not handling,
            // pass the event to the next responder.
            super.pressesBegan(presses, with: event)
        }
    }
    
}
