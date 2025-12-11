//
//  HomeViewController.swift
//  WispExample
//
//  Created by 김민성 on 12/10/25.
//

import UIKit

import SnapKit
import Wisp

class HomeViewController: UIViewController {

    private var sections: [HomeViewSection] = []

    private lazy var wispCollectionView: WispableCollectionView = {
        let collectionView = WispableCollectionView(
            frame: .zero,
            collectionViewLayout: .wisp.make { [weak self] sectionIndex, _ in
                return self?.sections[sectionIndex].layout
            }
        )
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(wispCollectionView)

        wispCollectionView.register(
            HomeViewCell.self,
            forCellWithReuseIdentifier: HomeViewCell.reuseIdentifier
        )
        wispCollectionView.register(
            HomeViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeViewHeader.reuseIdentifier
        )
        wispCollectionView.snp.makeConstraints { $0.edges.equalToSuperview() }

        wispCollectionView.dataSource = self
        wispCollectionView.delegate = self

        wisp.delegate = self
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        self.sections = HomeViewSection.allSections(view: self.view)
    }

}


// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeViewHeader.reuseIdentifier,
            for: indexPath
        ) as! HomeViewHeader
        header.setTitle(sections[indexPath.section].title)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeViewCell.reuseIdentifier,
            for: indexPath
        ) as? HomeViewCell else {
            fatalError()
        }
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]
        cell.label.text = item.vcTypeName
        return cell
    }

}


// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        let item = section.items[indexPath.item]
        let viewControllerToPresent = item.vcType.init()

        let configuration = section.configuration

        let naviCon = UINavigationController(rootViewController: viewControllerToPresent)
        naviCon.isNavigationBarHidden = false

        wisp.present(
            naviCon,
            collectionView: wispCollectionView,
            at: indexPath,
            configuration: configuration
        )
    }
}


extension HomeViewController: WispPresenterDelegate {
    func wispDidRestore() {
        print(#function)
        return
    }
}
