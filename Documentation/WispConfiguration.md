# WispConfiguration DSL Guide

Starting from **v1.3.0**, `WispConfiguration` uses a **DSL (Domain Specific Language) style** configuration.  
This approach groups related settings (animation, gesture, layout) into separate namespaces, making configuration more intuitive.

---

## DSL Syntax Overview

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

## Available Configuration Options

### Animation
- speed: `enum` (.slow, .normal, .fast)
``` swift
config.setAnimation { animation in
    animation.speed = .fast
}
```

## Gesture
- allowedDirections: OptionSet (up, left, right, down)
- dismissByTap: Bool
``` swift
config.setGesture { gesture in
    gesture.allowedDirections = [.right, .down]
    gesture.dismissByTap = false
}
```

## Layout
- presentedAreaInset: UIEdgeInsets
- initialCornerRadius: CGFloat
- finalCornerRadius: CGFloat
- initialMaskedCorner: CACornerMask
- finalMaskedCorner: CACornerMask

``` swift
config.setLayout { layout in
    layout.presentedAreaInset = .zero
    layout.initialCornerRadius = 15
    layout.finalCornerRadius = 30
    layout.initialMaskedCorner = [ .layerMaxXMaxYCorner, // ... ]
    layout.finalMaskedCorner = [ .layerMaxXMaxYCorner, // ... ]
}
```

## Deprecated API

## In previous versions, WispConfiguration used a property-based API like this:

``` swift
let config = WispConfiguration(
    animationSpeed: .fast,
    presentedAreaInset: .zero,
    initialCornerRadius: 12,
    finalCornerRadius: 20,
    initialMaskedCorner: [.layerMaxXMaxYCorner],
    finalMaskedCorner: [.layerMaxXMaxYCorner]
)
```

This API is deprecated and will be removed in future releases.
When using deprecated APIs, you will see a compiler warning:

``` swift
'init(animationSpeed:presentedAreaInset:initialCornerRadius:finalCornerRadius:initialMaskedCorner:finalMaskedCorner:)' is deprecated: 
Use the new DSL-based configuration. For detailed usage, please refer to the Wisp GitHub README.
```









