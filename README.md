# Wisp ✨

### A lightweight and beautiful Card-style transition library for `UICollectionView` 
### with smooth animations and intuitive interaction.

[🇰🇷 한국어 README 보기 →](./README.KO.md)
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
|<img src="https://github.com/user-attachments/assets/de41bad1-a288-455f-85c8-6c2d18dacbe1" width=200> |  <img src="https://github.com/user-attachments/assets/23140aed-2abd-4cb4-a29e-23d4893e1e0e" width=200>|

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

``` swift
let config = WispConfiguration(
    animationSpeed: .normal, // .fast, .normal, .slow
    presentedAreaInset: .init(top: 20, leading: 0, bottom: 20, trailing: 0),
    initialCornerRadius: 16,
    finalCornerRadius: 0,
    initialMaskedCorner: [.layerMinXMinYCorner, .layerMaxXMinYCorner],
    finalMaskedCorner: [.layerMinXMinYCorner, .layerMaxXMinYCorner]
)

wisp.present(secondVC, collectionView: myCollectionView, at: indexPath, configuration: config)
```
All properties are optional and have default values.


| Property | Type | Description |
|:--:|:--:|:--:|
|animationSpeed | .fast, .normal, .slow | Speed of the presentation animation |
|presentedAreaInset|NSDirectionalEdgeInsets|The inset of the final presented view (default: .zero)|
|initialCornerRadius|CGFloat|Corner radius at the beginning of animation|
|finalCornerRadius|CGFloat|Corner radius when fully presented|
|initialMaskedCorner|CACornerMask|Corners to apply rounding at start|
|finalMaskedCorner|CACornerMask|Corners to apply rounding at end|

For example, Use presentedAreaInset to customize the width and height of each card presented.

| fullscreen | formSheet style | card | small pop up |
|:--:|:--:|:--:|:--:|
| <img src="https://github.com/user-attachments/assets/dcbbc640-c7a1-439f-ba62-9c73e09b8c9b" width=130> | <img src="https://github.com/user-attachments/assets/0564c85f-9a09-4d3c-91be-8aaa83c29035" width=130> | <img src="https://github.com/user-attachments/assets/6d55a707-df20-46da-9211-3183461d7f85" width=130>  |  <img src="https://github.com/user-attachments/assets/ea68d539-889a-4017-b1ed-a6e29ec5d3df" width=130> |


## 📌 Requirements
- iOS 15.0+
- swift 5.0+
- UIKit
- Compositional Layout


## 📄 License

MIT License. See [LICENSE](https://github.com/nolanMinsung/Wisp?tab=MIT-1-ov-file#readme) for more information.
