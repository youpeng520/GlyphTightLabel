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
        static let fontSize: CGFloat = 42
        static let defaultLabelHeight: CGFloat = 104
    }

    private let sampleText = "Agjpqy Çãñá"
    private let tightMultilineText = "Agjpqy\nTight\nÇãñá"
    private let languageText = "Türkçe: İğüşöç\nPortuguês: ação coração\nEspañol: pingüino año\n日本語: こんにちは世界"
    private let autoWrapText = "İstanbul, São Paulo, Málaga, Bogotá, über, façade, niño, ação, pingüino, こんにちは世界"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()

    private let defaultTitleLabel = FontMetricsSampleView.makeSectionLabel("Default UILabel line box")
    private let tightTitleLabel = FontMetricsSampleView.makeSectionLabel("Glyph-tight UILabel")

    private let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .label
        label.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.28)
        label.numberOfLines = 1
        label.adjustsFontForContentSizeCategory = false
        return label
    }()

    private let overlayView: FontMetricsOverlayView = {
        let view = FontMetricsOverlayView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }()

    private let tightSingleLabel = FontMetricsSampleView.makeTightLabel()
    private let tightMultilineLabel = FontMetricsSampleView.makeTightLabel()
    private let tightLanguageLabel = FontMetricsSampleView.makeTightLabel()
    private let tightAutoWrapLabel = FontMetricsSampleView.makeTightLabel()

    private lazy var tightSingleStackView = makeTightSampleStack(
        title: "single line",
        label: tightSingleLabel
    )

    private lazy var tightMultilineStackView = makeTightSampleStack(
        title: "explicit lines",
        label: tightMultilineLabel
    )

    private lazy var tightLanguageStackView = makeTightSampleStack(
        title: "diacritics + Japanese",
        label: tightLanguageLabel
    )

    private lazy var tightAutoWrapStackView = makeTightSampleStack(
        title: "auto wrap",
        label: tightAutoWrapLabel
    )

    private lazy var tightSamplesStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            tightSingleStackView,
            tightMultilineStackView,
            tightLanguageStackView,
            tightAutoWrapStackView,
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()

    private let metricsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        return stackView
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            defaultTitleLabel,
            defaultPreviewView,
            tightTitleLabel,
            tightSamplesStackView,
            metricsStackView,
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private lazy var defaultPreviewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        overlayView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(textLabel)
        view.addSubview(overlayView)

        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: Constants.defaultLabelHeight),
            textLabel.topAnchor.constraint(equalTo: view.topAnchor),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            overlayView.topAnchor.constraint(equalTo: textLabel.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: textLabel.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: textLabel.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor),
        ])

        return view
    }()

    private let font: UIFont

    init(title: String, fontName: String) {
        font = UIFont(name: fontName, size: Constants.fontSize) ?? .systemFont(ofSize: Constants.fontSize)
        super.init(frame: .zero)

        titleLabel.text = "\(title) · \(font.fontName)"
        configureView()
        configureSamples()
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

        addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
    }

    private func configureSamples() {
        textLabel.text = sampleText
        textLabel.font = font
        overlayView.label = textLabel

        tightSingleLabel.text = sampleText
        tightSingleLabel.font = font
        tightSingleLabel.numberOfLines = 1

        tightMultilineLabel.text = tightMultilineText
        tightMultilineLabel.font = font
        tightMultilineLabel.numberOfLines = 0

        tightLanguageLabel.text = languageText
        tightLanguageLabel.font = font
        tightLanguageLabel.numberOfLines = 0

        tightAutoWrapLabel.text = autoWrapText
        tightAutoWrapLabel.font = font
        tightAutoWrapLabel.numberOfLines = 0
    }

    private func configureMetrics() {
        let glyphBounds = FontMetricsCalculator.glyphUnionBounds(text: sampleText, font: font)
        let defaultBaselineY = Constants.defaultLabelHeight / 2 + (font.ascender + font.descender) / 2
        let singleMetrics = GlyphTightTextLayout.metrics(text: sampleText, font: font)
        let multilineMetrics = GlyphTightTextLayout.metrics(
            text: tightMultilineText,
            font: font,
            constrainedWidth: .greatestFiniteMagnitude,
            numberOfLines: 0
        )
        let languageMetrics = GlyphTightTextLayout.metrics(
            text: languageText,
            font: font,
            constrainedWidth: .greatestFiniteMagnitude,
            numberOfLines: 0
        )
        let autoWrapMetrics = GlyphTightTextLayout.metrics(
            text: autoWrapText,
            font: font,
            constrainedWidth: 280,
            numberOfLines: 0
        )

        addMetricGroup(
            title: "Font",
            rows: [
                ("pointSize", format(font.pointSize)),
                ("lineHeight", format(font.lineHeight)),
                ("ascender", format(font.ascender)),
                ("descender", format(font.descender)),
                ("capHeight", format(font.capHeight)),
                ("xHeight", format(font.xHeight)),
            ]
        )
        addMetricGroup(
            title: "Default UILabel",
            rows: [
                ("labelHeight", format(Constants.defaultLabelHeight)),
                ("baselineY", format(defaultBaselineY)),
                ("glyphBounds", format(glyphBounds)),
            ]
        )
        addMetricGroup(
            title: "Glyph-tight",
            rows: [
                ("singleHeight", format(singleMetrics.tightHeight)),
                ("explicitLines", "\(multilineMetrics.lines.count), \(format(multilineMetrics.tightHeight))"),
                ("languageLines", "\(languageMetrics.lines.count), \(format(languageMetrics.tightHeight))"),
                ("autoWrapLines", "\(autoWrapMetrics.lines.count), \(format(autoWrapMetrics.tightHeight))"),
                ("savedSpace", format(font.lineHeight - singleMetrics.tightHeight)),
            ]
        )
    }

    private func addMetricGroup(title: String, rows: [(String, String)]) {
        metricsStackView.addArrangedSubview(makeMetricHeader(title))
        for (name, value) in rows {
            metricsStackView.addArrangedSubview(makeMetricRow(title: name, value: value))
        }
    }

    private func makeMetricHeader(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .monospacedSystemFont(ofSize: 12, weight: .bold)
        label.textColor = .label
        return label
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

    private func makeTightSampleStack(title: String, label: GlyphTightLabel) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .monospacedSystemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [titleLabel, label])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 8
        return stackView
    }

    private static func makeSectionLabel(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .monospacedSystemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private static func makeTightLabel() -> GlyphTightLabel {
        let label = GlyphTightLabel()
        label.textAlignment = .center
        label.textColor = .label
        label.backgroundColor = UIColor.systemPink.withAlphaComponent(0.24)
        label.adjustsFontForContentSizeCategory = false
        label.showsDebugLineSeparators = true
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.borderColor = UIColor.systemPink.cgColor
        label.layer.borderWidth = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
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
