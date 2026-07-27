//
//  GlyphTightDemoViewController.swift
//  UIKitExample
//
//  Created by Sun on 2026/6/4.
//

import SnapKit
import UIKit

/// `GlyphTightLabel` 用法示例：单行、多行与文字渐变色。
final class GlyphTightDemoViewController: UIViewController {
    private let demoFont = UIFont(name: "Poppins-Regular", size: 24) ?? .systemFont(ofSize: 24, weight: .regular)

    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        return view
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.spacing = 20
        return view
    }()

    private let singleLineTitleLabel = GlyphTightDemoViewController.makeSectionTitle("单行文本")

    private lazy var singleLineLabel: GlyphTightLabel = {
        let label = GlyphTightLabel()
        label.text = "Agjpqy Çãñá"
        label.font = demoFont
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = UIColor.systemPink.withAlphaComponent(0.2)
        label.showsDebugLineSeparators = false
        label.verticalPadding = 2
        return label
    }()

    private let multiLineTitleLabel = GlyphTightDemoViewController.makeSectionTitle("多行文本与调试边界线")

    private lazy var multiLineLabel: GlyphTightLabel = {
        let label = GlyphTightLabel()
        label.text = "Your BMI is slightly above the recommended range."
        label.font = demoFont
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = UIColor.systemPink.withAlphaComponent(0.2)
        label.showsDebugLineSeparators = true
        label.lineSpacing = 6
        label.verticalPadding = 2
        return label
    }()

    private let gradientTitleLabel = GlyphTightDemoViewController.makeSectionTitle("文字渐变 (Gradient Text)")

    private lazy var gradientSingleLineLabel: GlyphTightLabel = {
        let label = GlyphTightLabel()
        label.text = "Gradient GlyphTightLabel"
        label.font = demoFont
        label.textAlignment = .center
        label.numberOfLines = 1
        label.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
        label.verticalPadding = 4
        label.gradientColors = [
            UIColor.systemBlue,
            UIColor.systemPurple,
            UIColor.systemPink
        ]
        label.gradientStartPoint = CGPoint(x: 0, y: 0.5)
        label.gradientEndPoint = CGPoint(x: 1, y: 0.5)
        label.showsDebugLineSeparators = true
        return label
    }()

    private lazy var gradientMultiLineLabel: GlyphTightLabel = {
        let label = GlyphTightLabel()
        label.text = "Tight typography with multi-color gradient text Tight typography with multi-color gradient text renderin rendering."
        label.font = demoFont
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
        label.lineSpacing = 0
        label.verticalPadding = 0
        label.gradientColors = [
            UIColor.systemOrange,
            UIColor.systemRed,
            UIColor.systemPurple
        ]
        label.showsDebugLineSeparators = false
        label.gradientStartPoint = CGPoint(x: 0, y: 0.5)
        label.gradientEndPoint = CGPoint(x: 1, y: 0.5)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "GlyphTightLabel Demo"
        view.backgroundColor = .systemBackground

        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        stackView.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView.contentLayoutGuide).inset(20)
            make.leading.trailing.equalTo(scrollView.frameLayoutGuide).inset(20)
        }

        stackView.addArrangedSubview(singleLineTitleLabel)
        stackView.addArrangedSubview(singleLineLabel)
        stackView.addArrangedSubview(multiLineTitleLabel)
        stackView.addArrangedSubview(multiLineLabel)
        stackView.addArrangedSubview(gradientTitleLabel)
        stackView.addArrangedSubview(gradientSingleLineLabel)
        stackView.addArrangedSubview(gradientMultiLineLabel)
    }

    private static func makeSectionTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        return label
    }
}
