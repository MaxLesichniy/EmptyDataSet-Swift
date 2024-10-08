//
//  Protocols.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 27/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation

/// The object that acts as the data source of the empty datasets.
/// @discussion The data source must adopt the DZNEmptyDataSetSource protocol. The data source is not retained. All data source methods are optional.
@MainActor
public protocol EmptyDataSetSource: AnyObject {
    
    func emptyDataSetViewState(_ emptyDataSetView: EmptyDataSetView) -> EmptyDataSetViewState?
    /// Asks the data source for the title of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameter scrollView: scrollView A scrollView subclass informing the data source.
    /// - Returns: An attributed string for the dataset title, combining font, text color, text pararaph style, etc.
    func title(_ emptyDataSetView: EmptyDataSetView) -> NSAttributedString?
    
    /// Asks the data source for the description of the dataset.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameter scrollView: scrollView A scrollView subclass informing the data source.
    /// - Returns: An attributed string for the dataset description text, combining font, text color, text pararaph style, etc.
    func description(_ emptyDataSetView: EmptyDataSetView) -> NSAttributedString?
    
    /// Asks the data source for the image of the dataset.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the data source.
    /// - Returns: An image for the dataset.
    func image(_ emptyDataSetView: EmptyDataSetView) -> PlatformImage?
    
    /// Asks the data source for a tint color of the image dataset. Default is nil.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: A color to tint the image of the dataset.
    func imageTintColor(_ emptyDataSetView: EmptyDataSetView) -> PlatformColor?

    /// Asks the data source for the image animation of the dataset.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: image animation
    func imageAnimation(_ emptyDataSetView: EmptyDataSetView) -> CAAnimation?
    
    #if os(iOS) || os(tvOS)
    /// Asks the data source for the title to be used for the specified button state.
    /// The dataset uses a fixed font style by default, if no attributes are set. If you want a different font style, return a attributed string.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the data source.
    ///   - forState: The state that uses the specified title. The possible values are described in UIControlState.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonTitle(_ emptyDataSetView: EmptyDataSetView, for state: UIControl.State) -> NSAttributedString?
    
    /// Asks the data source for the image to be used for the specified button state.
    /// This method will override buttonTitle_:forState: and present the image only without any text.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass object informing the data source.
    ///   - forState: The state that uses the specified title. The possible values are described in UIControlState.
    /// - Returns: An image for the dataset button imageview.
    func buttonImage(_ emptyDataSetView: EmptyDataSetView, for state: UIControl.State) -> UIImage?
    
    /// Asks the data source for a background image to be used for the specified button state.
    /// There is no default style for this call.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass informing the data source.
    ///   - forState: The state that uses the specified image. The values are described in UIControlState.
    /// - Returns: An attributed string for the dataset button title, combining font, text color, text pararaph style, etc.
    func buttonBackgroundImage(_ emptyDataSetView: EmptyDataSetView, for state: UIControl.State) -> UIImage?
    #endif
    
    /// Asks the data source for the background color of the dataset. Default is clear color.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the data source.
    /// - Returns: A color to be applied to the dataset background view.
    func backgroundColor(_ emptyDataSetView: EmptyDataSetView) -> PlatformColor?

    /// Asks the data source for a custom view to be displayed instead of the default views such as labels, imageview and button. Default is nil.
    /// Use this method to show an activity view indicator for loading feedback, or for complete custom empty data set.
    /// Returning a custom view will ignore -offset_ and -spaceHeight_ configurations.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: The custom view.
    func customView(_ emptyDataSetView: EmptyDataSetView) -> PlatformView?

    /// Asks the data source for a offset for vertical alignment of the content. Default is 0.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: The offset for vertical alignment.
    func verticalOffset(_ emptyDataSetView: EmptyDataSetView) -> CGFloat

    /// Asks the data source for a vertical space between elements. Default is 11 pts.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: The space height between elements.
    func verticalSpacing(_ emptyDataSetView: EmptyDataSetView) -> CGFloat

}

public extension EmptyDataSetSource {
    
    func emptyDataSetViewState(_ emptyDataSetView: EmptyDataSetView) -> EmptyDataSetViewState? {
        return nil
    }
    
    func title(_ emptyDataSetView: EmptyDataSetView) -> NSAttributedString? {
        return nil
    }
    
    func description(_ emptyDataSetView: EmptyDataSetView) -> NSAttributedString? {
        return nil
    }
    
    func image(_ emptyDataSetView: EmptyDataSetView) -> PlatformImage? {
        return nil
    }
    
    func imageTintColor(_ emptyDataSetView: EmptyDataSetView) -> PlatformColor? {
        return nil
    }
    
    func imageAnimation(_ emptyDataSetView: EmptyDataSetView) -> CAAnimation? {
        return nil
    }
 
    #if os(iOS) || os(tvOS)
    func buttonTitle(_ emptyDataSetView: EmptyDataSetView, for state: UIControl.State) -> NSAttributedString? {
        return nil
    }
    
    func buttonImage(_ emptyDataSetView: EmptyDataSetView, for state: UIControl.State) -> UIImage? {
        return nil
    }

    func buttonBackgroundImage(_ emptyDataSetView: EmptyDataSetView, for state: UIControl.State) -> UIImage? {
        return nil
    }
    #endif
    
    func backgroundColor(_ emptyDataSetView: EmptyDataSetView) -> PlatformColor? {
        return nil
    }
    
    func customView(_ emptyDataSetView: EmptyDataSetView) -> PlatformView? {
        return nil
    }
    
    func verticalOffset(_ emptyDataSetView: EmptyDataSetView) -> CGFloat {
        return 0
    }
 
    func verticalSpacing(_ emptyDataSetView: EmptyDataSetView) -> CGFloat {
        return emptyDataSetView.spacing
    }
}
