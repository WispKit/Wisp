//
//  HomeViewCell.swift
//  WispExample
//
//  Created by kinsgmin on 12/10/25.
//

import UIKit
import SnapKit

final class HomeViewCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: HomeViewCell.self)
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray5
        layer.cornerRadius = 10
        clipsToBounds = true
        
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
