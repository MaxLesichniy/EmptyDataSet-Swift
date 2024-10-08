//
//  EmptyDataSetView+Extension.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 3/7/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation

extension EmptyDataSetView {

    // TODO: - override options
    @discardableResult
    public func applyConfiguration(/*override: Bool = false,*/ _ configurationHandler: @escaping (EmptyDataSetView) -> Void) -> Self {
        if let oldConfigure = configure/*, override == false*/ {
            configure = { emptyDataSetView in
                oldConfigure(emptyDataSetView)
                configurationHandler(emptyDataSetView)
            }
        } else {
            configure = configurationHandler
        }
        return self
    }
    
    // MARK: - Data Source
    
    /// Asks the data source for the title of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    @discardableResult
    public func titleLabelString(_ attributedString: NSAttributedString?) -> Self {
        titleLabel.attributedText = attributedString
        titleLabel.isHidden = !canShowTitle
        return self
    }
    
    /// Asks the data source for the description of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    @discardableResult
    public func detailLabelString(_ attributedString: NSAttributedString?) -> Self {
        detailLabel.attributedText = attributedString
        detailLabel.isHidden = !canShowDetail
        return self
    }
    
    /// Asks the data source for the image of the dataset.
    @discardableResult
    public func image(_ image: PlatformImage?) -> Self {
        imageView.image = image
        imageView.isHidden = !canShowImage
        return self
    }
    
    /// Asks the data source for a tint color of the image dataset. Default is nil.
    @discardableResult
    public func imageTintColor(_ imageTintColor: PlatformColor?) -> Self {
        #if os(iOS) || os(tvOS)
        imageView.tintColor = imageTintColor
        let renderingMode: UIImage.RenderingMode = imageTintColor != nil ? .alwaysTemplate : .alwaysOriginal
        return image(imageView.image?.withRenderingMode(renderingMode))
        #else
        return self
        #endif
    }
    
    /// Asks the data source for the image animation of the dataset.
    @discardableResult
    public func imageAnimation(_ imageAnimation: CAAnimation?) -> Self {
        #if os(iOS) || os(tvOS)
        imageAnimation.map {
            imageView.layer.add($0, forKey: nil)
        }
        #endif
        return self
    }
    
    #if os(iOS) || os(tvOS)
    /// Asks the data source for the title to be used for the specified button state.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    @discardableResult
    public func buttonTitle(_ buttonTitle: NSAttributedString?, for state: UIControl.State) -> Self {
        button.setAttributedTitle(buttonTitle, for: state)
        button.isHidden = !canShowButton
        return self
    }
    
    /// Asks the data source for the image to be used for the specified button state.
    /// This method will override buttonTitleForEmptyDataSet:forState: and present the image only without any text.
    @discardableResult
    public func buttonImage(_ buttonImage: UIImage?, for state: UIControl.State) -> Self {
        button.setImage(buttonImage, for: state)
        button.isHidden = !canShowButton
        return self
    }
    
    /// Asks the data source for a background image to be used for the specified button state.
    /// There is no default style for this call.
    @discardableResult
    public func buttonBackgroundImage(_ buttonBackgroundImage: UIImage?, for state: UIControl.State) -> Self {
        button.setBackgroundImage(buttonBackgroundImage, for: state)
        return self
    }
    #endif
    
    /// Asks the data source for the background color of the dataset. Default is clear color.
    @discardableResult
    public func dataSetBackgroundColor(_ backgroundColor: PlatformColor?) -> Self {
        #if os(iOS) || os(tvOS)
        self.backgroundColor = backgroundColor
        #else
        self.layer?.backgroundColor = backgroundColor?.cgColor
        #endif
        return self
    }
    
    /// Asks the data source for a custom view to be displayed instead of the default views such as labels, imageview and button. Default is nil.
    /// Use this method to show an activity view indicator for loading feedback, or for complete custom empty data set.
    /// Returning a custom view will ignore -offsetForEmptyDataSet and -spaceHeightForEmptyDataSet configurations.
    @discardableResult
    public func customView(_ customView: PlatformView?) -> Self {
        self.customView = customView
        self.contentView.isHidden = customView != nil
        self.setNeedsUpdateConstraints()
        return self
    }
    
    /// Asks the data source for a offset for vertical alignment of the content. Default is 0.
    @discardableResult
    public func verticalOffset(_ offset: CGFloat) -> Self {
        verticalOffset = offset
        setNeedsUpdateConstraints()
        return self
    }
    
    /// Asks the data source for a vertical space between elements. Default is 11 pts.
    @discardableResult
    public func verticalSpacing(_ spacing: CGFloat) -> Self {
        contentView.spacing = spacing
        return self
    }
    
    //MARK: - Delegate & Events
    /// Asks the delegate to know if the empty dataset should fade in when displayed. Default is true.
//    @discardableResult
//    public func shouldFadeIn(_ bool: Bool) -> Self {
//        fadeInOnDisplay = bool
//        return self
//    }
    
    /// Asks the delegate to know if the empty dataset should still be displayed when the amount of items is more than 0. Default is false.
    @discardableResult
    public func shouldBeForcedToDisplay(_ bool: Bool) -> Self {
        isHidden = !bool
        return self
    }
    
    /// Asks the delegate to know if the empty dataset should be rendered and displayed. Default is true.
    @discardableResult
    public func shouldDisplay(_ bool: Bool) -> Self {
        #if os(iOS) || os(tvOS)
        if let superview = self.superview as? UIScrollView {
            isHidden = !(bool && superview.itemsCount == 0)
        } else {
            isHidden = !bool
        }
        #endif
        return self
    }
    
    #if os(iOS) || os(tvOS)
    /// Asks the delegate for touch permission. Default is true.
    @discardableResult
    public func isTouchAllowed(_ bool: Bool) -> Self {
        isUserInteractionEnabled = bool
        return self
    }
    
    /// Asks the delegate for scroll permission. Default is false.
    @discardableResult
    public func isScrollAllowed(_ bool: Bool) -> Self {
        if let superview = superview as? UIScrollView {
            superview.isScrollEnabled = bool
        }
        return self
    }
    #endif
    
    /// Asks the delegate for image view animation permission. Default is false.
    /// Make sure to return a valid CAAnimation object from imageAnimationForEmptyDataSet:
    @discardableResult
    public func isImageViewAnimateAllowed(_ bool: Bool) -> Self {
        #if os(iOS) || os(tvOS)
        if !bool {
            imageView.layer.removeAllAnimations()
        }
        #endif
        return self
    }
    
    #if os(iOS) || os(tvOS)
    /// Tells the delegate that the empty dataset view was tapped.
    /// Use this method either to resignFirstResponder of a textfield or searchBar.
    @discardableResult
    public func didTapContentView(_ closure: @escaping () -> (Void)) -> Self {
        didTapContentViewHandle = closure
        return self
    }
    #endif
    
    /// Tells the delegate that the action button was tapped.
    @discardableResult
    public func didTapDataButton(_ closure: @escaping () -> (Void)) -> Self {
        didTapDataButtonHandle = closure
        return self
    }
    
    /// Tells the delegate that the empty data set will appear.
    @discardableResult
    public func willAppear(_ closure: @escaping () -> (Void)) -> Self {
        willAppearHandle = closure
        return self
    }
    
    /// Tells the delegate that the empty data set did appear.
    @discardableResult
    public func didAppear(_ closure: @escaping () -> (Void)) -> Self {
        didAppearHandle = closure
        return self
    }
    
    /// Tells the delegate that the empty data set will disappear.
    @discardableResult
    public func willDisappear(_ closure: @escaping () -> (Void)) -> Self {
        willDisappearHandle = closure
        return self
    }
    
    /// Tells the delegate that the empty data set did disappear.
    @discardableResult
    public func didDisappear(_ closure: @escaping () -> (Void)) -> Self {
        didDisappearHandle = closure
        return self
    }
    
}
