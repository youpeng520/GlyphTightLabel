//
//  FontMetricsSampleView.swift
//  UIKitExample
//
//  Created by Sun on 2026/6/4.
//

import CoreText
import UIKit

final class FontMetricsSampleView: UIView {
    private enum Constants {
        static let fontSize: CGFloat = 56
        static let textAreaHeight: CGFloat = 104
    }

    private let sampleText = "Agjpqy"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.28)
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tightTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Glyph-tight UILabel"
        label.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tightLabel: GlyphTightLabel = {
        let label = GlyphTightLabel()
        label.textAlignment = .center
        label.textColor = .label
        label.backgroundColor = UIColor.systemCyan.withAlphaComponent(0.24)
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.borderColor = UIColor.systemTeal.cgColor
        label.layer.borderWidth = 1
        return label
    }()

    private let overlayView = FontMetricsOverlayView()

    private let metricsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let font: UIFont

    init(title: String, fontName: String) {
        font = UIFont(name: fontName, size: Constants.fontSize) ?? .systemFont(ofSize: Constants.fontSize)
        super.init(frame: .zero)

        titleLabel.text = title
        configureView()
        configureMetrics()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 8
        layer.borderColor = UIColor.separator.cgColor
        layer.borderWidth = 1

        textLabel.text = sampleText
        textLabel.font = font
        tightLabel.text = sampleText
        tightLabel.font = font

        overlayView.label = textLabel
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        overlayView.isUserInteractionEnabled = false
        overlayView.backgroundColor = .clear

        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(overlayView)
        addSubview(tightTitleLabel)
        addSubview(tightLabel)
        addSubview(metricsStackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),
            textLabel.heightAnchor.constraint(equalToConstant: Constants.textAreaHeight),

            overlayView.topAnchor.constraint(equalTo: textLabel.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor),

            tightTitleLabel.topAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: 18),
            tightTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24),
            tightTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24),

            tightLabel.topAnchor.constraint(equalTo: tightTitleLabel.bottomAnchor, constant: 8),
            tightLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            tightLabel.heightAnchor.constraint(equalToConstant: ceil(GlyphTightTextLayout.metrics(text: sampleText, font: font).tightHeight)),

            metricsStackView.topAnchor.constraint(equalTo: tightLabel.bottomAnchor, constant: 18),
            metricsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            metricsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            metricsStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16),
        ])
    }

    private func configureMetrics() {
        let glyphBounds = FontMetricsCalculator.glyphUnionBounds(text: sampleText, font: font)
        let tightMetrics = GlyphTightTextLayout.metrics(text: sampleText, font: font)
        let baselineY = Constants.textAreaHeight / 2 + (font.ascender + font.descender) / 2

        [
            ("fontName", font.fontName),
            ("pointSize", format(font.pointSize)),
            ("labelBounds", "fill x \(format(Constants.textAreaHeight))"),
            ("baselineY", format(baselineY)),
            ("glyphBounds", format(glyphBounds)),
            ("tightHeight", format(tightMetrics.tightHeight)),
            ("lineHeight", format(font.lineHeight)),
            ("ascender", format(font.ascender)),
            ("descender", format(font.descender)),
            ("capHeight", format(font.capHeight)),
            ("xHeight", format(font.xHeight)),
        ].forEach { title, value in
            metricsStackView.addArrangedSubview(makeMetricRow(title: title, value: value))
        }
    }

    private func makeMetricRow(title: String, value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .secondaryLabel
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .monospacedSystemFont(ofSize: 12, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.55

        let row = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 12
        return row
    }

    private func format(_ value: CGFloat) -> String {
        String(format: "%.1f pt", value)
    }

    private func format(_ rect: CGRect) -> String {
        String(
            format: "x%.1f y%.1f w%.1f h%.1f",
            rect.minX,
            rect.minY,
            rect.width,
            rect.height
        )
    }
}

private final class FontMetricsOverlayView: UIView {
    private struct MetricMarker {
        let name: String
        let y: CGFloat
        let color: UIColor
    }

    weak var label: UILabel?

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard
            let label,
            let text = label.text,
            let font = label.font,
            let context = UIGraphicsGetCurrentContext()
        else {
            return
        }

        let line = CTLineCreateWithAttributedString(
            NSAttributedString(string: text, attributes: FontMetricsCalculator.coreTextAttributes(font: font))
        )
        let lineWidth = CGFloat(CTLineGetTypographicBounds(line, nil, nil, nil))
        let baselineY = bounds.midY + (font.ascender + font.descender) / 2
        let textOriginX = alignedTextOriginX(lineWidth: lineWidth, label: label)

        let markers = [
            MetricMarker(name: "ascender", y: baselineY - font.ascender, color: .systemRed),
            MetricMarker(name: "cap", y: baselineY - font.capHeight, color: .systemOrange),
            MetricMarker(name: "x-height", y: baselineY - font.xHeight, color: .systemGreen),
            MetricMarker(name: "baseline", y: baselineY, color: .systemBlue),
            MetricMarker(name: "descender", y: baselineY - font.descender, color: .systemPurple),
        ]

        for marker in markers {
            drawHorizontalMetricLine(y: marker.y, color: marker.color, context: context)
        }
        drawMetricLabels(markers)
        drawGlyphBounds(line: line, textOriginX: textOriginX, baselineY: baselineY, context: context)
    }

    private func alignedTextOriginX(lineWidth: CGFloat, label: UILabel) -> CGFloat {
        switch label.textAlignment {
        case .center:
            return bounds.midX - lineWidth / 2
        case .right:
            return bounds.maxX - lineWidth
        default:
            return bounds.minX
        }
    }

    private func drawHorizontalMetricLine(y: CGFloat, color: UIColor, context: CGContext) {
        let pixelAlignedY = y.rounded(.toNearestOrAwayFromZero) + 0.5
        context.saveGState()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(1)
        context.setLineDash(phase: 0, lengths: [5, 4])
        context.move(to: CGPoint(x: bounds.minX, y: pixelAlignedY))
        context.addLine(to: CGPoint(x: bounds.maxX, y: pixelAlignedY))
        context.strokePath()
        context.restoreGState()
    }

    private func drawMetricLabels(_ markers: [MetricMarker]) {
        let labelHeight: CGFloat = 14
        let labelSpacing: CGFloat = 2
        var labelOrigins = markers.map { max(0, $0.y.rounded(.toNearestOrAwayFromZero) - labelHeight) }

        for index in labelOrigins.indices.dropFirst() {
            let minimumY = labelOrigins[index - 1] + labelHeight + labelSpacing
            if labelOrigins[index] < minimumY {
                labelOrigins[index] = minimumY
            }
        }

        if let lastOrigin = labelOrigins.last {
            let overflow = lastOrigin + labelHeight - bounds.height
            if overflow > 0 {
                let shift = min(overflow, labelOrigins.first ?? 0)
                labelOrigins = labelOrigins.map { $0 - shift }
            }
        }

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 11, weight: .medium),
            .backgroundColor: UIColor.systemBackground.withAlphaComponent(0.84),
        ]

        for (index, marker) in markers.enumerated() {
            var attributes = textAttributes
            attributes[.foregroundColor] = marker.color
            " \(marker.name) ".draw(at: CGPoint(x: 6, y: labelOrigins[index]), withAttributes: attributes)
        }
    }

    private func drawGlyphBounds(line: CTLine, textOriginX: CGFloat, baselineY: CGFloat, context: CGContext) {
        let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []

        context.saveGState()
        context.setStrokeColor(UIColor.systemPink.cgColor)
        context.setLineWidth(1)

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
                    x: textOriginX + position.x + glyphBounds.minX,
                    y: baselineY - position.y - glyphBounds.maxY,
                    width: glyphBounds.width,
                    height: glyphBounds.height
                )
                context.stroke(rect)
            }
        }

        context.restoreGState()
    }
}
