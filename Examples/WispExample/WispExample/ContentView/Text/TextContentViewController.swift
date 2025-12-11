//
//  TextContentViewController.swift
//  WispExample
//
//  Created by kinsgmin on 12/10/25.
//

import UIKit
import SnapKit

class TextContentViewController: UIViewController {
    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
        
        textView.text = """
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris facilisis tempor consectetur. Donec eu dui vehicula risus eleifend laoreet et scelerisque leo. Fusce et quam quis turpis semper sagittis nec eu neque. Nullam imperdiet, mi facilisis lacinia pretium, lectus sapien efficitur massa, ut pretium ipsum lorem sed magna. Vivamus consequat dui non ex tincidunt aliquam. Pellentesque et hendrerit purus. Mauris accumsan quam vel egestas viverra. Maecenas pellentesque ex id orci dictum, sit amet feugiat ipsum vehicula. Cras vel mauris gravida, pharetra orci quis, interdum tellus. Pellentesque sit amet laoreet nulla. Integer ut aliquet metus, eu eleifend purus.
        
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris facilisis tempor consectetur. Donec eu dui vehicula risus eleifend laoreet et scelerisque leo. Fusce et quam quis turpis semper sagittis nec eu neque. Nullam imperdiet, mi facilisis lacinia pretium, lectus sapien efficitur massa, ut pretium ipsum lorem sed magna. Vivamus consequat dui non ex tincidunt aliquam. Pellentesque et hendrerit purus. Mauris accumsan quam vel egestas viverra. Maecenas pellentesque ex id orci dictum, sit amet feugiat ipsum vehicula. Cras vel mauris gravida, pharetra orci quis, interdum tellus. Pellentesque sit amet laoreet nulla. Integer ut aliquet metus, eu eleifend purus.
        
                Lorem ipsum dolor sit amet, consectetur adipiscing elit. Mauris facilisis tempor consectetur. Donec eu dui vehicula risus eleifend laoreet et scelerisque leo. Fusce et quam quis turpis semper sagittis nec eu neque. Nullam imperdiet, mi facilisis lacinia pretium, lectus sapien efficitur massa, ut pretium ipsum lorem sed magna. Vivamus consequat dui non ex tincidunt aliquam. Pellentesque et hendrerit purus. Mauris accumsan quam vel egestas viverra. Maecenas pellentesque ex id orci dictum, sit amet feugiat ipsum vehicula. Cras vel mauris gravida, pharetra orci quis, interdum tellus. Pellentesque sit amet laoreet nulla. Integer ut aliquet metus, eu eleifend purus.
        """
        textView.font = .preferredFont(forTextStyle: .body)
        view.addSubview(textView)
        textView.layer.cornerRadius = 10
        textView.keyboardDismissMode = .onDrag
        textView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(10)
//            $0.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(10)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
        }
    }
}
