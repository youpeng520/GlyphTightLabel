//
//  GlyphTightDemoViewController.swift
//  UIKitExample
//
//  Created by Sun on 2026/6/4.
//

import SnapKit
import UIKit

/// `GlyphTightLabel` 最小用法示例：单行与多行。
final class GlyphTightDemoViewController: UIViewController {
    private let demoFont = UIFont(name: "Poppins-Regular", size: 28) ?? .systemFont(ofSize: 28, weight: .regular)

    private let singleLineTitleLabel = GlyphTightDemoViewController.makeSectionTitle("单行")

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

    private let multiLineTitleLabel = GlyphTightDemoViewController.makeSectionTitle("多行")

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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "GlyphTightLabel"
        view.backgroundColor = .systemBackground

        view.addSubview(singleLineTitleLabel)
        view.addSubview(singleLineLabel)
        view.addSubview(multiLineTitleLabel)
        view.addSubview(multiLineLabel)

        singleLineTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        singleLineLabel.snp.makeConstraints { make in
            make.top.equalTo(singleLineTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        multiLineTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(singleLineLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        multiLineLabel.snp.makeConstraints { make in
            make.top.equalTo(multiLineTitleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(34)
        }
    }

    private static func makeSectionTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        return label
    }
}
