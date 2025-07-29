//
//  WispCardView.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


class WispCardView: UIView {
    
    private let cardInset: NSDirectionalEdgeInsets
    private let usingSafeArea: Bool
    
//    let backgroundBlurView = CustomIntensityBlurView(blurStyle: .regular, intensity: 0.0)
    
    let card = UIView()
    
    init(cardInset: NSDirectionalEdgeInsets, usingSafeArea: Bool) {
        self.cardInset = cardInset
        self.usingSafeArea = usingSafeArea
        super.init(frame: .zero)
        
        setupDesign()
        setupViewHierarchy()
        setupLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



extension WispCardView {
    
    func setupDesign() {
//        backgroundBlurView.alpha = 1
        card.backgroundColor = UIColor.systemGray4
        card.layer.cornerRadius = 37
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true
    }
    
}


// MARK: - View Layout Setting

private extension WispCardView {
    
    func setupViewHierarchy() {
//        addSubview(backgroundBlurView)
        addSubview(card)
    }
    
    func setupLayoutConstraints() {
//        backgroundBlurView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            backgroundBlurView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
//            backgroundBlurView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
//            backgroundBlurView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
//            backgroundBlurView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
//        ])
        
        card.translatesAutoresizingMaskIntoConstraints = false
        let cardEdgesConstraints: [NSLayoutConstraint]
        if usingSafeArea {
            cardEdgesConstraints = [
                card.topAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.topAnchor,
                    constant: cardInset.top
                ),
                card.leadingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.leadingAnchor,
                    constant: cardInset.leading
                ),
                card.trailingAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.trailingAnchor,
                    constant: cardInset.trailing
                ),
                card.bottomAnchor.constraint(
                    equalTo: safeAreaLayoutGuide.bottomAnchor,
                    constant: cardInset.bottom
                ),
            ]
        } else {
            cardEdgesConstraints = [
                card.topAnchor.constraint(equalTo: topAnchor, constant: cardInset.top),
                card.leadingAnchor.constraint(equalTo: leadingAnchor, constant: cardInset.leading),
                card.trailingAnchor.constraint(equalTo: trailingAnchor, constant: cardInset.trailing),
                card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: cardInset.bottom),
            ]
        }
        NSLayoutConstraint.activate(cardEdgesConstraints)
    }
    
}


extension WispCardView {
    
    func setCardShowingInitialState(startFrame: CGRect) {
        let cardFinalFrame = card.frame
        
        let centerDiffX = startFrame.center.x - cardFinalFrame.center.x
        let centerDiffY = startFrame.center.y - cardFinalFrame.center.y
        
        let cardWidthScaleDiff = startFrame.width / cardFinalFrame.width
        let cardHeightScaleDiff = startFrame.height / cardFinalFrame.height
        
        let scaleTransform = CGAffineTransform(scaleX: cardWidthScaleDiff, y: cardHeightScaleDiff)
        let centerTransform = CGAffineTransform(translationX: centerDiffX, y: centerDiffY)
        let cardTransform = scaleTransform.concatenating(centerTransform)
        card.transform = cardTransform
    }
    
    func setCardShowingFinalState() {
        card.transform = .identity
    }
    
}
