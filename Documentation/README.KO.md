# Wisp ✨

### `UICollectionView`에서 사용할 수 있는 카드 형식의 커스텀 트랜지션을 지원하는 라이브러리입니다.
### 부드러운 애니메이션과 직관적인 인터페이스를 제공합니다.

---

## ✨ 주요 기능

- 📱 **부드럽고 자연스러운 애니메이션**으로 셀이 전체 화면으로 전환
- 🔙 **드래그하여 닫기**: 화면을 아래로 드래그하면 원래 셀로 돌아감
- 🎯 **직관적인 UX** — 인스타그램, 넷플릭스 등에서 사용하는 카드 형식 전환을 참고하여 구현
- 🧱 **`Compositional Layout`** 기반의 컬렉션 뷰에서 사용 가능
- ⚙️ 간단한 설정으로 동작하며, `WispConfiguration`을 통해 커스터마이징 가능
---

## 📸 동작 이미지

| 직관적인 Dismiss 인터페이스 | 배경을 탭하여 Dismiss 가능 |
|:--:|:--:|
|<img src="https://github.com/user-attachments/assets/de41bad1-a288-455f-85c8-6c2d18dacbe1" width=200> |  <img src="https://github.com/user-attachments/assets/23140aed-2abd-4cb4-a29e-23d4893e1e0e" width=200>|

---

# ⬇️ 설치

Wisp는 [Swift Package Manager](https://swift.org/package-manager/)를 통해 설치할 수 있습니다:

1. Xcode project 열기.
2. **File > Add Package Dependencies...** 로 이동
3. package URL 입력: `https://github.com/nolanMinsung/Wisp.git`
4. 버전 선택 후 `Target`에 추가


## 🚀 어떻게 사용하나요?

### 아주 간단합니다! 단 몇 줄의 코드면 충분합니다.
#### 1.	UICollectionView 대신 `WispableCollectionView` 를 사용합니다. 
#### 2.	그리고 나서 UIViewController에서 필요한 코드는 단 한 줄입니다.

WispableCollectionView는 다음과 같이 compositional layout의 section 정보를 사용하여 초기화합니다.
``` swift
import Wisp

// ...
let myCollectionView = WispableCollectionView(
    frame: .zero,
    sectionProvider: { sectionIndex, layoutEnvironment in
        // your compositional layout section Info here
    }
)
// ...
```
하나의 섹션만을 사용하여 초기화하는 경우에는 다음과 같이 사용할 수 있습니다:
``` swift
// ...
let myCollectionView = WispableCollectionView(
    frame: .zero,
    section: {
        // your compositional layout section
    }
)
// ...
```

그리고 나서 전환을 실행할 뷰컨트롤러에서, 다음과 같이 한 줄만 적으면 됩니다:

``` swift
let secondVC = MyViewController()
wisp.present(secondVC, collectionView: myCollectionView, at: indexPath)
// ⚠️ Note: The collection view는 present되는 view controller의 subview여야 합니다.
```
### ✅ 이게 전부입니다! 복잡한 delegate나, 커스텀 트랜지션 설정은 필요하지 않습니다. 말 그대로, 그냥 동작해요.

## ⚙️ Configuration

만약 애니메이션 속도, 펼쳐질 카드의 크기나 corner radius 등을 변경하고 싶다면 
`WispConfiguration`을 통해 커스텀 설정을 할 수 있습니다.
## WispConfiguration (v1.3.0)

버전 **1.3.0**부터 `WispConfiguration`이 **DSL 기반 구성 방식**으로 리팩터링되었습니다.  
이로 인해 코드 가독성, 유지보수성, 확장성이 개선되었습니다.

> 자세한 내용은 [WispConfiguration DSL 가이드](./WispConfiguration.md)를 참고하세요.

### 간단 예제

``` swift
let configuration = WispConfiguration { config in
    // Animation configuration
    config.setAnimation { animation in
        animation.speed = .fast
    }
    
    // Gesture configuration
    config.setGesture { gesture in
        gesture.allowedDirections = [.right, .down]
    }
    
    // Layout configuration
    config.setLayout { layout in
        layout.presentedAreaInset = inset
        layout.initialCornerRadius = 15
        layout.finalCornerRadius = 30
    }
}
```
각 속성은 기본값을 가지고 있으므로, 원하는 항목만 설정하시면 됩니다.

예를 들어, `presentedAreaInset` 값을 사용하면 다음과 같이 카드가 펼쳐질 영역을 커스텀할 수 있습니다.

| fullscreen | formSheet style | card | small pop up |
|:--:|:--:|:--:|:--:|
| <img src="https://github.com/user-attachments/assets/dcbbc640-c7a1-439f-ba62-9c73e09b8c9b" width=130> | <img src="https://github.com/user-attachments/assets/0564c85f-9a09-4d3c-91be-8aaa83c29035" width=130> | <img src="https://github.com/user-attachments/assets/6d55a707-df20-46da-9211-3183461d7f85" width=130>  |  <img src="https://github.com/user-attachments/assets/ea68d539-889a-4017-b1ed-a6e29ec5d3df" width=130> |


## 📌 최소 요구 사항
- iOS 15.0+
- swift 컴파일러 5.9+
- UIKit
- Compositional Layout


## 📄 License

MIT License. See [LICENSE](https://github.com/nolanMinsung/Wisp?tab=MIT-1-ov-file#readme) for more information.
