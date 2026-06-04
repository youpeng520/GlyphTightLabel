import GlyphTightLabel
import UIKit

/// `GlyphTightLabel` 最小用法示例：单行与多行。
final class DemoViewController: UIViewController {
    private let demoFont = UIFont.systemFont(ofSize: 28, weight: .regular)

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let singleLineTitleLabel = DemoViewController.makeSectionTitle("单行")

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

    private let multiLineTitleLabel = DemoViewController.makeSectionTitle("多行")

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

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        [
            singleLineTitleLabel,
            singleLineLabel,
            multiLineTitleLabel,
            multiLineLabel,
        ].forEach(contentStack.addArrangedSubview)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48),
        ])
    }

    private static func makeSectionTitle(_ title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        label.textColor = .secondaryLabel
        return label
    }
}
