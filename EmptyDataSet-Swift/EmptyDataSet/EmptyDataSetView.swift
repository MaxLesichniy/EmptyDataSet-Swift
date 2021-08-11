//
//  EmptyDataSetView.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 28/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation

public protocol EmptyDataSetState: Hashable {
    
}

public struct EmptyDataSetStateConfiguration {
    var title: String?
    var attributedTitle: NSAttributedString?
    var details: String?
    var attributedDetails: NSAttributedString?
    var image: Image?
    
    init(_ base: EmptyDataSetStateConfiguration) {
        self.title = base.title
        self.attributedTitle = base.attributedTitle
        self.details = base.details
        self.attributedDetails = base.attributedDetails
        self.image = base.image
    }
}

open class EmptyDataSetView: View {
    
    public weak var dataSource: EmptyDataSetSource?
    public weak var delegate: EmptyDataSetDelegate?
    public var configure: ((EmptyDataSetView) -> Void)?
    public var verticalAlignment: VerticalAlignment = .center
    
    public internal(set) lazy var contentView: StackView = {
        let contentView = StackView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS)
        contentView.axis = .vertical
        contentView.alignment = .center
        contentView.backgroundColor = .clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0
        contentView.layoutMargins = EdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentView.isLayoutMarginsRelativeArrangement = true
        #else
        contentView.orientation = .vertical
        contentView.alignment = .centerX
        contentView.alphaValue = 0
        contentView.edgeInsets = EdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        #endif
        return contentView
    }()
    
    public internal(set) lazy var imageView: ImageView = {
        let imageView = ImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "empty set background image"
        #else
        imageView.imageScaling = .scaleProportionallyDown
        #endif
        return imageView
    }()
    
    public internal(set) lazy var titleLabel: Label = {
        let titleLabel = Label()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = .systemFont(ofSize: 27.0)
        titleLabel.textColor = .init(white: 0.6, alpha: 1.0)
        #if os(iOS)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityIdentifier = "empty set title"
        #else
        titleLabel.alignment = .center
        titleLabel.maximumNumberOfLines = 0
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.drawsBackground = false
        #endif
        return titleLabel
    }()
    
    public internal(set) lazy var detailLabel: Label = {
        let detailLabel = Label()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.font = .systemFont(ofSize: 17.0)
        detailLabel.textColor = .init(white: 0.6, alpha: 1.0)
        #if os(iOS)
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 0
        detailLabel.accessibilityIdentifier = "empty set detail label"
        #else
        detailLabel.alignment = .center
        detailLabel.maximumNumberOfLines = 0
        detailLabel.isEditable = false
        detailLabel.isBordered = false
        detailLabel.drawsBackground = false
        #endif
        return detailLabel
    }()
    
    public internal(set) lazy var button: Button = { [unowned self] in
        let button: Button
        let contentEdgeInsets = EdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        #if os(iOS)
        button = UIButton(type: .custom)
        button.contentEdgeInsets = contentEdgeInsets
        button.accessibilityIdentifier = "empty set button"
        button.addTarget(self, action: #selector(didTapDataButtonHandler(_:)), for: .touchUpInside)
        #else
        button = NSButton()
        button.target = self
        button.action = #selector(didTapDataButtonHandler(_:))
        #endif
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    internal var canShowImage: Bool {
        return imageView.image != nil
    }
    
    internal var canShowTitle: Bool {
        if let attributedText = titleLabel.attributedText {
            return attributedText.length > 0
        }
        return false
    }
    
    internal var canShowDetail: Bool {
        if let attributedText = detailLabel.attributedText {
            return attributedText.length > 0
        }
        return false
    }
    
    internal var canShowButton: Bool {
        #if os(iOS)
        if let attributedTitle = button.attributedTitle(for: .normal) {
            return attributedTitle.length > 0
        } else if let _ = button.image(for: .normal) {
            return true
        }
        return false
        #else
        return button.attributedTitle.length > 0 || button.image != nil
        #endif
    }
    
    internal var customView: View? {
        willSet {
            if let customView = customView {
                customView.removeFromSuperview()
            }
        }
        didSet {
            if let customView = customView {
                customView.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(customView)
            }
        }
    }
    
    internal var fadeInOnDisplay = false
    internal var verticalOffset: CGFloat = 0
    
    internal var didTapContentViewHandle: (() -> Void)?
    internal var didTapDataButtonHandle: (() -> Void)?
    internal var willAppearHandle: (() -> Void)?
    internal var didAppearHandle: (() -> Void)?
    internal var willDisappearHandle: (() -> Void)?
    internal var didDisappearHandle: (() -> Void)?
    
    private var _constraints: [NSLayoutConstraint] = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(contentView)
        contentView.addArrangedSubview(imageView)
        contentView.addArrangedSubview(titleLabel)
        contentView.addArrangedSubview(detailLabel)
        contentView.addArrangedSubview(button)

        #if os(iOS)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapContentViewHandler(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        #endif
    }
    
    #if os(iOS)
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
//        if let superviewBounds = superview?.bounds {
//            frame = CGRect(x: 0, y: 0, width: superviewBounds.width, height: superviewBounds.height)
//        }
        
        if fadeInOnDisplay {
            UIView.animate(withDuration: 0.25) {
                self.contentView.alpha = 1
            }
        } else {
            contentView.alpha = 1
        }
    }
    #else
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if fadeInOnDisplay {
            // TODO: set duration
            contentView.animator().alphaValue = 1
        } else {
            contentView.alphaValue = 1
        }
    }
    #endif
    
    public func setDetailLabel(_ label: Label) {
        // FIXME: contentView.addArrangedSubview(detailLabel)
        self.detailLabel = label
        self.contentView.addSubview(label)
    }
    
    // MARK: - Action Methods
    
    #if os(macOS)
    open override func prepareForReuse() {
        super.prepareForReuse()
        _prepareForReuse()
    }
    #else
    func prepareForReuse() {
        _prepareForReuse()
    }
    #endif
    
    func _prepareForReuse() {
        titleLabelString(nil)
        detailLabelString(nil)
        image(nil)
        
        #if canImport(UIKit)
        let buttonStates: [UIControl.State] = [.highlighted, .normal]
        buttonStates.forEach {
            buttonTitle(nil, for: $0)
            buttonImage(nil, for: $0)
            buttonBackgroundImage(nil, for: $0)
        }
        #endif

        button.isHidden = true
        customView = nil
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        
        self.removeConstraints(_constraints)
        _constraints.removeAll()
        
        let view = customView ?? contentView
        
        // First, configure the content view constaints
        // The content view must alway be centered to its superview
        let item: Any
        
        if #available(iOS 11, macOS 11.0, *) {
            item = self.layoutMarginsGuide
        } else {
            item = self
        }
        
        let centerXConstraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: item, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: view, attribute: verticalAlignment.layoutConstraintAttribute, relatedBy: .equal, toItem: item, attribute: verticalAlignment.layoutConstraintAttribute, multiplier: 1.0, constant: 0.0) // setup verticalOffset

        _constraints.append(contentsOf: [centerXConstraint, centerYConstraint])
        _constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: ["contentView": view]))
        
        // TODO: delete this code block
        // When a custom offset is available, we adjust the vertical constraints' constants
        if (verticalOffset != 0 && _constraints.count > 0) {
            centerYConstraint.constant = verticalOffset
        }
        
        
        self.addConstraints(_constraints)
    }
    
    //MARK: - Delegate Getters & Events (Private)
    
    private var shouldFadeIn: Bool {
        return delegate?.emptyDataSetShouldFadeIn(self) ?? true
    }
    
    private var shouldDisplay: Bool {
        return delegate?.emptyDataSetShouldDisplay(self) ?? true
    }
    
    private var shouldBeForcedToDisplay: Bool {
        return delegate?.emptyDataSetShouldBeForcedToDisplay(self) ?? false
    }
    
    private var isTouchAllowed: Bool {
        return delegate?.emptyDataSetShouldAllowTouch(self) ?? true
    }
    
    private var isScrollAllowed: Bool {
        return delegate?.emptyDataSetShouldAllowScroll(self) ?? false
    }
    
    private var isImageViewAnimateAllowed: Bool {
        return delegate?.emptyDataSetShouldAnimateImageView(self) ?? false
    }
    
    private func willAppear() {
        delegate?.emptyDataSetWillAppear(self)
        willAppearHandle?()
    }
    
    private func didAppear() {
        delegate?.emptyDataSetDidAppear(self)
        didAppearHandle?()
    }
    
    private func willDisappear() {
        delegate?.emptyDataSetWillDisappear(self)
        willDisappearHandle?()
    }
    
    private func didDisappear() {
        delegate?.emptyDataSetDidDisappear(self)
        didDisappearHandle?()
    }
    
    @objc private func didTapDataButtonHandler(_ sender: Button) {
        delegate?.emptyDataSet(self, didTapButton: sender)
        didTapDataButtonHandle?()
    }
    
    #if os(iOS)
    @objc private func didTapContentViewHandler(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        delegate?.emptyDataSet(self, didTapView: view)
        didTapContentViewHandle?()
    }
    #endif
    
    //MARK: - Reload APIs (Public)
    public func reloadEmptyDataSet(itemsCount: Int = 0) {
        guard let dataSource = self.dataSource else {
            invalidateIfNedded()
            return
        }
        
        guard (shouldDisplay && itemsCount == 0) || shouldBeForcedToDisplay else {
            invalidateIfNedded()
            return
        }
        
        // Notifies that the empty dataset view will appear
        willAppear()
        
        // Configure empty dataset fade in display
        fadeInOnDisplay = shouldFadeIn
        
        // Removing view resetting the view and its constraints it very important to guarantee a good state
        // If a non-nil custom view is available, let's configure it instead
        prepareForReuse()
        
        if let customView = dataSource.customView(self) {
            self.contentView.isHidden = true
            self.customView = customView
        } else {
            self.contentView.isHidden = false
                            
            contentView.spacing = dataSource.verticalSpacing(self)
            // Configure offset
            verticalOffset = dataSource.verticalOffset(self)
            
            // Configure Image
            image(dataSource.image(self))
            imageTintColor(dataSource.imageTintColor(self))
            // Configure title label
            titleLabelString(dataSource.title(self))
            // Configure detail label
            detailLabelString(dataSource.description(self))
            // Configure button
            #if os(iOS)
            if let image = dataSource.buttonImage(self, for: .normal) {
                buttonImage(image, for: .normal)
                buttonImage(dataSource.buttonImage(self, for: .highlighted), for: .highlighted)
            } else if let title = dataSource.buttonTitle(self, for: .normal) {
                buttonTitle(title, for: .normal)
                buttonTitle(dataSource.buttonTitle(self, for: .highlighted), for: .highlighted)
                buttonBackgroundImage(dataSource.buttonBackgroundImage(self, for: .normal), for: .normal)
                buttonBackgroundImage(dataSource.buttonBackgroundImage(self, for: .highlighted), for: .highlighted)
            }
            #endif
        }
        
        isHidden = false
        
        #if os(iOS)
        // Configure the empty dataset view
        backgroundColor = dataSource.backgroundColor(self)
        clipsToBounds = true
        
        // Configure empty dataset userInteraction permission
        isUserInteractionEnabled = isTouchAllowed
        
        // Configure scroll permission
        if let scrollView = superview as? UIScrollView {
            scrollView.isScrollEnabled = isScrollAllowed
        }
        
        // Configure image view animation
        if self.isImageViewAnimateAllowed {
            if let animation = dataSource.imageAnimation(self) {
                imageView.layer.add(animation, forKey: nil)
            }
        } else {
            imageView.layer.removeAllAnimations()
        }
        #endif
        
        configure?(self)
        
        setNeedsUpdateConstraints()
        
        // Notifies that the empty dataset view did appear
        didAppear()
    }
    
    internal func invalidateIfNedded() {
        if !isHidden {
            invalidate()
        }
    }
    
    internal func invalidate() {
        willDisappear()
        prepareForReuse()
        isHidden = true
        #if os(iOS)
        if let scrollView = superview as? UIScrollView {
            scrollView.isScrollEnabled = true
        }
        #endif
        didDisappear()
    }
    
}

extension EmptyDataSetView {
    
    public enum VerticalAlignment: Int {
        case top
        case center
        case bottom
        
        var layoutConstraintAttribute: NSLayoutConstraint.Attribute {
            switch self {
            case .top:
                return .top
            case .center:
                return .centerY
            case .bottom:
                return .bottom
            }
        }
    }
    
}
