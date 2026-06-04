//
//  GlyphTightLabel.swift
//  UIKitExample
//
//  Created by Sun on 2026/6/4.
//

import CoreText
import UIKit

/// 使用实际 glyph bounds 而不是字体 lineHeight 进行排版和绘制的 UILabel。
///
/// `GlyphTightLabel` 适合用来观察或实现“文字视觉上贴近 Label 上下边”的效果。
/// 它会用 CoreText 计算每一行真实 glyph 外接矩形，再根据这些外接矩形决定
/// `intrinsicContentSize`、`sizeThatFits`、Auto Layout fitting size 和实际绘制位置。
///
/// 注意：该类会重绘文本，不完全等同于系统 UILabel 的默认 TextKit 绘制行为；
/// 如果业务依赖 attributedText、复杂截断、省略号或系统动态字体，应先补齐对应逻辑。
open class GlyphTightLabel: UILabel {
    /// 是否绘制每一行 tight 区域的调试分割线。
    ///
    /// 默认为 `false`。开启后，每一行的顶部会绘制红色虚线，底部会绘制蓝色虚线，
    /// 用于检查多行文本的 tight 高度、行间边界和自动换行结果。
    public var showsDebugLineSeparators = false {
        didSet {
            setNeedsDisplay()
        }
    }

    /// 绘制时额外保留的上下内边距。
    ///
    /// 默认值为 `0`，表示 Label 高度完全由 glyph tight bounds 决定。
    /// 设置为正数后，最终高度会在 tight height 基础上增加 `verticalPadding * 2`，
    /// 文本仍会在内容区域中垂直居中。
    public var verticalPadding: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    /// 多行时相邻两行 tight 区域之间的额外间距。
    ///
    /// 默认 `0`：下一行紧接上一行 glyph 下边界。设为正值可在行与行之间留出空隙，
    /// 总高度与 `GlyphTightTextLayout.metrics(lineSpacing:)` 一致。
    public var lineSpacing: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    /// Label 显示的纯文本。
    ///
    /// 文本变化后会重新计算 glyph bounds，并刷新 intrinsic size 和绘制结果。
    override open var text: String? {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    /// 用于计算和绘制文本的字体。
    ///
    /// 字体变化会影响 glyph bounds、分行宽度、baseline 和 tight height。
    override open var font: UIFont! {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    /// 最大行数。
    ///
    /// 与 UILabel 保持一致：`0` 表示不限行；大于 `0` 时最多绘制指定行数。
    /// 自动换行由可用宽度决定，显式换行符 `\n` 也会参与分行。
    override open var numberOfLines: Int {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    private var measuredWidth: CGFloat = 0

    /// 基于当前文本、字体和可用宽度计算的 tight intrinsic size。
    ///
    /// 当 Auto Layout 已经给 Label 一个宽度时，会按该宽度自动换行并返回自撑开的高度；
    /// 否则按不受限宽度测量，行为接近单行自然尺寸。
    override open var intrinsicContentSize: CGSize {
        let fallbackSize = super.intrinsicContentSize
        guard let text, !text.isEmpty, font != nil else {
            return fallbackSize
        }

        return fittingSize(constrainedWidth: preferredMeasurementWidth)
    }

    /// 返回给定宽度下的 tight size。
    ///
    /// `size.width` 大于 0 时作为自动换行宽度；否则按不受限宽度测量。
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let text, !text.isEmpty, font != nil else {
            return super.sizeThatFits(size)
        }

        return fittingSize(constrainedWidth: size.width)
    }

    /// 返回给定 bounds 下 tight 文本区域。
    ///
    /// UIKit 和 Auto Layout 会通过该方法查询指定行数和宽度下的文本占用区域。
    override open func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        guard let text, !text.isEmpty, font != nil else {
            return super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        }

        let constrainedWidth = bounds.width > 0 ? bounds.width : preferredMeasurementWidth
        let metrics = GlyphTightTextLayout.metrics(
            text: text,
            font: font,
            constrainedWidth: constrainedWidth,
            numberOfLines: numberOfLines,
            lineSpacing: lineSpacing
        )
        return CGRect(
            x: bounds.minX,
            y: bounds.minY,
            width: min(ceil(metrics.maxLineWidth), constrainedWidth),
            height: ceil(metrics.tightHeight + verticalPadding * 2)
        )
    }

    /// 返回 Auto Layout 在目标尺寸下需要的 tight fitting size。
    override open func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        fittingSize(constrainedWidth: targetSize.width)
    }

    /// 返回 Auto Layout 在目标尺寸和 fitting priority 下需要的 tight fitting size。
    ///
    /// 当前实现主要依赖目标宽度计算自动换行后的高度，priority 不改变测量策略。
    override open func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority _: UILayoutPriority,
        verticalFittingPriority _: UILayoutPriority
    ) -> CGSize {
        fittingSize(constrainedWidth: targetSize.width)
    }

    /// 监听宽度变化并刷新 preferredMaxLayoutWidth。
    ///
    /// 这能让多行 Label 在 Auto Layout 改变宽度后重新计算自撑开的高度。
    override open func layoutSubviews() {
        super.layoutSubviews()

        guard measuredWidth != bounds.width else {
            return
        }

        measuredWidth = bounds.width
        preferredMaxLayoutWidth = bounds.width
        invalidateIntrinsicContentSize()
    }

    /// 用 CoreText 按 glyph tight bounds 绘制文本。
    ///
    /// 每一行会根据自身 glyph bounds 计算 baseline，因此行高来自真实 glyph 外接矩形，
    /// 而不是 `UIFont.lineHeight`。
    override open func drawText(in rect: CGRect) {
        guard
            let text,
            !text.isEmpty,
            let font,
            let context = UIGraphicsGetCurrentContext()
        else {
            super.drawText(in: rect)
            return
        }

        let contentRect = rect.insetBy(dx: 0, dy: verticalPadding)
        let layout = GlyphTightTextLayout.metrics(
            text: text,
            font: font,
            constrainedWidth: contentRect.width,
            numberOfLines: numberOfLines,
            lineSpacing: lineSpacing
        )
        var lineTopY = contentRect.minY + max(0, (contentRect.height - layout.tightHeight) / 2)

        context.saveGState()
        context.setFillColor(textColor.cgColor)
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1, y: -1)

        for (index, line) in layout.lines.enumerated() {
            let baselineY = lineTopY + line.baselineY
            let originX = alignedOriginX(lineWidth: line.lineWidth, in: contentRect)
            if showsDebugLineSeparators {
                drawDebugLineSeparator(lineTopY: lineTopY, lineHeight: line.tightHeight, context: context)
            }
            context.textPosition = CGPoint(x: originX, y: bounds.height - baselineY)
            CTLineDraw(line.ctLine, context)
            lineTopY += line.tightHeight
            if index < layout.lines.count - 1 {
                lineTopY += lineSpacing
            }
        }

        context.restoreGState()
    }

    private func alignedOriginX(lineWidth: CGFloat, in rect: CGRect) -> CGFloat {
        switch textAlignment {
        case .center:
            return rect.midX - lineWidth / 2
        case .right:
            return rect.maxX - lineWidth
        default:
            return rect.minX
        }
    }

    private var preferredMeasurementWidth: CGFloat {
        if preferredMaxLayoutWidth > 0 {
            return preferredMaxLayoutWidth
        }
        if bounds.width > 0 {
            return bounds.width
        }
        return .greatestFiniteMagnitude
    }

    private func fittingSize(constrainedWidth: CGFloat) -> CGSize {
        guard let text, !text.isEmpty, let font else {
            return super.intrinsicContentSize
        }

        let width = constrainedWidth > 0 && constrainedWidth < .greatestFiniteMagnitude
            ? constrainedWidth
            : .greatestFiniteMagnitude
        let metrics = GlyphTightTextLayout.metrics(
            text: text,
            font: font,
            constrainedWidth: width,
            numberOfLines: numberOfLines,
            lineSpacing: lineSpacing
        )

        return CGSize(
            width: width == .greatestFiniteMagnitude ? ceil(metrics.maxLineWidth) : width,
            height: ceil(metrics.tightHeight + verticalPadding * 2)
        )
    }

    private func drawDebugLineSeparator(lineTopY: CGFloat, lineHeight: CGFloat, context: CGContext) {
        let topY = bounds.height - lineTopY
        let bottomY = bounds.height - lineTopY - lineHeight

        context.saveGState()
        context.setLineWidth(1)
        context.setLineDash(phase: 0, lengths: [4, 3])

        context.setStrokeColor(UIColor.systemRed.withAlphaComponent(0.75).cgColor)
        context.move(to: CGPoint(x: 0, y: topY))
        context.addLine(to: CGPoint(x: bounds.width, y: topY))

        context.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.75).cgColor)
        context.move(to: CGPoint(x: 0, y: bottomY))
        context.addLine(to: CGPoint(x: bounds.width, y: bottomY))

        context.strokePath()
        context.restoreGState()
    }
}

/// Glyph-tight 文本布局计算工具。
///
/// 该类型只负责把文本、字体、宽度和行数转换成 CoreText 行信息与 tight 尺寸，
/// 不负责实际绘制。外部如果只想拿到 glyph bounds 或 tight height，可以直接使用它。
public enum GlyphTightTextLayout {
    /// 单行文本的 tight 布局结果。
    public struct LineMetrics {
        /// 可直接传给 `CTLineDraw` 绘制的 CoreText 行对象。
        public let ctLine: CTLine

        /// 该行所有 glyph 的联合外接矩形，坐标系以 baseline 为基准。
        public let glyphBounds: CGRect

        /// CoreText 计算出的 typographic line width。
        public let lineWidth: CGFloat

        /// 从该行 tight 区域顶部到 baseline 的距离。
        public let baselineY: CGFloat

        /// 该行 glyph tight bounds 的高度。
        public let tightHeight: CGFloat
    }

    /// 多行文本的 tight 布局结果。
    public struct Metrics {
        /// 按绘制顺序排列的每行布局结果。
        public let lines: [LineMetrics]

        /// 所有行中最大的 line width。
        public let maxLineWidth: CGFloat

        /// 所有行 `tightHeight` 与行间 `lineSpacing` 累加后的总高度。
        public let tightHeight: CGFloat
    }

    /// 按不受限宽度测量单行文本。
    ///
    /// - Parameters:
    ///   - text: 要测量的文本。
    ///   - font: 用于测量的字体。
    /// - Returns: 单行文本的 glyph-tight 布局结果。
    public static func metrics(text: String, font: UIFont) -> Metrics {
        metrics(
            text: text,
            font: font,
            constrainedWidth: .greatestFiniteMagnitude,
            numberOfLines: 1
        )
    }

    /// 按指定宽度和行数测量文本。
    ///
    /// `constrainedWidth` 会作为自动换行宽度；`numberOfLines == 0` 表示不限行。
    /// 方法同时支持显式换行符 `\n` 和 CoreText 自动换行。
    ///
    /// - Parameters:
    ///   - text: 要测量的文本。
    ///   - font: 用于测量的字体。
    ///   - constrainedWidth: 自动换行宽度。
    ///   - numberOfLines: 最大行数，`0` 表示不限行。
    ///   - lineSpacing: 相邻两行 tight 区域之间的额外间距，默认 `0`。
    /// - Returns: 多行文本的 glyph-tight 布局结果。
    public static func metrics(
        text: String,
        font: UIFont,
        constrainedWidth: CGFloat,
        numberOfLines: Int,
        lineSpacing: CGFloat = 0
    ) -> Metrics {
        let lines = makeLines(
            text: text,
            font: font,
            constrainedWidth: max(1, constrainedWidth),
            numberOfLines: numberOfLines
        )
        let maxLineWidth = lines.map(\.lineWidth).max() ?? 0
        let glyphHeight = lines.reduce(CGFloat(0)) { $0 + $1.tightHeight }
        let gapCount = max(0, lines.count - 1)
        let tightHeight = glyphHeight + lineSpacing * CGFloat(gapCount)

        return Metrics(
            lines: lines,
            maxLineWidth: maxLineWidth,
            tightHeight: tightHeight
        )
    }

    private static func makeLines(
        text: String,
        font: UIFont,
        constrainedWidth: CGFloat,
        numberOfLines: Int
    ) -> [LineMetrics] {
        let attributedText = NSAttributedString(
            string: text,
            attributes: FontMetricsCalculator.coreTextAttributes(font: font)
        )
        let typesetter = CTTypesetterCreateWithAttributedString(attributedText)
        let nsText = text as NSString
        let length = attributedText.length
        let maximumLineCount = numberOfLines > 0 ? numberOfLines : Int.max
        let wrapsText = constrainedWidth < .greatestFiniteMagnitude

        var lines: [LineMetrics] = []
        var location = 0

        while location < length, lines.count < maximumLineCount {
            let remainingRange = NSRange(location: location, length: length - location)
            let newlineRange = nsText.range(of: "\n", options: [], range: remainingRange)
            let paragraphEnd = newlineRange.location == NSNotFound ? length : newlineRange.location
            let paragraphLength = paragraphEnd - location

            if paragraphLength == 0 {
                location = min(length, paragraphEnd + 1)
                continue
            }

            let suggestedLength = wrapsText
                ? CTTypesetterSuggestLineBreak(typesetter, location, Double(constrainedWidth))
                : paragraphLength
            let lineLength = max(1, min(suggestedLength, paragraphLength))
            let lineRange = CFRange(location: location, length: lineLength)
            let line = CTTypesetterCreateLine(typesetter, lineRange)
            let glyphBounds = FontMetricsCalculator.glyphUnionBounds(line: line)

            lines.append(
                LineMetrics(
                    ctLine: line,
                    glyphBounds: glyphBounds,
                    lineWidth: CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil)),
                    baselineY: -glyphBounds.minY,
                    tightHeight: glyphBounds.height
                )
            )

            location += lineLength
            if location == paragraphEnd {
                location = min(length, paragraphEnd + 1)
            }
        }

        return lines
    }
}

/// 字体和 glyph bounds 相关的 CoreText 计算工具。
public enum FontMetricsCalculator {
    /// 计算一段文本在指定字体下的 glyph 联合外接矩形。
    ///
    /// 返回值坐标系以 baseline 为基准：`minY` 通常为负值，表示 descender
    /// 或其他低于 baseline 的部分；`maxY` 表示高于 baseline 的部分。
    ///
    /// - Parameters:
    ///   - text: 要测量的文本。
    ///   - font: 用于测量的字体。
    /// - Returns: 所有 glyph 的联合外接矩形。
    public static func glyphUnionBounds(text: String, font: UIFont) -> CGRect {
        let line = CTLineCreateWithAttributedString(
            NSAttributedString(string: text, attributes: FontMetricsCalculator.coreTextAttributes(font: font))
        )
        return glyphUnionBounds(line: line)
    }

    /// 计算 CoreText 行中所有 glyph 的联合外接矩形。
    ///
    /// - Parameter line: 已经由 CoreText 创建好的 `CTLine`。
    /// - Returns: 该行所有 glyph 的联合外接矩形。
    public static func glyphUnionBounds(line: CTLine) -> CGRect {
        let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []
        var unionRect = CGRect.null

        for run in runs {
            guard let runFontValue = (CTRunGetAttributes(run) as NSDictionary)[kCTFontAttributeName] else {
                continue
            }
            let runFont = runFontValue as! CTFont

            let glyphCount = CTRunGetGlyphCount(run)
            var glyphs = Array(repeating: CGGlyph(), count: glyphCount)
            var positions = Array(repeating: CGPoint.zero, count: glyphCount)
            CTRunGetGlyphs(run, CFRange(location: 0, length: glyphCount), &glyphs)
            CTRunGetPositions(run, CFRange(location: 0, length: glyphCount), &positions)

            for index in 0 ..< glyphCount {
                var glyph = glyphs[index]
                let glyphBounds = CTFontGetBoundingRectsForGlyphs(runFont, .horizontal, &glyph, nil, 1)
                let position = positions[index]
                let rect = CGRect(
                    x: position.x + glyphBounds.minX,
                    y: -glyphBounds.maxY,
                    width: glyphBounds.width,
                    height: glyphBounds.height
                )
                unionRect = unionRect.union(rect)
            }
        }

        return unionRect.isNull ? .zero : unionRect
    }

    /// 生成 CoreText 使用的字体 attribute。
    ///
    /// UIKit 的 `UIFont` 会被转换成同名同字号的 `CTFont`，用于 `CTLine` 和
    /// `CTTypesetter` 的计算与绘制。
    ///
    /// - Parameter font: UIKit 字体。
    /// - Returns: 包含 `kCTFontAttributeName` 的 attributed string attributes。
    public static func coreTextAttributes(font: UIFont) -> [NSAttributedString.Key: Any] {
        let ctFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        return [kCTFontAttributeName as NSAttributedString.Key: ctFont]
    }
}
