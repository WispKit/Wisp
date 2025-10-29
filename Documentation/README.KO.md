# Wisp ✨

### `UICollectionView`에서 사용할 수 있는 카드 형식의 커스텀 트랜지션을 지원하는 라이브러리입니다.
### 부드러운 애니메이션과 직관적인 인터페이스를 제공합니다.
### [🔗 깃허브 레포지토리 →](https://github.com/WispKit/Wisp)

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

### 1. WispCompositionalLayout 생성하기

`WispCompositionalLayout`은 `UICollectionViewCompositionalLayout`과 거의 동일한 방식으로 동작합니다.
이미 알고 있는 UIKit의 API를 그대로 사용할 수 있으며, `.wisp.make`를 사용하여 생성합니다.

즉, `UICollectionViewCompositionalLayout`에서 사용할 수 있는 모든 팩토리 메서드
(init(section:), init(sectionProvider:), list(using:) 등)는
Wisp에서도 동일하게 제공됩니다:

```swift
@MainActor
func make(section: NSCollectionLayoutSection) -> WispCompositionalLayout

@MainActor
func make(
    section: NSCollectionLayoutSection,
    configuration: UICollectionViewCompositionalLayoutConfiguration
) -> WispCompositionalLayout

@MainActor
func make(
    sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider
) -> WispCompositionalLayout

@MainActor
func make(
    sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider,
    configuration: UICollectionViewCompositionalLayoutConfiguration
) -> WispCompositionalLayout

@MainActor
func list(using configuration: UICollectionLayoutListConfiguration) -> WispCompositionalLayout
```

UIKit의 이니셜라이저를 직접 호출하는 대신
.wisp.make(...) 문법을 사용하면 됩니다:

``` swift
// 멀티 섹션 레이아웃
let layout = UICollectionViewCompositionalLayout.wisp.make { sectionIndex, layoutEnvironment in
    // 여기서 SectionProvider를 반환하세요.
}

// 단일 섹션 레이아웃
let simpleLayout = UICollectionViewCompositionalLayout.wisp.make {
    // 여기서 NSCollectionLayoutSection을 반환하세요.
}

// 리스트 레이아웃
let listLayout = UICollectionViewCompositionalLayout.wisp.list(using: .plain)
```

이 방식을 사용하면 기존 `UICollectionViewCompositionalLayout` 코드를 거의 수정하지 않고 그대로 재사용할 수 있습니다.
생성 구문(.wisp.make { ... })만 변경하여 사용할 수 있습니다.


### 2. WispableCollectionView 생성하기
`WispableCollectionView`는 기본적으로 `UICollectionView`와 동일하지만,
`UICollectionViewLayout` 대신 `WispCompositionalLayout`을 받습니다.
생성된 레이아웃을 그대로 전달하면 됩니다:

``` swift
let myCollectionView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: layout
)
```
또는 한 줄로 간단히 작성할 수도 있습니다:
``` swift
let myCollectionView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: .wisp.make {
        // NSCollectionLayoutSection을 반환하세요.
    }
)
```

리스트 형태의 레이아웃을 사용하는 경우:
``` swift
let myListView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout.wisp.list(using: .plain)
)

// 위 코드는 다음과 같이 한 줄로 간단하게 작성할 수도 있습니다.
let myListView = WispableCollectionView(frame: .zero, collectionViewLayout: .wisp.list(using: .plain))
```

### 3. wisp.present로 화면 전환하기
별도의 복잡한 커스텀 트랜지션 설정 없이 바로 사용할 수 있습니다.

``` swift
class MyViewController: UIViewController, UICollectionViewDelegate {
    
    // ...
    
    let myCollectionView = WispableCollectionView(
        frame: .zero,
        collectionViewLayout: .wisp.make { ... }
    )
    
    // ...
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let secondVC = MyViewController()
        wisp.present(secondVC, collectionView: myCollectionView, at: indexPath)
        // ⚠️ 주의: collectionView는 반드시 현재 ViewController의 하위 뷰로 포함되어 있어야 합니다.
    }
    
    // ...
}
```

### 4. Dismiss 동작
기본적으로 wisp로 present된 뷰컨트롤러는 드래그 제스처(pan gesture) 또는 배경을 탭하는 것으로 dismiss할 수 있습니다.
하지만, 개발자가 원하는 시점에 명시적으로 dismiss를 하고 싶다면, 다음과 같이 public API를 호출할 수 있습니다:

``` swift
// present된 뷰컨트롤러 내부에서 스스로 dismiss하는 경우
self.wisp.dismiss(to: IndexPath(item: 0, section: 0), animated: true)
```

### 5. Delegate 사용하기

Wisp는 카드가 원래 셀로 되돌아가는 복원(restoring) 애니메이션의 시작과 끝 시점을 감지할 수 있도록 delegate를 제공합니다.  
이 복원 애니메이션은 실제 뷰 컨트롤러의 생명주기(lifecycle)와는 별개로 동작합니다.  
왜냐하면 카드가 복원을 시작하는 시점에는 이미 해당 뷰 컨트롤러가 dismiss되었기 때문입니다.

delegate는 **presenting view controller** 쪽에서 설정할 수 있습니다:

``` swift
import Wisp

final class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        wisp.delegate = self
    }
}

extension MyViewController: WispPresenterDelegate {
    func wispWillRestore() {
        print("복원이 시작됩니다.")
    }

    func wispDidRestore() {
        print("복원이 완료되었습니다.")
    }
}
```

Wisp로 present된 뷰 컨트롤러가 드래그, 탭 또는 코드로 dismiss될 때,
복원 애니메이션은 실제 뷰 컨트롤러가 아니라 캡처된 스냅샷 뷰에 의해 처리됩니다.
따라서 UIKit의 생명주기 메서드(viewWillAppear, viewDidDisappear 등)에서는
이 복원 시점을 감지할 수 없습니다.

대신 Wisp의 delegate 메서드를 통해 다음과 같은 시점을 알 수 있습니다:

- wispWillRestore(): 카드 복원이 시작될 때 호출
- wispDidRestore(): 복원 애니메이션이 완료될 때 호출

이 delegate를 이용하면 collection view의 상태를 동기화하거나,
복원 시점에 맞춰 커스텀 UI 변경을 수행할 수 있습니다.

### 6. Dismiss 함수 시그니처
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
- UICollectionViewCompositional 코드를 거의 그대로 사용할 수 있습니다.
- UIKit의 커스텀 트랜지션을 별도로 설정할 필요가 없습니다. 이제 번거로움 없이 매끄러운 화면 전환을 구현할 수 있습니다.

## ⚙️ Configuration

만약 애니메이션 속도, 펼쳐질 카드의 크기나 corner radius 등을 변경하고 싶다면 
`WispConfiguration`을 통해 커스텀 설정을 할 수 있습니다.
## WispConfiguration (v1.3.0)

버전 **1.3.0**부터 `WispConfiguration`이 **DSL 기반 구성 방식**으로 리팩토링되었습니다.  
이로 인해 코드 가독성, 유지보수성, 확장성이 개선되었습니다.

> WispConfiguration에 대한 자세한 내용은 [WispConfiguration DSL 가이드](./WispConfiguration.md)를 참고하세요.

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
        gesture.dismissByTap = false
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
