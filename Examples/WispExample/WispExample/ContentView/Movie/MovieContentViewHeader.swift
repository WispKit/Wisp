//
//  MovieContentViewHeader.swift
//  WispExample
//
//  Created by 김민성 on 12/10/25.
//

import Foundation
import UIKit
import SnapKit

final class MovieContentViewHeader: UICollectionReusableView {
    
    static let reuseIdentifier = "NFLXContentViewHeader"
    
    let titleLabel = UILabel()
    let additionalInfoLabel = UILabel()
    let playButton = UIButton()
    let saveButton = UIButton()
    
    let synopsisLabel = UILabel()
    let castListLabel = UILabel()
    
    let actionButton1 = UIButton()
    let actionButton2 = UIButton()
    let actionButton3 = UIButton()
    let segmentedControl = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupViewHierarchy()
        setupLayoutConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Initial Settings
private extension MovieContentViewHeader {
    
    func setupUI() {
        backgroundColor = .systemBackground
        
        titleLabel.text = "What is your Favorite Movie?"
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 18)
        
        additionalInfoLabel.textColor = .label
        additionalInfoLabel.text = "2h 27m"
        additionalInfoLabel.font = .systemFont(ofSize: 13)
        
        playButton.backgroundColor = .label
        playButton.setTitle("Play", for: .normal)
        playButton.setTitleColor(.systemBackground, for: .normal)
        playButton.layer.cornerRadius = 5
        
        saveButton.backgroundColor = .darkGray
        saveButton.setTitle("Download", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 5
        
        synopsisLabel.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris facilisis tempor consectetur. Donec eu dui vehicula risus eleifend laoreet et scelerisque leo. Fusce et quam quis turpis semper sagittis nec eu neque."
        synopsisLabel.textColor = .label
        synopsisLabel.numberOfLines = 3
        synopsisLabel.font = .systemFont(ofSize: 14)
        
        castListLabel.textColor = .systemGray2
        castListLabel.text = "Cast: Minsung Kim, Wisp, Swift...more"
        castListLabel.font = .systemFont(ofSize: 12)
        castListLabel.numberOfLines = 2
    }
    
    func setupViewHierarchy() {
        addSubview(titleLabel)
        addSubview(additionalInfoLabel)
        addSubview(playButton)
        addSubview(saveButton)
        addSubview(synopsisLabel)
        addSubview(castListLabel)
    }
    
    func setupLayoutConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(5)
        }
        additionalInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(5)
            make.height.equalTo(30)
        }
        playButton.snp.makeConstraints { make in
            make.top.equalTo(additionalInfoLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(5)
            make.height.equalTo(40)
        }
        saveButton.snp.makeConstraints { make in
            make.top.equalTo(playButton.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(5)
            make.height.equalTo(40)
        }
        synopsisLabel.snp.makeConstraints { make in
            make.top.equalTo(saveButton.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(5)
        }
        castListLabel.snp.makeConstraints { make in
            make.top.equalTo(synopsisLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(5)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
}
