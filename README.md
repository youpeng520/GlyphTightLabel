# GlyphTightLabel

基于 CoreText glyph bounds 排版的 `UILabel` 子类，让文字在视觉上更贴近 Label 的上下边缘，而不是系统 `lineHeight` 带来的额外留白。

## 安装（Swift Package Manager）

在 Xcode：**File → Add Package Dependencies…**，填入仓库 URL：

```
https://github.com/youpeng520/GlyphTightLabel.git
```

或在 `Package.swift` 中：

```swift
dependencies: [
    .package(url: "https://github.com/youpeng520/GlyphTightLabel.git", from: "1.0.0"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "GlyphTightLabel", package: "GlyphTightLabel"),
        ]
    ),
]
```

使用：

```swift
import GlyphTightLabel

let label = GlyphTightLabel()
label.text = "Agjpqy"
label.font = .systemFont(ofSize: 28)
label.numberOfLines = 0
```

## 运行 Demo

Demo 在 `Example/` 目录，通过本地 SPM 依赖仓库根目录的 `Package.swift`。

```bash
open Example/GlyphTightLabelDemo.xcodeproj
```

在 Xcode 中选择 **GlyphTightLabelDemo** scheme，运行到模拟器即可。

命令行构建：

```bash
xcodebuild -project Example/GlyphTightLabelDemo.xcodeproj \
  -scheme GlyphTightLabelDemo \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

若已安装 [XcodeGen](https://github.com/yonaskolb/XcodeGen)，也可用 `Example/project.yml` 重新生成工程：

```bash
cd Example && xcodegen generate
```

## 主要 API

| 类型 | 说明 |
|------|------|
| `GlyphTightLabel` | 按 glyph tight bounds 测量与绘制的 Label |
| `GlyphTightTextLayout` | 仅计算布局尺寸，不负责绘制 |
| `FontMetricsCalculator` | glyph 外接矩形与 CoreText 属性工具 |

### `GlyphTightLabel` 常用属性

- `verticalPadding`：在 tight 高度外额外增加的上下内边距
- `lineSpacing`：多行时相邻两行 tight 区域之间的间距
- `showsDebugLineSeparators`：绘制每行上下边界调试线

## 要求

- iOS 13+
- Swift 5.9+

## 仓库结构

```
.
├── Package.swift              # SPM 库定义
├── Sources/GlyphTightLabel/   # 库源码
└── Example/                   # Demo App（XcodeGen）
```

## 本地验证 SPM

```bash
swift package resolve
```

> iOS 库需在 Xcode 或 `xcodebuild` 中链接到 App target 进行完整编译；`swift build` 在纯 macOS 目标下可能无法单独编译 UIKit 代码。

## UIKitExample（可选）

同仓库中的 `UIKitExample/` 为更完整的 UIKit 示例工程（含字体度量等页面），与发布用的 SPM 包相互独立；集成本库时请以 `Sources/GlyphTightLabel` 为准。
