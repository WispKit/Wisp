# Wisp ✨

### A lightweight and beautiful Card-style transition library for `UICollectionView` 
### with smooth animations and intuitive interaction.
### [🔗 Github Repository →](https://github.com/WispKit/Wisp)

[🇰🇷 한국어 README 보기 →](./Documentation/README.KO.md)
---


## ✨ Features

- 📱 **Smooth and elegant transition** from a cell to fullscreen.
- 🔙 **Drag to dismiss**: return back to the original cell by dragging or tapping background.
- 🎯 **Smooth and intuitive interactions**, inspired by transitions seen in apps like Instagram and Netflix
- 🧱 Fully compatible with `UICollectionView` built using **Compositional Layout**.
- ⚙️ Simple and customizable via `WispConfiguration`.

---

## 📸 Preview

| Intuitive Drag Interaction | Tap to Dismiss |
|:--:|:--:|
|<img src="https://github.com/user-attachments/assets/22d76600-628c-4f38-964b-68192578e99e" width=200> |  <img src="https://github.com/user-attachments/assets/9d2241fa-ebe9-4823-95cc-2701b56ee47f" width=200>|

---

## ⬇️ Installation

This library supports installation via [Swift Package Manager](https://swift.org/package-manager/):

1. Open your Xcode project.
2. Go to **File > Add Package Dependencies...**
3. Enter the package URL: `https://github.com/WispKit/Wisp.git`
4. Select the version and add it to your target.


## 🚀 How To Use

### 1. Create a WispCompositionalLayout

`WispCompositionalLayout` is designed to work almost identically to `UICollectionViewCompositionalLayout`.
You can use the same APIs you already know — the only difference is that you call them through `.wisp.make`.

That means every factory method available on `UICollectionViewCompositionalLayout`
(e.g. `init(section:)`, `init(sectionProvider:)`, or `list(using:)`)
has its Wisp equivalent:

``` swift
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

So instead of calling UIKit’s initializer directly,
you can simply use the .wisp.make(...) syntax:
``` swift
// Multi-section layout
let layout = UICollectionViewCompositionalLayout.wisp.make { sectionIndex, layoutEnvironment in
    // return your SectionProvider here
}

// Single-section layout
let simpleLayout = UICollectionViewCompositionalLayout.wisp.make {
    // return your NSCollectionLayoutSection here
}

// List layout
let listLayout = UICollectionViewCompositionalLayout.wisp.make.list(using: .plain)
```

### 2. Create a `WispableCollectionView`

`WispableCollectionView` is just like `UICollectionView`, but it takes a `WispCompositionalLayout` instead of `UICollectionViewLayout`.
Once you have your layout, pass it to `WispableCollectionView`:

``` swift
let myCollectionView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: layout
)
```

Or inline it:

``` swift
let myCollectionView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: .wisp.make {
        // return your NSCollectionLayoutSection here
    }
)
```

You can also build with list layout easily:
``` swift
let myListView = WispableCollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout.wisp.list(using: .plain)
)
```
or you can simplify like this:
``` swift
let myListView = WispableCollectionView(frame: .zero, collectionViewLayout: .wisp.list(using: .plain))
```

### 3. Present using `wisp.present( ... )`
No extra delegates or boilerplate needed.
``` swift
class MyViewController: UIViewController, UICollectionViewDelegate {
    
    // ...
    
    let myCollectionView: WispableCollectionView(
        frame: .zero,
        collectionViewLayout: .wisp.make { ... }
    )
    // ...
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let secondVC = MyViewController()
        wisp.present(secondVC, collectionView: myCollectionView, at: indexPath)
        // ⚠️ Note: The collection view must be a subview of the presenting view controller.
    }
    
    // ...
    
}
```

### 4. Dismiss Behavior
By default, a wisp-presented view controller can be dismissed with a drag gesture (pan gesture) or by tapping the background.
However, if you want to dismiss explicitly at a specific moment in your code, you can call the public API:

``` swift
// Inside the presented view controller
self.wisp.dismiss(to: IndexPath(item: 0, section: 0), animated: true)
```

### 5. Using Delegate

Wisp provides a delegate so you can detect when a card restoration (returning animation) begins and ends.  
This is useful because the restoring animation is not part of the actual view controller’s lifecycle —  
the view controller is already dismissed when the card starts restoring.

You can set the delegate from the presenting view controller:

``` swift
import Wisp
import UIKit

final class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        wisp.delegate = self
    }
}

extension MyViewController: WispPresenterDelegate {
    func wispWillRestore() {
        print("Restoring will begin.")
    }

    func wispDidRestore() {
        print("Restoring completed.")
    }
}
```

When a Wisp-presented view controller is dismissed (via drag, tap, or programmatically),
the restoring animation is handled internally by a captured snapshot view, not by the dismissed view controller itself.
Therefore, UIKit’s lifecycle methods such as viewWillAppear or viewDidDisappear won’t notify you of this transition.
Instead, you can rely on these two delegate methods:

- `wispWillRestore()`: called when the card restoration begins
- `wispDidRestore()`: called when the restoration animation finishes

You can use this delegate to coordinate updates with your collection view or perform custom UI changes.


### 6. Dismiss API Signature

``` swift
func dismiss(
    to indexPath: IndexPath? = nil,
    animated: Bool = true
)
```
If indexPath is nil, the view will try to use the original indexPath used at the time of presentation.
If you want the view to dismiss to a different indexPath, just provide it in the to parameter.

Example:
``` swift
// Dismiss to a different cell than the one originally presented from
self.wisp.dismiss(to: IndexPath(item: 5, section: 0), animated: true)
```

### ✅ That’s it!
- Familiar API, just like UICollectionView
- Simple creation of custom or list layouts
- Smooth presentation with zero hassle

## ⚙️ Configuration

WispConfiguration allows you to tweak the animation and layout behavior.

From version **1.3.0**, `WispConfiguration` has been refactored to use a **DSL-based configuration style** for better readability, maintainability, and future extensibility.
> For details, see the [WispConfiguration DSL Guide](./Documentation/WispConfiguration.md).

### Quick Example

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
All properties are optional and have default values.

For example, Use `presentedAreaInset` to customize the width and height of each card presented.

| fullscreen | formSheet style | card | small pop up |
|:--:|:--:|:--:|:--:|
| <img src="https://github.com/user-attachments/assets/ae85c010-fa94-40e6-bb61-0f834f3de4fb" width=130> | <img src="https://github.com/user-attachments/assets/99e50638-317d-456a-8e3e-11707eda2876" width=130> | <img src="https://github.com/user-attachments/assets/6a3ee01b-cd2d-4fc1-a16a-ba1c3db11b9b" width=130>  |  <img src="https://github.com/user-attachments/assets/f888ae8c-5777-45c8-a807-fd5627b5e6f2" width=130> |


## 📌 Requirements
- iOS: 15.0+
- swift compiler: 5.9+
- UIKit
- Compositional Layout


## 📄 License

MIT License. See [LICENSE](https://github.com/nolanMinsung/Wisp?tab=MIT-1-ov-file#readme) for more information.
