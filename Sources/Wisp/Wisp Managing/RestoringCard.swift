//
//  RestoringCard.swift
//  NoteCard
//
//  Created by 김민성 on 7/22/25.
//

import UIKit


final class RestoringCard: UIView {
    
    var cellSnapshot: UIView? = nil
    let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    var viewSnapshot: UIView? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        isUserInteractionEnabled = false
        addSubview(blurView)
        setupDefaultLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDefaultLayoutConstraints() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
    }
    
}

extension RestoringCard {
    
    func setupSnapshots(viewSnapshot: UIView?, cellSnapshot: UIView?) {
        if let viewSnapshot {
            addViewSnapshot(viewSnapshot)
        }
        
        if let cellSnapshot {
            addCellSnapshot(cellSnapshot)
        }
        
        layoutSnapshots()
    }
    
    func addCellSnapshot(_ snapshot: UIView) {
        cellSnapshot = snapshot
        addSubview(cellSnapshot!)
        sendSubviewToBack(cellSnapshot!)
    }
    
    
    func addViewSnapshot(_ snapshot: UIView) {
        viewSnapshot = snapshot
        addSubview(viewSnapshot!)
    }
    
    
    func layoutSnapshots() {
        cellSnapshot?.translatesAutoresizingMaskIntoConstraints = false
        if let cellSnapshot {
            NSLayoutConstraint.activate([
                cellSnapshot.topAnchor.constraint(equalTo: topAnchor),
                cellSnapshot.leadingAnchor.constraint(equalTo: leadingAnchor),
                cellSnapshot.trailingAnchor.constraint(equalTo: trailingAnchor),
                cellSnapshot.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        
        viewSnapshot?.translatesAutoresizingMaskIntoConstraints = false
        if let viewSnapshot {
            NSLayoutConstraint.activate([
                viewSnapshot.topAnchor.constraint(equalTo: topAnchor),
                viewSnapshot.leadingAnchor.constraint(equalTo: leadingAnchor),
                viewSnapshot.trailingAnchor.constraint(equalTo: trailingAnchor),
                viewSnapshot.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
        }
        layoutIfNeeded()
    }
    
    func switchSnapshots() {
        cellSnapshot?.alpha = 1
        blurView.effect = nil
        viewSnapshot?.alpha = 0
    }
    
    func setStateAfterRestore() {
        cellSnapshot?.removeFromSuperview()
        cellSnapshot = nil
        blurView.effect = nil
        viewSnapshot?.removeFromSuperview()
        viewSnapshot = nil
        isHidden = true
    }
    
}
