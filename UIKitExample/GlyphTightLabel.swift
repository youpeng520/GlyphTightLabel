//
//  GlyphTightLabel.swift
//  UIKitExample
//
//  Created by Sun on 2026/6/4.
//

import CoreText
import UIKit

final class GlyphTightLabel: UILabel {
    var verticalPadding: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    override var text: String? {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    override var font: UIFont! {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    override var intrinsicContentSize: CGSize {
        let fallbackSize = super.intrinsicContentSize
        guard let text, !text.isEmpty, let font else {
            return fallbackSize
        }

        let metrics = GlyphTightTextLayout.metrics(text: text, font: font)
        return CGSize(
            width: ceil(metrics.lineWidth),
            height: ceil(metrics.tightHeight + verticalPadding * 2)
        )
    }

    override func sizeThatFits(_: CGSize) -> CGSize {
        intrinsicContentSize
    }

    override func drawText(in rect: CGRect) {
        guard
            let text,
            !text.isEmpty,
            let font,
            let context = UIGraphicsGetCurrentContext()
        else {
            super.drawText(in: rect)
            return
        }

        let layout = GlyphTightTextLayout.metrics(text: text, font: font)
        let line = CTLineCreateWithAttributedString(
            NSAttributedString(string: text, attributes: FontMetricsCalculator.coreTextAttributes(font: font))
        )
        let contentRect = rect.insetBy(dx: 0, dy: verticalPadding)
        let baselineY = contentRect.minY
            + max(0, (contentRect.height - layout.tightHeight) / 2)
            + layout.baselineY
        let originX = alignedOriginX(lineWidth: layout.lineWidth, in: contentRect)

        context.saveGState()
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.height)
        context.scaleBy(x: 1, y: -1)
        context.textPosition = CGPoint(x: originX, y: bounds.height - baselineY)
        CTLineDraw(line, context)
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
}

enum GlyphTightTextLayout {
    struct Metrics {
        let glyphBounds: CGRect
        let lineWidth: CGFloat
        let baselineY: CGFloat
        let tightHeight: CGFloat
    }

    static func metrics(text: String, font: UIFont) -> Metrics {
        let line = CTLineCreateWithAttributedString(
            NSAttributedString(string: text, attributes: FontMetricsCalculator.coreTextAttributes(font: font))
        )
        let glyphBounds = FontMetricsCalculator.glyphUnionBounds(text: text, font: font)
        return Metrics(
            glyphBounds: glyphBounds,
            lineWidth: CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil)),
            baselineY: -glyphBounds.minY,
            tightHeight: glyphBounds.height
        )
    }
}

enum FontMetricsCalculator {
    static func glyphUnionBounds(text: String, font: UIFont) -> CGRect {
        let line = CTLineCreateWithAttributedString(
            NSAttributedString(string: text, attributes: coreTextAttributes(font: font))
        )
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

    static func coreTextAttributes(font: UIFont) -> [NSAttributedString.Key: Any] {
        let ctFont = CTFontCreateWithName(font.fontName as CFString, font.pointSize, nil)
        return [kCTFontAttributeName as NSAttributedString.Key: ctFont]
    }
}
