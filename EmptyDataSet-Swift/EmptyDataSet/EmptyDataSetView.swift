//
//  EmptyDataSetView.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 28/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
import UIKit

open class EmptyDataSetView: UIView {
    
    public weak var dataSource: EmptyDataSetSource?
    public weak var delegate: EmptyDataSetDelegate?
    public var configure: ((EmptyDataSetView) -> Void)?
    
    internal lazy var contentView: UIStackView = {
        let contentView = UIStackView()
        contentView.axis = .vertical
        contentView.alignment = .center
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        contentView.isUserInteractionEnabled = true
        contentView.alpha = 0
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentView.isLayoutMarginsRelativeArrangement = true
        return contentView
    }()
    
    public internal(set) lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        imageView.accessibilityIdentifier = "empty set background image"
        return imageView
    }()
    
    public internal(set) lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.backgroundColor = UIColor.clear
        
        titleLabel.font = UIFont.systemFont(ofSize: 27.0)
        titleLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.numberOfLines = 0
        titleLabel.accessibilityIdentifier = "empty set title"
        return titleLabel
    }()
    
    public internal(set) lazy var detailLabel: UILabel = {
        let detailLabel = UILabel()
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.backgroundColor = UIColor.clear
        
        detailLabel.font = UIFont.systemFont(ofSize: 17.0)
        detailLabel.textColor = UIColor(white: 0.6, alpha: 1.0)
        detailLabel.textAlignment = .center
        detailLabel.lineBreakMode = .byWordWrapping
        detailLabel.numberOfLines = 0
        detailLabel.accessibilityIdentifier = "empty set detail label"
        return detailLabel
    }()
    
    public internal(set) lazy var button: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.accessibilityIdentifier = "empty set button"
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapDataButtonHandler(_:)), for: .touchUpInside)
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
        if let attributedTitle = button.attributedTitle(for: .normal) {
            return attributedTitle.length > 0
        } else if let _ = button.image(for: .normal) {
            return true
        }
        
        return false
    }
    
    internal var customView: UIView? {
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

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapContentViewHandler(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    override open func didMoveToSuperview() {
        if let superviewBounds = superview?.bounds {
            frame = CGRect(x: 0, y: 0, width: superviewBounds.width, height: superviewBounds.height)
        }
        if fadeInOnDisplay {
            UIView.animate(withDuration: 0.25) {
                self.contentView.alpha = 1
            }
        } else {
            contentView.alpha = 1
        }
    }
    
    public func setDetailLabel(_ label: UILabel) {
        self.detailLabel = label
        self.contentView.addSubview(label)
    }
    
    // MARK: - Action Methods
    
    internal func prepareForReuse() {
        titleLabelString(nil)
        detailLabelString(nil)
        image(nil)
        
        let buttonStates: [UIControl.State] = [.highlighted, .normal]
        buttonStates.forEach {
            buttonTitle(nil, for: $0)
            buttonImage(nil, for: $0)
            buttonBackgroundImage(nil, for: $0)
        }

        button.isHidden = true
        
        customView = nil
    }
    
    open override func updateConstraints() {
        super.updateConstraints()
        
        self.removeConstraints(_constraints)
        _constraints.removeAll()
        
        if let customView = customView {
            let centerXConstraint = NSLayoutConstraint(item: customView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let centerYConstraint = NSLayoutConstraint(item: customView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            
            let customViewHeight = customView.frame.height
            let customViewWidth = customView.frame.width
            
            let heightConstarint: NSLayoutConstraint
            
            if (customViewHeight == 0) {
                heightConstarint = NSLayoutConstraint(item: customView, attribute: .height, relatedBy: .lessThanOrEqual, toItem: self, attribute: .height, multiplier: 1, constant: 0.0)
            } else {
                heightConstarint = NSLayoutConstraint(item: customView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: customViewHeight)
            }
            
            let widthConstarint: NSLayoutConstraint

            if (customViewWidth == 0) {
                widthConstarint = NSLayoutConstraint(item: customView, attribute: .width, relatedBy: .lessThanOrEqual, toItem: self, attribute: .width, multiplier: 1, constant: 0.0)
            } else {
                widthConstarint = NSLayoutConstraint(item: customView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: customViewWidth)
            }
            
            // When a custom offset is available, we adjust the vertical constraints' constants
            if (verticalOffset != 0) {
                centerYConstraint.constant = verticalOffset
            }
            
            _constraints.append(contentsOf: [centerXConstraint, centerYConstraint])
            _constraints.append(contentsOf: [heightConstarint, widthConstarint])
            
        } else {
            // First, configure the content view constaints
            // The content view must alway be centered to its superview
            let item: Any
            
            if #available(iOS 11, *) {
                item = self.safeAreaLayoutGuide
            } else {
                item = self
            }
            
            let centerXConstraint = NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: item, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let centerYConstraint = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: item, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            
            _constraints.append(contentsOf: [centerXConstraint, centerYConstraint])
            _constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: ["contentView": contentView]))
            
            // When a custom offset is available, we adjust the vertical constraints' constants
            if (verticalOffset != 0 && _constraints.count > 0) {
                centerYConstraint.constant = verticalOffset
            }
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
    
    @objc private func didTapDataButtonHandler(_ sender: UIButton) {
        delegate?.emptyDataSet(self, didTapButton: sender)
        didTapDataButtonHandle?()
    }
    
    
    @objc private func didTapContentViewHandler(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view else { return }
        delegate?.emptyDataSet(self, didTapView: view)
        didTapContentViewHandle?()
    }
    
    //MARK: - Reload APIs (Public)
    public func reloadEmptyDataSet(itemsCount: Int = 0) {
        guard dataSource != nil else { return }
        
        if ((shouldDisplay && itemsCount == 0) || shouldBeForcedToDisplay) && dataSource != nil {
            // Notifies that the empty dataset view will appear
            willAppear()
            
            // Configure empty dataset fade in display
            fadeInOnDisplay = shouldFadeIn
            
            // Removing view resetting the view and its constraints it very important to guarantee a good state
            // If a non-nil custom view is available, let's configure it instead
            prepareForReuse()
            
            if let customView = dataSource?.customView(self) {
                self.contentView.isHidden = true
                self.customView = customView
            } else {
                self.contentView.isHidden = false
                // Get the data from the data source
                let renderingMode: UIImage.RenderingMode = dataSource?.imageTintColor(self) != nil ? .alwaysTemplate : .alwaysOriginal
                
                contentView.spacing = dataSource?.verticalSpacing(self) ?? 11
                
                // Configure Image
                if let image = dataSource?.image(self) {
                    imageView.image = image.withRenderingMode(renderingMode)
                    if let imageTintColor = dataSource?.imageTintColor(self) {
                        imageView.tintColor = imageTintColor
                    }
                }
                // Configure title label
                titleLabelString(dataSource?.title(self))
                // Configure detail label
                detailLabelString(dataSource?.description(self))
                // Configure button
                if let image = dataSource?.buttonImage(self, for: .normal) {
                    buttonImage(image, for: .normal)
                    buttonImage(dataSource?.buttonImage(self, for: .highlighted), for: .highlighted)
                } else if let title = dataSource?.buttonTitle(self, for: .normal) {
                    buttonTitle(title, for: .normal)
                    buttonTitle(dataSource?.buttonTitle(self, for: .highlighted), for: .highlighted)
                    buttonBackgroundImage(dataSource?.buttonBackgroundImage(self, for: .normal), for: .normal)
                    buttonBackgroundImage(dataSource?.buttonBackgroundImage(self, for: .highlighted), for: .highlighted)
                }
            }
            
            // Configure offset
            verticalOffset = dataSource?.verticalOffset(self) ?? 0
            
            // Configure the empty dataset view
            backgroundColor = dataSource?.backgroundColor(self)
            isHidden = false
            clipsToBounds = true
            
            // Configure empty dataset userInteraction permission
            isUserInteractionEnabled = isTouchAllowed
            
            // Configure scroll permission
            if let scrollView = superview as? UIScrollView {
                scrollView.isScrollEnabled = isScrollAllowed
            }
            
            // Configure image view animation
            if self.isImageViewAnimateAllowed {
                if let animation = dataSource?.imageAnimation(self) {
                    imageView.layer.add(animation, forKey: nil)
                }
            } else {
                imageView.layer.removeAllAnimations()
            }
            
            configure?(self)
            
            setNeedsUpdateConstraints()
//            layoutIfNeeded()
            
            // Notifies that the empty dataset view did appear
            didAppear()
        } else if !isHidden {
            invalidate()
        }
    }
    
    internal func invalidate() {
        willDisappear()
        prepareForReuse()
        isHidden = true
        if let scrollView = superview as? UIScrollView {
            scrollView.isScrollEnabled = true
        }
        didDisappear()
    }
    
}

