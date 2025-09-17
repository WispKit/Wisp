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
|<img src="https://github.com/user-attachments/assets/22d76600-628c-4f38-964b-68192578e99e" width=200> |  <img src="https://github.com/user-attachments/assets/9d2241fa-ebe9-4823-95cc-2701b56ee47f" width=200>|
---

## ⬇️ 설치

Wisp는 [Swift Package Manager](https://swift.org/package-manager/)를 통해 설치할 수 있습니다:

1. Xcode project 열기.
2. **File > Add Package Dependencies...** 로 이동
3. package URL 입력: `https://github.com/WispKit/Wisp.git`
4. 버전 선택 후 `Target`에 추가


## 🚀 사용 방법

### 1. WispableCollectionView 생성하기
`UICollectionView`와 거의 동일하지만, `UICollectionViewLayout` 대신 `WispCompositionalLayout`을 받습니다. 

```swift
import Wisp

let layout = UICollectionViewCompositionalLayout.wisp.make { sectionIndex, layoutEnvironment in
    // return your NSCollectionLayoutSection here
}

let myCollectionView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: layout
)
```

단일 섹션 레이아웃의 경우:
``` swift
// ...
let myCollectionView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout.wisp.make {
        // return your NSCollectionLayoutSection here
    }
)
// ...
```

혹은 더 간단히 이렇게 작성할 수도 있습니다:
``` swift
// 다중 섹션 레이아웃
let myCollectionView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: .wisp.make { sectionIndex, layoutEnvironment in
        // return your NSCollectionLayoutSection here
    }
)

// 단일 섹션 레이아웃
let myCollectionView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: .wisp.make {
        // return your NSCollectionLayoutSection here
    }
)
```

### 2. UIKit의 내장 리스트 레이아웃 사용하기
UIKit의 리스트 스타일 레이아웃이 필요하다면 간단히 이렇게 호출하세요:

``` swift
let myListView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout.wisp.list(using: .plain)
)
```
혹은 더 간단히:
``` swift
let myListView = WispableCollectionView(frame: .zero, collectionViewLayout: .wisp.list(using: .plain))
```

### 3. wisp.present로 화면 전환하기
추가 delegate 설정은 필요 없습니다. 한 줄이면 동작합니다!

``` swift
let secondVC = MyViewController()
wisp.present(secondVC, collectionView: myCollectionView, at: indexPath)
// ⚠️ Note: The collection view must be a subview of the presenting view controller.
```

### 4. Dismiss 동작
기본적으로 wisp로 present된 뷰컨트롤러는 드래그 제스처(pan gesture) 또는 배경을 탭하는 것으로 dismiss할 수 있습니다.
하지만, 개발자가 원하는 시점에 명시적으로 dismiss를 하고 싶다면, 다음과 같이 public API를 호출할 수 있습니다:

``` swift
// present된 뷰컨트롤러 내부에서 스스로 dismiss하는 경우
self.wisp.dismiss(to: IndexPath(item: 0, section: 0), animated: true)
```

### 5. Dismiss 함수 시그니처
``` swift
func dismiss(
    to indexPath: IndexPath? = nil,
    animated: Bool = true
)
```
indexPath가 nil인 경우, 처음 present될 때 사용한 원래 indexPath로 wisp가 dismiss를 시도합니다.
dismiss 시점에 다른 indexPath로 되돌아가야 한다면, to 매개변수에 원하는 indexPath를 넣어주면 됩니다.

예시:
``` swift
// 처음 present된 셀과는 다른 셀로 dismiss하기
self.wisp.dismiss(to: IndexPath(item: 5, section: 0), animated: true)
```

### ✅ 끝!
- UICollectionView와 친숙한 API
- 커스텀 레이아웃 또는 리스트 레이아웃을 간단하게 생성
- 번거로움 없는 매끄러운 화면 전환

## ⚙️ Configuration

만약 애니메이션 속도, 펼쳐질 카드의 크기나 corner radius 등을 변경하고 싶다면 
`WispConfiguration`을 통해 커스텀 설정을 할 수 있습니다.
## WispConfiguration (v1.3.0)

버전 **1.3.0**부터 `WispConfiguration`이 **DSL 기반 구성 방식**으로 리팩토링되었습니다.  
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
| <img src="https://github.com/user-attachments/assets/ae85c010-fa94-40e6-bb61-0f834f3de4fb" width=130> | <img src="https://github.com/user-attachments/assets/99e50638-317d-456a-8e3e-11707eda2876" width=130> | <img src="https://github.com/user-attachments/assets/6a3ee01b-cd2d-4fc1-a16a-ba1c3db11b9b" width=130>  |  <img src="https://github.com/user-attachments/assets/f888ae8c-5777-45c8-a807-fd5627b5e6f2" width=130> |

## 📌 최소 요구 사항
- iOS 15.0+
- swift 컴파일러 5.9+
- UIKit
- Compositional Layout


## 📄 License

MIT License. See [LICENSE](https://github.com/nolanMinsung/Wisp?tab=MIT-1-ov-file#readme) for more information.
