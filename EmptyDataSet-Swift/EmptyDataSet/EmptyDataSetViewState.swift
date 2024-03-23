//
//  EmptyDataSetViewState.swift
//  EmptyDataSet-Swift
//
//  Created by Max Lesichniy on 20.09.2021.
//

import Foundation

public struct EmptyDataSetViewState: Hashable {

    public var title: String?
    public var attributedTitle: NSAttributedString?
    public var details: String?
    public var attributedDetails: NSAttributedString?
    public var image: PlatformImage?
    public var additionalButtons: [PlatformButton]?
    public var buttonTitle: String?
    public var buttonHandler: (() -> Void)?
    
    public var hasTitle: Bool {
        if let str = title, !str.isEmpty {
            return true
        }
        if let str = attributedTitle?.string, !str.isEmpty {
            return true
        }
        return false
    }
    
    public var hasDetails: Bool {
        if let str = details, !str.isEmpty {
            return true
        }
        if let str = attributedDetails?.string, !str.isEmpty {
            return true
        }
        return false
    }
    
    public init(title: String? = nil, attributedTitle: NSAttributedString? = nil,
                details: String? = nil, attributedDetails: NSAttributedString? = nil,
                image: PlatformImage? = nil,
                additionalButtons: [PlatformButton]? = nil,
                buttonTitle: String? = nil, buttonHandler: (() -> Void)? = nil) {
        self.title = title
        self.attributedTitle = attributedTitle
        self.details = details
        self.attributedDetails = attributedDetails
        self.image = image
        self.additionalButtons = additionalButtons
        self.buttonTitle = buttonTitle
        self.buttonHandler = buttonHandler
    }
    
    public init(_ base: EmptyDataSetViewState) {
        self.title = base.title
        self.attributedTitle = base.attributedTitle
        self.details = base.details
        self.attributedDetails = base.attributedDetails
        self.image = base.image
        self.additionalButtons = base.additionalButtons
        self.buttonTitle = base.buttonTitle
        self.buttonHandler = base.buttonHandler
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(attributedTitle)
        hasher.combine(details)
        hasher.combine(attributedDetails)
        hasher.combine(image)
        hasher.combine(additionalButtons)
        hasher.combine(buttonTitle)
    }
    
    public static func == (lhs: EmptyDataSetViewState, rhs: EmptyDataSetViewState) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}
