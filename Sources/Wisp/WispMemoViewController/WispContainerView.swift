//
//  WispContainerView.swift
//  NoteCard
//
//  Created by 김민성 on 7/21/25.
//

import UIKit


final class WispContainerView: UIView {
    
    private let cardInset: NSDirectionalEdgeInsets
    private let usingSafeArea: Bool
    
    // .6,.32,.57,1
    private let cardShowingAnimator = UIViewPropertyAnimator(
        duration: 0.5,
        controlPoint1: .init(x: 0.24, y: 0.42),
        controlPoint2: .init(x: 0.0, y: 1)
    )
    
    private let cardDisappearingAnimator = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 1)
    
    let blurIntensitySetter = UIViewPropertyAnimator(duration: 0.3, curve: .linear)
//    let backgroundBlurView = CustomIntensityBlurView(blurStyle: .regular, intensity: 0.0)
    
    // transition 시 card에 띄울 blur view.
//    let cellSnapshotView = UIImageView()
    let cardBlurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    
    let card = UIView()
//    private let titleTextField = UITextField()
//    private let heartImageView = UIButton(configuration: .plain())
//    private let ellipsisButton = UIButton(configuration: .plain())
    
    private var cardTopAnchor: NSLayoutConstraint!
    private var cardLeadingAnchor: NSLayoutConstraint!
    private var cardTrailingAnchor: NSLayoutConstraint!
    private var cardBottomAnchor: NSLayoutConstraint!
    
    
//    private var makeCategorySingleLineLayout = {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.minimumLineSpacing = 10
//        flowLayout.scrollDirection = .horizontal
//        flowLayout.estimatedItemSize = CGSize(width: 50, height: 25)
//        return flowLayout
//    }
//    private lazy var categoryCollectionView = UICollectionView(
//        frame: .zero,
//        collectionViewLayout: makeCategorySingleLineLayout()
//    )
    
//    private let makeImageLayout = {
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.minimumLineSpacing = 10
//        flowLayout.sectionInset = .zero
//        flowLayout.itemSize = CGSize(width: 70, height: 70)
//        flowLayout.scrollDirection = .horizontal
//        return flowLayout
//    }
//    private lazy var imageCollectionView = UICollectionView(
//        frame: .zero,
//        collectionViewLayout: makeImageLayout()
//    )
    
    // iOS 버전에 따라 생성자를 다르게 사용하여 초기화하기 위해 초깃값 할당하지 않았음.
//    var memoTextView: UITextView!
//    let memoDateLabel = UILabel()
    
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


// MARK: - Design, Properties Settings

private extension WispContainerView {
    
    func setupDesign() {
//        backgroundBlurView.alpha = 1
//        card.backgroundColor = UIColor.memoBackground
        card.layer.cornerRadius = 37
        card.layer.cornerCurve = .continuous
        card.clipsToBounds = true
        
//        setupTitleTextField()
//        setupHeartButton()
//        setupEllipsisButton()
//        setupCategoryCollectionView()
//        setupImageCollectionView()
//        setupMemoTextView()
//        setupMemoDateLabel()
    }
    
//    func setupTitleTextField() {
//        setInputAccessoryView(to: titleTextField)
//        
//        titleTextField.font = UIFont.systemFont(ofSize: 18)
//        titleTextField.placeholder = "제목 없음".localized()
//        titleTextField.borderStyle = .none
//        titleTextField.text = ""
//        titleTextField.textAlignment = .left
//        titleTextField.backgroundColor = .clear
//        titleTextField.textColor = UIColor.label
//        titleTextField.tintColor = .currentTheme()
//        titleTextField.minimumFontSize = 16 //같은 셀의 textView의 폰트는 13.5 <- 이보다는 커야 한다.
//        titleTextField.adjustsFontSizeToFitWidth = true
//    }
    
//    func setupHeartButton() {
////        heartButton.tintColor = .systemRed
//        heartImageView.imageView?.contentMode = .scaleAspectFit
//        heartImageView.configuration?.title = ""
//        heartImageView.configuration?.baseBackgroundColor = .clear
//        heartImageView.configuration?.baseForegroundColor = .systemRed
//        heartImageView.configurationUpdateHandler = { button in
//            let systemImageName = button.isSelected ? "heart.fill" : "heart"
//            button.configuration?.image = UIImage(systemName: systemImageName)
//        }
//    }
    
//    func setupEllipsisButton() {
//        ellipsisButton.configuration?.image = UIImage(systemName: "ellipsis.circle")
//        ellipsisButton.configuration?.title = ""
//        ellipsisButton.configuration?.contentInsets = .zero
//        ellipsisButton.configuration?.imagePlacement = .all
//        ellipsisButton.configuration?.baseBackgroundColor = .clear
//        ellipsisButton.configurationUpdateHandler = { button in
//            button.tintColor = button.isHighlighted ? .lightGray : UIColor.currentTheme()
//        }
//        ellipsisButton.showsMenuAsPrimaryAction = true
//    }
    
//    func setupCategoryCollectionView() {
//        // DiffableDataSource로 변경 고려
//        categoryCollectionView.register(
//            TotalListCellCategoryCell.self,
//            forCellWithReuseIdentifier: TotalListCellCategoryCell.cellID
//        )
//        categoryCollectionView.clipsToBounds = true
//        categoryCollectionView.showsHorizontalScrollIndicator = false
//        categoryCollectionView.backgroundColor = .clear
//    }
    
//    func setupImageCollectionView() {
//        imageCollectionView.register(
//            MemoImageCollectionViewCell.self,
//            forCellWithReuseIdentifier: MemoImageCollectionViewCell.cellID
//        )
//        imageCollectionView.isScrollEnabled = true
//        imageCollectionView.showsHorizontalScrollIndicator = false
//        imageCollectionView.clipsToBounds = true
//        imageCollectionView.backgroundColor = .clear
//        imageCollectionView.layer.cornerRadius = 13
//        imageCollectionView.layer.cornerCurve = .continuous
//    }
    
//    func setupMemoTextView() {
//        if #available(iOS 16.0, *) {
//            // iOS 16.0 이후에서는 TextKit2 사용기 기본값이기 때문에,
//            // TextKit1 사용으로 통일하기 위해 usingTextLayoutManager 매개변수에 false 할당.
//            memoTextView = UITextView(usingTextLayoutManager: false)
//        } else {
//            memoTextView = UITextView()
//        }
//        
//        // inputAccessoryView 설정
//        setInputAccessoryView(to: memoTextView)
//        
//        // typingAttributes 설정
//        let mutableParagraphStyle = NSMutableParagraphStyle()
//        mutableParagraphStyle.lineSpacing = 5
//        memoTextView.typingAttributes = [.paragraphStyle: mutableParagraphStyle,
//                                         .font: UIFont.systemFont(ofSize: 15),
//                                         .foregroundColor: UIColor.label]
//        
//        memoTextView.textInputView.backgroundColor = .clear
//        memoTextView.tintColor = .currentTheme()
//        memoTextView.dataDetectorTypes = .link
//        
//        // 텍스트 제외한 모든 inset 제거
//        memoTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
//        memoTextView.textContainerInset  = .zero
//        memoTextView.textContainer.lineFragmentPadding = 0
//        
//        // 아래 코너 둥글게
//        memoTextView.clipsToBounds = true
//        memoTextView.layer.cornerRadius = 25
//        memoTextView.layer.cornerCurve = .continuous
//        memoTextView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
//    }
    
//    func setupMemoDateLabel() {
//        memoDateLabel.text = "----.--.--.에 생성됨"
//        memoDateLabel.textColor = .lightGray
//        memoDateLabel.font = .systemFont(ofSize: 14)
//    }
    
//    func setInputAccessoryView(to textReceiver: some UITextInput) {
//        let isTextField = textReceiver is UITextField
//        let isTextView = textReceiver is UITextView
//        guard isTextField || isTextView else { return }
//        
//        let toolBar = UIToolbar(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
//        let hideKeyboardButton = UIBarButtonItem(
//            image: UIImage(systemName: "keyboard.chevron.compact.down"),
//            style: .plain,
//            target: self,
//            action: #selector(keyboardHideButtonTapped)
//        )
//        let flexibleBarButton = UIBarButtonItem(systemItem: UIBarButtonItem.SystemItem.flexibleSpace)
//        toolBar.items = [flexibleBarButton, hideKeyboardButton]
//        toolBar.sizeToFit()
//        toolBar.tintColor = .currentTheme()
//        
//        if let textField = textReceiver as? UITextField {
//            textField.inputAccessoryView = toolBar
//        } else if let textView = textReceiver as? UITextView {
//            textView.inputAccessoryView = toolBar
//        }
//    }
    
//    func setupActions() {
//        
//    }
    
//    @objc private func keyboardHideButtonTapped() {
//        self.endEditing(true)
//    }
    
}


// MARK: - View Layout Setting

private extension WispContainerView {
    
    func setupViewHierarchy() {
//        addSubview(backgroundBlurView)
        addSubview(card)
//        card.addSubview(titleTextField)
//        card.addSubview(heartImageView)
//        card.addSubview(ellipsisButton)
//        card.addSubview(categoryCollectionView)
//        card.addSubview(imageCollectionView)
//        card.addSubview(memoTextView)
//        card.addSubview(memoDateLabel)
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
        
//        titleTextField.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            titleTextField.topAnchor.constraint(equalTo: card.topAnchor, constant: 15),
//            titleTextField.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 25),
//            titleTextField.heightAnchor.constraint(equalToConstant: 30),
//        ])
//        
//        heartImageView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            heartImageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
//            heartImageView.leadingAnchor.constraint(equalTo: titleTextField.trailingAnchor, constant: 10),
//            heartImageView.trailingAnchor.constraint(equalTo: ellipsisButton.leadingAnchor, constant: 0),
//            heartImageView.widthAnchor.constraint(equalToConstant: 27),
//            heartImageView.heightAnchor.constraint(equalToConstant: 27),
//        ])
//        
//        ellipsisButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            ellipsisButton.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
//            ellipsisButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
//            ellipsisButton.widthAnchor.constraint(equalToConstant: 30),
//            ellipsisButton.heightAnchor.constraint(equalToConstant: 30),
//        ])
//        
//        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            categoryCollectionView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 10),
//            categoryCollectionView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
//            categoryCollectionView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
//            categoryCollectionView.heightAnchor.constraint(equalToConstant: 25),
//        ])
//        
//        imageCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            imageCollectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 0),
//            imageCollectionView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
//            imageCollectionView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
//            imageCollectionView.heightAnchor.constraint(equalToConstant: 0),
//        ])
//        
//        memoTextView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            memoTextView.topAnchor.constraint(equalTo: imageCollectionView.bottomAnchor, constant: 10),
//            memoTextView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 10),
//            memoTextView.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -10),
//            memoTextView.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -10),
//        ])
//        
//        memoDateLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            memoDateLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -30),
//            memoDateLabel.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 10),
//        ])
    }
    
}


// MARK: - Configurint Data

extension WispContainerView {
    
//    func configure(with memo: MemoEntity) {
//        guard let orderCriterion = UserDefaults.standard.string(forKey: UserDefaultsKeys.orderCriterion.rawValue) else { fatalError() }
//        
//        if memo.isInTrash {
//            self.memoDateLabel.textColor = .systemRed
//            
//            // 삭제 날짜 계산 로직 분리 필요
//            guard let deletedDate = memo.deletedDate else { fatalError() }
//            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
//            let dateAfterDeleted = calendar.dateComponents([.day, .hour], from: deletedDate, to: Date())
//            guard let dayAfterDeleted = dateAfterDeleted.day else { fatalError() }
//            guard let hourAfterDeleted = dateAfterDeleted.hour else { fatalError() }
//            
//            if dayAfterDeleted < 13 {
//                self.memoDateLabel.text = String(format: "%d일 뒤에 삭제됨".localized(), 14 - dayAfterDeleted)
//            } else {
//                self.memoDateLabel.text = "1일 이내에 삭제됨".localized()
//            }
//            
//            self.heartImageView.isEnabled = false
//            self.heartImageView.tintColor = .lightGray
//            self.titleTextField.isEnabled = false
//            self.memoTextView.isEditable = false
//            self.memoTextView.isSelectable = false
//            
//        } else if orderCriterion == OrderCriterion.creationDate.rawValue {
//            self.memoDateLabel.text = String(format: "%@에 생성됨".localized(), memo.getCreationDateInString())
//        } else {
//            self.memoDateLabel.text = String(format: "%@에 수정됨".localized(), memo.getModificationDateString())
//        }
//        
//        self.titleTextField.text = memo.memoTitle
//        
//        let heartImageName = memo.isFavorite ? "heart.fill" : "heart"
//        heartImageView.configuration?.image = .init(systemName: heartImageName)
//        
//        self.memoTextView.setLineSpace(
//            with: memo.memoText,
//            lineSpace: 5,
//            font: UIFont.systemFont(ofSize: 15),
//            textColor: .label
//        )
//        if UserDefaults.standard.object(forKey: "themeColor") as! String == ThemeColor.black.rawValue {
//            self.memoTextView.linkTextAttributes = [
//                .foregroundColor: UIColor.systemGray,
//                .underlineStyle: NSUnderlineStyle.single.rawValue
//            ]
//        } else {
//            self.memoTextView.linkTextAttributes = [.foregroundColor: UIColor.currentTheme()]
//        }
//    }
    
//    func configureCategories(with categories: [CategoryEntity]) {
//        
//    }
//    
//    func configureImages(with images: [ImageEntity]) {
//        
//    }
    
}


// MARK: - Custom Transition Related

extension WispContainerView {
    
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
    
    func setCardDisappearingInitialState() {
        card.transform = .identity
    }
    
    func setCardDisappearingFinalState(endFrame: CGRect) {
        let cardOriginalFrame = card.frame
        
        let centerDiffX = endFrame.center.x - cardOriginalFrame.center.x
        let centerDiffY = endFrame.center.y - cardOriginalFrame.center.y
        
        let cardWidthScaleDiff = endFrame.width / cardOriginalFrame.width
        let cardHeightScaleDiff = endFrame.height / cardOriginalFrame.height
        
        let currentT = card.transform
        
        let scaleT = CGAffineTransform(scaleX: cardWidthScaleDiff, y: cardHeightScaleDiff)
        let translationT = CGAffineTransform(translationX: centerDiffX, y: centerDiffY)
        
        /// - Important: ⚠️ 순서 매우 중요!!!‼️
        /// concatenating을 통해 CGAffineTransform 들을 연산할 때 맨 마지막에 추가된 transform부터 역순으로 계산된다.
        ///
        /// 현재 상황에서 여러 transform을 엮을 때, 다음 순서를 지켜야 함.
        /// 1. `scaleT`는 `translationT` 다음에 와야 한다.
        ///     `scaleT`가 먼저 적용되면 `translationT`의 움직임은 `scaleT`의 비율만큼 적용되기 때문..
        /// 2. `currentT`는 `translationT` 다음에 와야 한다.
        ///     `currentT` 자체에 `scale`이 반영되어 있을 수가 있어서 `translationT`를 적용할 때 의도한 것과 다른 값 만큼 이동할 수 있음.
        card.transform = scaleT
            // currentTransform 안에 scale 변화가 들어가 있어서, 이게
            .concatenating(currentT)
            .concatenating(translationT)
    }
    
}
