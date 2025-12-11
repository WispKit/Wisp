//
//  MovieContentViewController.swift
//  Wisp
//
//  Created by 김민성 on 12/10/25.
//

import UIKit

import Wisp

final class MovieContentViewController: UIViewController {
    
    let rootView = MovieContentView()
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rootView.collectionView.register(
            MovieContentViewHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MovieContentViewHeader.reuseIdentifier
        )
        rootView.collectionView.register(HomeViewCell.self, forCellWithReuseIdentifier: HomeViewCell.reuseIdentifier)
        rootView.collectionView.dataSource = self
        rootView.collectionView.delegate = self
        
        rootView.dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print(#function)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(#function)
    }
    
    deinit {
        print("NFLXContentVC deinit")
    }
    
}


private extension MovieContentViewController {
    
    @objc func dismissButtonTapped() {
        self.wisp.dismiss()
    }
    
}


// MARK: - UICollectionViewDataSource
extension MovieContentViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MovieContentViewHeader.reuseIdentifier,
            for: indexPath
        ) as? MovieContentViewHeader else { fatalError("header dequeuing failed") }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeViewCell.reuseIdentifier,
            for: indexPath
        ) as? HomeViewCell else { fatalError("cell dequeuing failed.") }
        return cell
    }
    
}


extension MovieContentViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.pushViewController(MovieContentViewController(), animated: true)
    }
    
}


extension MovieContentViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let dummyHeader = MovieContentViewHeader()
        guard let windowSize = view.window?.bounds else { return .zero }
        return dummyHeader.systemLayoutSizeFitting(
            .init(width: windowSize.width, height: 1000),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .defaultLow
        )
    }
    
}

