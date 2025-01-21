//
//  EmptyDataSetDelegate.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 27/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// The object that acts as the delegate of the empty datasets.
/// @discussion The delegate can adopt the DZNEmptyDataSetDelegate protocol. The delegate is not retained. All delegate methods are optional.
///
/// @discussion All delegate methods are optional. Use this delegate for receiving action callbacks.
@MainActor
public protocol EmptyDataSetDelegate: AnyObject {

    /// Asks the delegate to know if the empty dataset should be rendered and displayed. Default is true.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset should show.
    func emptyDataSetShouldDisplay(_ emptyDataSetView: EmptyDataSetView, with state: EmptyDataSetViewState?) -> Bool

    /// Asks the delegate for scroll permission. Default is false.
    ///
    /// - Parameter scrollView: A scrollView subclass object informing the delegate.
    /// - Returns: true if the empty dataset is allowed to be scrollable.
    func emptyDataSetShouldAllowScroll(_ emptyDataSetView: EmptyDataSetView) -> Bool

    /// Tells the delegate that the empty dataset view was tapped.
    /// Use this method either to resignFirstResponder of a textfield or searchBar.
    ///
    /// - Parameters:
    ///   - scrollView: scrollView A scrollView subclass informing the delegate.
    ///   - view: the view tapped by the user
    func emptyDataSet(_ emptyDataSetView: EmptyDataSetView, didTapView view: PlatformView)

    /// Tells the delegate that the action button was tapped.
    ///
    /// - Parameters:
    ///   - scrollView: A scrollView subclass informing the delegate.
    ///   - button: the button tapped by the user
    func emptyDataSet(_ emptyDataSetView: EmptyDataSetView, didTapButton button: PlatformButton)

    /// Tells the delegate that the empty data set will appear.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetWillAppear(_ emptyDataSetView: EmptyDataSetView)

    /// Tells the delegate that the empty data set did appear.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetDidAppear(_ emptyDataSetView: EmptyDataSetView)

    /// Tells the delegate that the empty data set will disappear.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetWillDisappear(_ emptyDataSetView: EmptyDataSetView)

    /// Tells the delegate that the empty data set did disappear.
    ///
    /// - Parameter scrollView: A scrollView subclass informing the delegate.
    func emptyDataSetDidDisappear(_ emptyDataSetView: EmptyDataSetView)

}

public extension EmptyDataSetDelegate {
    
    func emptyDataSetShouldDisplay(_ emptyDataSetView: EmptyDataSetView, with state: EmptyDataSetViewState?) -> Bool {
        return emptyDataSetView.shouldDisplay
    }
    
    func emptyDataSetShouldAllowScroll(_ emptyDataSetView: EmptyDataSetView) -> Bool {
        return false
    }
    
    func emptyDataSet(_ emptyDataSetView: EmptyDataSetView, didTapView view: PlatformView) {
        
    }
    
    func emptyDataSet(_ emptyDataSetView: EmptyDataSetView, didTapButton button: PlatformButton) {
        
    }
    
    func emptyDataSetWillAppear(_ emptyDataSetView: EmptyDataSetView) {
        
    }
    
    func emptyDataSetDidAppear(_ emptyDataSetView: EmptyDataSetView) {
        
    }
    
    func emptyDataSetWillDisappear(_ emptyDataSetView: EmptyDataSetView) {
        
    }
    
    func emptyDataSetDidDisappear(_ emptyDataSetView: EmptyDataSetView) {
        
    }
    
}
