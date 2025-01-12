import XCTest
import AXSnapshot

final class AccessibilityDescriptionSnapshotTests: XCTestCase {
    func testSnapshotOfView() throws {
        let viewUnderTest = ListItemView()
        viewUnderTest.leftText = "The answer is"
        viewUnderTest.rightText = "42"

        XCTAssert(viewUnderTest.exposedAccessibleViews().count == 1)
        XCTAssert(
            viewUnderTest.axSnapshot() == """
            ------------------------------------------------------------
            The answer is, 42
            button
            ------------------------------------------------------------
            """
        )
    }
    
    
    @available(iOS 13, *)
    func testSnapshotOfViewController() throws {
        let viewController = UIViewController()
        let scrollView = UIScrollView()
        viewController.view.addSubview(scrollView)
        
        let innerStackView = UIStackView()
        scrollView.addSubview(innerStackView)
        
        let header = ListItemView()
        header.accessibilityTraits = [.header, .button]
        header.leftText = "Final Result"
        header.accessibilityHint = "Double Tap to see detail result"
        header.accessibilityCustomActions = [UIAccessibilityCustomAction(name: "Retry", actionHandler: { _ in
            print("Retry!")
            return true
        })]
        
        let firstItem = ListItemView()
        firstItem.leftText = "The question is"
        firstItem.rightText = "The answer to the Life, the Universe, and Everything"
        
        let secondItem = ListItemView()
        secondItem.leftText = "The answer is"
        secondItem.rightText = "42"
        
        innerStackView.addArrangedSubview(header)
        innerStackView.addArrangedSubview(firstItem)
        innerStackView.addArrangedSubview(secondItem)
        
        XCTAssert(scrollView.exposedAccessibleViews().count == 3)
        XCTAssert(
            viewController.axSnapshot() == """
            ------------------------------------------------------------
            Final Result
            button, header
            Double Tap to see detail result
            Actions: Retry
            ------------------------------------------------------------
            The question is, The answer to the Life, the Universe, and Everything
            button
            ------------------------------------------------------------
            The answer is, 42
            button
            ------------------------------------------------------------
            """
        )
    }
    
    func testUnRespondableItem() throws {

        let childAccessibleElement = UIButton()
        childAccessibleElement.isAccessibilityElement = true
        childAccessibleElement.setTitle("Submit", for: .normal)
        
        let parentAccessibleElement = UIView()
        parentAccessibleElement.addSubview(childAccessibleElement)
        parentAccessibleElement.isAccessibilityElement = true
        parentAccessibleElement.accessibilityLabel = childAccessibleElement.accessibilityLabel
        
        XCTAssert(childAccessibleElement.exposedAccessibleViews().isEmpty)
        XCTAssert(
            childAccessibleElement.axSnapshot().isEmpty,
            "If Parent View is an accessibilityElement, child cannot be exposed to end user"
        )
    }
}

class ListItemView: UIView {
    var leftText = "" {
        didSet { leftLabel.text = leftText }
    }
    var rightText = "" {
        didSet { rightLabel.text = rightText }
    }
    
    private var stackView = UIStackView()
    var leftLabel = UILabel()
    var rightLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        
        stackView.addArrangedSubview(leftLabel)
        stackView.addArrangedSubview(rightLabel)
        
        self.isAccessibilityElement = true
        self.accessibilityTraits = [.button]
    }
    
    override var accessibilityLabel: String? {
        get { leftText }
        set { }
    }
    
    override var accessibilityValue: String? {
        get { rightText }
        set { }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
