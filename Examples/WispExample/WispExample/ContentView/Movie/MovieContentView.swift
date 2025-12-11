//
//  MovieContentView.swift
//  WispExample
//
//  Created by 김민성 on 12/10/25.
//

import UIKit
import SnapKit

import UIKit
import SnapKit

final class MovieContentView: UIView {
    
    private let videoView = UIView()
    let dismissButton = UIButton()
    private(set) var collectionView: UICollectionView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.333),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 6, bottom: 0, trailing: 6)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.45))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize,
                                                       subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(300)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = .always
        
        videoView.backgroundColor = .systemGray
        videoView.isUserInteractionEnabled = false
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.setTitle("", for: .normal)
        dismissButton.backgroundColor = .systemBackground
        dismissButton.tintColor = .label
        dismissButton.setTitleColor(.label, for: .normal)
        dismissButton.layer.cornerRadius = 13
        dismissButton.clipsToBounds = true
        
        addSubview(videoView)
        addSubview(collectionView)
        addSubview(dismissButton)
        
        videoView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(videoView.snp.width).multipliedBy(0.56)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(videoView.snp.bottom)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        dismissButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(videoView).inset(10)
            make.size.equalTo(26)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
