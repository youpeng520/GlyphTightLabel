//
//  ViewController.swift
//  GlyphTightLabelDemo
//

import GlyphTightLabel
import SnapKit
import UIKit

final class ViewController: UIViewController {
    private struct FontSample {
        let title: String
        let segmentTitle: String
        let fontName: String
    }

    private let fontSamples = [
        FontSample(title: "Thin", segmentTitle: "Thin", fontName: "Poppins-Thin"),
        FontSample(title: "ExtraLight", segmentTitle: "XL", fontName: "Poppins-ExtraLight"),
        FontSample(title: "Light", segmentTitle: "Light", fontName: "Poppins-Light"),
        FontSample(title: "Regular", segmentTitle: "Reg", fontName: "Poppins-Regular"),
        FontSample(title: "Medium", segmentTitle: "Med", fontName: "Poppins-Medium"),
        FontSample(title: "SemiBold", segmentTitle: "SB", fontName: "Poppins-SemiBold"),
        FontSample(title: "Bold", segmentTitle: "Bold", fontName: "Poppins-Bold"),
        FontSample(title: "ExtraBold", segmentTitle: "XB", fontName: "Poppins-ExtraBold"),
        FontSample(title: "Black", segmentTitle: "Black", fontName: "Poppins-Black"),
    ]

    private var selectedSampleIndex = 3

    private lazy var activeSampleView = makeSampleView(at: selectedSampleIndex)

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
        label.text = "黄色背景为默认 UILabel，粉色描边为 glyph bounds；粉色透明块为 Glyph-tight UILabel，红/蓝虚线为每行上下边界。"
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let segmentedControlScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: fontSamples.map(\.segmentTitle))
        control.selectedSegmentIndex = selectedSampleIndex
        control.addTarget(self, action: #selector(fontSegmentChanged(_:)), for: .valueChanged)
        return control
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            headingLabel,
            subtitleLabel,
            segmentedControlScrollView,
            activeSampleView,
        ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Poppins"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Demo",
            style: .plain,
            target: self,
            action: #selector(openGlyphTightDemo)
        )
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        segmentedControlScrollView.addSubview(segmentedControl)

        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.contentLayoutGuide).offset(20)
            make.leading.equalTo(scrollView.frameLayoutGuide).offset(20)
            make.trailing.equalTo(scrollView.frameLayoutGuide).offset(-20)
            make.bottom.equalTo(scrollView.contentLayoutGuide).offset(-24)
        }

        segmentedControlScrollView.snp.makeConstraints { make in
            make.height.equalTo(36)
        }

        segmentedControl.snp.makeConstraints { make in
            make.edges.equalTo(segmentedControlScrollView.contentLayoutGuide)
            make.centerY.equalTo(segmentedControlScrollView.frameLayoutGuide)
            make.width.greaterThanOrEqualTo(segmentedControlScrollView.frameLayoutGuide)
        }
    }

    @objc private func openGlyphTightDemo() {
        navigationController?.pushViewController(GlyphTightDemoViewController(), animated: true)
    }

    @objc private func fontSegmentChanged(_ sender: UISegmentedControl) {
        guard sender.selectedSegmentIndex != UISegmentedControl.noSegment else {
            return
        }

        selectedSampleIndex = sender.selectedSegmentIndex
        let newSampleView = makeSampleView(at: selectedSampleIndex)
        let currentIndex = stackView.arrangedSubviews.firstIndex(of: activeSampleView) ?? stackView.arrangedSubviews.count

        stackView.removeArrangedSubview(activeSampleView)
        activeSampleView.removeFromSuperview()
        stackView.insertArrangedSubview(newSampleView, at: currentIndex)
        activeSampleView = newSampleView
        scrollSelectedSegmentIntoView()
        view.layoutIfNeeded()
    }

    private func makeSampleView(at index: Int) -> FontMetricsSampleView {
        let sample = fontSamples[index]
        return FontMetricsSampleView(title: sample.title, fontName: sample.fontName)
    }

    private func scrollSelectedSegmentIntoView() {
        let segmentIndex = segmentedControl.selectedSegmentIndex
        guard segmentIndex != UISegmentedControl.noSegment else {
            return
        }

        let segmentWidth = segmentedControl.bounds.width / CGFloat(segmentedControl.numberOfSegments)
        let segmentFrame = CGRect(
            x: CGFloat(segmentIndex) * segmentWidth,
            y: 0,
            width: segmentWidth,
            height: segmentedControl.bounds.height
        )
        segmentedControlScrollView.scrollRectToVisible(segmentFrame.insetBy(dx: -12, dy: 0), animated: true)
    }
}
