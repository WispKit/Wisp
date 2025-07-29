//
//  WispViewController.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

public class WispViewController: UIViewController, WispPresented {
    
    public var presentedAreaInset: NSDirectionalEdgeInsets// = .init(top: 130, leading: 10, bottom: 130, trailing: 10)
    
    let imageView = UIImageView(image: .init(systemName: ["swift", "apple.logo"].randomElement()!))
    
    public init(viewInset: NSDirectionalEdgeInsets) {
        self.presentedAreaInset = viewInset
        super.init(nibName: nil, bundle: nil)
        
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray4
    }
    
}
