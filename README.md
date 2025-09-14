# Wisp ✨

### A lightweight and beautiful Card-style transition library for `UICollectionView` 
### with smooth animations and intuitive interaction.

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

# ⬇️ Installation

This library supports installation via [Swift Package Manager](https://swift.org/package-manager/):

1. Open your Xcode project.
2. Go to **File > Add Package Dependencies...**
3. Enter the package URL: `https://github.com/nolanMinsung/Wisp.git`
4. Select the version and add it to your target.


## 🚀 How To Use
#### 1.	Use `WispableCollectionView` instead of a regular UICollectionView.
#### 2.	Present your UIViewController with just one method call!


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
Or use a simplified initializer for single-section layout:
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

Then in the view controller that owns the collection view::

``` swift
let secondVC = MyViewController()
wisp.present(secondVC, collectionView: myCollectionView, at: indexPath)
// ⚠️ Note: The collection view must be a subview of the presenting view controller.
```
### ✅ That’s it! No delegate mess, no manual transition setup. It just works.

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
