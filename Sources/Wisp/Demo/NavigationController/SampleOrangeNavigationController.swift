//
//  SampleOrangeNavigationController.swift
//  NoteCard
//
//  Created by 김민성 on 7/28/25.
//

import UIKit

public class SampleOrangeNavigationController: UINavigationController, WispDismissable {
    
    public var viewInset: NSDirectionalEdgeInsets
    
    public init(viewInset: NSDirectionalEdgeInsets) {
        self.viewInset = viewInset
        super.init(rootViewController: OrangeViewController())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
