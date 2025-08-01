# Wisp ✨

### A lightweight and beautiful card-style transition library for `UICollectionView` 
### with smooth animations and intuitive interaction.

<!--[한국어 README 보기 →](./README.KO.md)-->
---


## ✨ Features

- 📱 **Smooth and elegant transition** from a cell to fullscreen.
- 🔙 **Drag to dismiss**: return back to the original cell by dragging or tapping background.
- 🎯 **Smooth and intuitive interactions**, inspired by transitions seen in apps like Instagram and Netflix
- 🧱 Fully compatible with `UICollectionView` built using **Compositional Layout**.
- ⚙️ Simple and customizable via `WispConfiguration`.

---

## 📸 Preview

|<img src="https://github.com/user-attachments/assets/de41bad1-a288-455f-85c8-6c2d18dacbe1" width=200> |  <img src="https://github.com/user-attachments/assets/23140aed-2abd-4cb4-a29e-23d4893e1e0e" width=200>|
|:--:|:--:|
| Intuitive Drag Interaction | Tap to Dismiss |

---

# ⬇️ Installation

This library supports installation via [Swift Package Manager](https://swift.org/package-manager/) only:

1. Open your Xcode project.
2. Go to **File > Add Package Dependencies...**
3. Enter the package URL: `https://github.com/nolanMinsung/Wisp.git`
4. Select the version and add it to your target.


## 🚀 How To Use
1.	Use `WispableCollectionView` instead of a regular UICollectionView.
2.	Present your UIViewController with just one method call!


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

Then in your presenting view controller:

``` swift
let secondVC = MyViewController()
wisp.present(secondVC, collectionView: myCollectionView, at: indexPath)
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


## 📄 License

MIT License. See [LICENSE](https://github.com/nolanMinsung/Wisp?tab=MIT-1-ov-file#readme) for more information.
