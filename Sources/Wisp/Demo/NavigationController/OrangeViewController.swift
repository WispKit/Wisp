//
//  OrangeViewController.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit


final class OrangeViewController: UIViewController {
    
    let button = UIButton(configuration: .plain())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemOrange
        
        button.configuration?.title = "go to Blue"
        button.configuration?.image = UIImage(systemName: "chevron.right")
        
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        button.addTarget(self, action: #selector(goToBlue), for: .touchUpInside)
    }
    
    @objc private func goToBlue(_ sender: UIButton) {
        navigationController?.pushViewController(BlueViewController(), animated: true)
    }
    
}
