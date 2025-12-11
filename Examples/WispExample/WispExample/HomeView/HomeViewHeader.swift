//
//  HomeViewHeader.swift
//  WispExample
//
//  Created by 김민성 on 12/10/25.
//

import UIKit
import SnapKit

final class HomeViewHeader: UICollectionReusableView {

    static let reuseIdentifier = String(describing: HomeViewHeader.self)

    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.font = .boldSystemFont(ofSize: 22)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        label.text = title
    }
}

