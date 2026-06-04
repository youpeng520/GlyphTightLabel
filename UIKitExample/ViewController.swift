//
//  ViewController.swift
//  UIKitExample
//
//  Created by Sun on 2026/6/4.
//

import UIKit

final class ViewController: UIViewController {
    private struct FontSample {
        let title: String
        let fontName: String
    }

    private let fontSamples = [
        FontSample(title: "Thin", fontName: "Poppins-Thin"),
        FontSample(title: "ExtraLight", fontName: "Poppins-ExtraLight"),
        FontSample(title: "Light", fontName: "Poppins-Light"),
        FontSample(title: "Regular", fontName: "Poppins-Regular"),
        FontSample(title: "Medium", fontName: "Poppins-Medium"),
        FontSample(title: "SemiBold", fontName: "Poppins-SemiBold"),
        FontSample(title: "Bold", fontName: "Poppins-Bold"),
        FontSample(title: "ExtraBold", fontName: "Poppins-ExtraBold"),
        FontSample(title: "Black", fontName: "Poppins-Black"),
    ]

    private let headingLabel: UILabel = {
        let label = UILabel()
        label.text = "Poppins UILabel Metrics"
        label.font = .preferredFont(forTextStyle: .title2)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "粉色框为 glyph bounds，青色边框为视觉贴边的 Glyph-tight UILabel。"
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let sampleViews = fontSamples.map { sample in
            FontMetricsSampleView(title: sample.title, fontName: sample.fontName)
        }
        let stackView = UIStackView(arrangedSubviews: [headingLabel, subtitleLabel] + sampleViews)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Poppins"
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
        ])

        stackView.arrangedSubviews.compactMap { $0 as? FontMetricsSampleView }.forEach { sampleView in
            sampleView.heightAnchor.constraint(equalToConstant: 440).isActive = true
        }
    }
}
