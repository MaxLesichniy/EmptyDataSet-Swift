//
//  EmptyDataSetView.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 28/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import os.log

extension OSLog {
    static let emptyDataSet = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "", category: "EmptyDataSet")
}

open class EmptyDataSetView: PlatformView {
    
    public weak var dataSource: EmptyDataSetSource?
    public weak var delegate: EmptyDataSetDelegate?
    public var configure: ((EmptyDataSetView) -> Void)?
    public var verticalAlignment: VerticalAlignment = .center
    public var spacing: CGFloat = 11.0
    public var shouldDisplay: Bool = true
    public var state: EmptyDataSetViewState? {
        didSet {
            guard state != oldValue,
                  state != currentlyDisplayedState else { return }
            reload()
        }
    }
    
    public internal(set) lazy var contentView: PlatformStackView = {
        let contentView = PlatformStackView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS) || os(tvOS)
        contentView.axis = .vertical
        contentView.alignment = .center
        contentView.backgroundColor = .clear
        contentView.isUserInteractionEnabled = true
        contentView.layoutMargins = PlatformEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentView.isLayoutMarginsRelativeArrangement = true
        #else
        contentView.orientation = .vertical
        contentView.alignment = .centerX
        contentView.alphaValue = 0
        contentView.edgeInsets = EdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        #endif
        return contentView
    }()
    
    public internal(set) lazy var imageView: PlatformImageView = {
        let imageView = PlatformImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        #if os(iOS) || os(tvOS)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.accessibilityIdentifier = "empty set background image"
        #else
        imageView.imageScaling = .scaleProportionallyDown
        #endif
        return imageView
    }()
    
    public internal(set) lazy var titleLabel: PlatformLabel = {
        let titleLabel = PlatformLabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.font = .systemFont(ofSize: 27.0)
        titleLabel.textColor = .init(white: 0.6, alpha: 1.0)
        #if os(iOS) || os(tvOS)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
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
    
    public internal(set) lazy var detailLabel: PlatformLabel = {
        let detailLabel = PlatformLabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.font = .systemFont(ofSize: 17.0)
        detailLabel.textColor = .init(white: 0.6, alpha: 1.0)
        #if os(iOS) || os(tvOS)
        detailLabel.textAlignment = .center
        detailLabel.numberOfLines = 5
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
    
    public internal(set) lazy var button: PlatformButton = { [unowned self] in
        let button: PlatformButton
        let contentEdgeInsets = PlatformEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        #if os(iOS) || os(tvOS)
        button = UIButton(type: .custom)
        button.contentEdgeInsets = contentEdgeInsets
        button.accessibilityIdentifier = "empty set button"
        button.addTarget(self, action: #selector(didTapDataButtonHandler(_:)), for: .touchUpInside)
//        #if os(iOS)
//        if #available(iOS 15, macCatalyst 15, *) {
//            button.preferredBehavioralStyle = .pad
//        }
//        #endif
        #else
        button = NSButton()
        button.target = self
        button.action = #selector(didTapDataButtonHandler(_:))
        #endif
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    open var textColor: PlatformColor? {
        didSet {
            titleLabel.textColor = textColor
            detailLabel.textColor = textColor
        }
    }
    
    #if os(iOS) || os(tvOS)
    open internal(set) lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapContentViewHandler(_:)))
    #endif

    internal var currentlyDisplayedState: EmptyDataSetViewState?
    
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
        #if os(iOS) || os(tvOS)
        if let attributedTitle = button.attributedTitle(for: .normal) {
            return attributedTitle.length > 0
        } else if let title = button.title(for: .normal) {
            return !title.isEmpty
        } else if let _ = button.image(for: .normal) {
            return true
        }
        return false
        #else
        return button.attributedTitle.length > 0 || button.image != nil
        #endif
    }
    
    internal var customView: PlatformView? {
        didSet {
            guard oldValue !== customView else { return }
            oldValue?.removeFromSuperview()
            if let customView = customView {
                customView.translatesAutoresizingMaskIntoConstraints = false
                self.addSubview(customView)
            }
        }
    }
    
    internal var verticalOffset: CGFloat = 0
    internal var didTapContentViewHandle: (() -> Void)?
    internal var didTapDataButtonHandle: (() -> Void)?
    internal var willAppearHandle: (() -> Void)?
    internal var didAppearHandle: (() -> Void)?
    internal var willDisappearHandle: (() -> Void)?
    internal var didDisappearHandle: (() -> Void)?
    internal var needsReloadWithItemsCount: Int?
    
    private var originalIsScrollEnabled: Bool = true
    private var _constraints: [NSLayoutConstraint] = []
    private var additionalButtons: [PlatformButton]?
    
    // MARK: - Init
    
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

        #if os(iOS) || os(tvOS)
        addGestureRecognizer(tapGestureRecognizer)
        #endif
    }
    
    #if os(iOS) || os(tvOS)
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
//        if let superviewBounds = superview?.bounds {
//            frame = CGRect(x: 0, y: 0, width: superviewBounds.width, height: superviewBounds.height)
//        }
        
//        if fadeInOnDisplay {
//            UIView.animate(withDuration: 0.25) {
//                self.contentView.alpha = 1
//            }
//        } else {
//            contentView.alpha = 1
//        }
    }
    #else
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
//        if fadeInOnDisplay {
//            // TODO: set duration
//            contentView.animator().alphaValue = 1
//        } else {
//            contentView.alphaValue = 1
//        }
    }
    #endif
    
    public func setDetailLabel(_ label: PlatformLabel) {
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
        setupTitleLabel(with: nil)
        setupDetailsLabel(with: nil)
        setupImageView(with: nil)
        
        #if os(iOS) || os(tvOS)
        removeAdditionalButtons()
        
        let buttonStates: [UIControl.State] = [.highlighted, .normal]
        buttonStates.forEach {
            buttonTitle(nil, for: $0)
            buttonImage(nil, for: $0)
        }
        #endif

        button.isHidden = true
        customView = nil
        currentlyDisplayedState = nil
    }
    
    #if os(iOS) || os(tvOS)
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if let itemsCount = needsReloadWithItemsCount {
            performReload(with: itemsCount)
        }
    }
    #else
    open override func layout() {
        super.layout()
        
        if let itemsCount = needsReloadWithItemsCount {
            performReload(with: itemsCount)
        }
    }
    #endif
    
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
        
        let centerXConstraint = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal,
                                                   toItem: item, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: view, attribute: verticalAlignment.layoutConstraintAttribute, relatedBy: .equal,
                                                   toItem: item, attribute: verticalAlignment.layoutConstraintAttribute, multiplier: 1.0, constant: verticalOffset)

        _constraints.append(contentsOf: [centerXConstraint, centerYConstraint])
        _constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: ["contentView": view]))
                
        self.addConstraints(_constraints)
    }
    
    // MARK: - Delegate Getters & Events (Private)
    
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
    
    @objc private func didTapDataButtonHandler(_ sender: PlatformButton) {
        delegate?.emptyDataSet(self, didTapButton: sender)
        currentlyDisplayedState?.buttonHandler?()
        didTapDataButtonHandle?()
    }
    
    #if os(iOS) || os(tvOS)
    @objc private func didTapContentViewHandler(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        delegate?.emptyDataSet(self, didTapView: view)
        didTapContentViewHandle?()
    }
    #endif
    
    // MARK: - Reload APIs (Public)
    public func reload(with itemsCount: Int = 0) {
//        os_log(.debug, log: .emptyDataSet, "Need reload with items: \(itemsCount)")
        needsReloadWithItemsCount = itemsCount
        #if os(iOS) || os(tvOS)
        setNeedsLayout()
        #else
        needsLayout = true
        #endif
    }
    
    @available(*, deprecated, renamed: "reload(with:)")
    public func reloadEmptyDataSet(itemsCount: Int = 0) {
        performReload(with: itemsCount)
    }
    
    func performReload(with itemsCount: Int = 0) {
//        os_log(.debug, log: .emptyDataSet, "Perform reload with items: \(itemsCount)")
        
        let state = self.state ?? makeStateFromDataSource()
        let customView = self.dataSource?.customView(self)
        let shouldDisplay = itemsCount == 0 && self.delegate?.emptyDataSetShouldDisplay(self, with: state) ?? self.shouldDisplay
        
        if (state == nil && customView == nil) || shouldDisplay == false {
            invalidateIfNedded()
            return
        }
        
        // Removing view resetting the view and its constraints it very important to guarantee a good state
        // If a non-nil custom view is available, let's configure it instead
        prepareForReuse()
        
        // Notifies that the empty dataset view will appear
        willAppear()
        
        if let customView = customView {
            self.contentView.isHidden = true
            self.customView = customView
        } else {
            self.contentView.isHidden = false
                            
            contentView.spacing = dataSource?.verticalSpacing(self) ?? spacing
            
            setup(with: state)
            
            #if os(iOS)
            if let image = dataSource?.buttonImage(self, for: .normal) {
                buttonImage(image, for: .normal)
                buttonImage(dataSource?.buttonImage(self, for: .highlighted), for: .highlighted)
            }
            #endif
        }
        
        verticalOffset = dataSource?.verticalOffset(self) ?? 0
        
        isHidden = false
        
        #if os(iOS)
        // Configure the empty dataset view
        clipsToBounds = true

        // Configure scroll permission
        if let scrollView = superview as? UIScrollView {
            originalIsScrollEnabled = scrollView.isScrollEnabled
            scrollView.isScrollEnabled = delegate?.emptyDataSetShouldAllowScroll(self) ?? false
        }
        #endif
        
        needsReloadWithItemsCount = nil

        configure?(self)
        
        setNeedsUpdateConstraints()
        
        // Notifies that the empty dataset view did appear
        didAppear()
    }
    
    // MARK: -
    
//    public func reloadEmptyDataSet(with state: EmptyDataSetViewState?, addionalConfiguration: ((Self) -> Void)?) {
//        
//    }
    
    func setup(with state: EmptyDataSetViewState?) {
        let attributedTitle = state?.attributedTitle ?? state?.title.map { NSAttributedString(string: $0) }
        let attributedDetails = state?.attributedDetails ?? state?.details.map { NSAttributedString(string: $0) }
        setupTitleLabel(with: attributedTitle)
        setupDetailsLabel(with: attributedDetails)
        setupImageView(with: state?.image)
        #if os(iOS)
        setupButtonTitle(with: state?.buttonTitle, for: .normal)
        setupAdditionalButtons(with: state?.additionalButtons)
        #endif
        
        currentlyDisplayedState = state
    }
    
    func setupTitleLabel(with attributedText: NSAttributedString?) {
        titleLabel.attributedText = attributedText
        titleLabel.isHidden = !canShowTitle
    }
    
    func setupDetailsLabel(with attributedText: NSAttributedString?) {
        detailLabel.attributedText = attributedText
        detailLabel.isHidden = !canShowDetail
    }

    func setupImageView(with image: PlatformImage?) {
        imageView.image = image
        imageView.isHidden = !canShowImage
    }

    #if os(iOS) || os(tvOS)
    func setupButtonTitle(with buttonTitle: String?, for state: UIControl.State) {
        button.setTitle(buttonTitle, for: state)
        button.isHidden = !canShowButton
    }
    
    func setupButtonTitle(with buttonTitle: NSAttributedString?, for state: UIControl.State) {
        button.setAttributedTitle(buttonTitle, for: state)
        button.isHidden = !canShowButton
    }
    
    func setupAdditionalButtons(with buttons: [PlatformButton]?) {
        if let buttons, let index = contentView.arrangedSubviews.firstIndex(of: button) {
            for b in buttons.reversed() {
                contentView.insertArrangedSubview(b, at: index + 1)
            }
        }
        self.additionalButtons = buttons
    }
    
    func removeAdditionalButtons() {
        if let additionalButtons {
            for b in additionalButtons {
                contentView.removeArrangedSubview(b)
                b.removeFromSuperview()
            }
        }
    }
    #endif
    
    func makeStateFromDataSource() -> EmptyDataSetViewState? {
        guard let dataSource = self.dataSource else { return nil }
        if let stateFromDataSource = dataSource.emptyDataSetViewState(self) {
            return stateFromDataSource
        }
        var state = EmptyDataSetViewState()
        state.attributedTitle = dataSource.title(self)
        state.attributedDetails = dataSource.description(self)
        state.image = dataSource.image(self)
        #if os(iOS) || os(tvOS)
        state.buttonTitle = dataSource.buttonTitle(self, for: .normal)?.string
        #endif
        return state
    }
    
    public func setNeedsUpdateVerticalOffset() {
        let oldOffset = verticalOffset
        verticalOffset = dataSource?.verticalOffset(self) ?? 0
        if verticalOffset != oldOffset {
            setNeedsUpdateConstraints()
        }
    }
    
    func invalidateIfNedded() {
        if !isHidden {
            invalidate()
        }
    }
    
    public func invalidate() {
        willDisappear()
        prepareForReuse()
        currentlyDisplayedState = nil
        isHidden = true
        #if os(iOS) || os(tvOS)
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
