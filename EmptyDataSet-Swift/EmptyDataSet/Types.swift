//
//  Types.swift
//  EmptyDataSet-Swift
//
//  Created by Max Lesichniy on 06.03.2021.
//

import Foundation
#if os(macOS)
import AppKit
public typealias Image = NSImage
public typealias Color = NSColor
public typealias View = NSView
public typealias StackView = NSStackView
public typealias ImageView = NSImageView
public typealias Label = NSTextField
public typealias Button = NSButton
public typealias EdgeInsets = NSEdgeInsets

extension NSTextField {
    
    var attributedText: NSAttributedString? {
        get { attributedStringValue }
        set { attributedStringValue = newValue ?? NSAttributedString() }
    }
    
}

extension NSView {
    
    func setNeedsUpdateConstraints() {
        self.needsUpdateConstraints = true
    }
    
}

#else
import UIKit
public typealias Image = UIImage
public typealias Color = UIColor
public typealias View = UIView
public typealias StackView = UIStackView
public typealias ImageView = UIImageView
public typealias Label = UILabel
public typealias Button = UIButton
public typealias EdgeInsets = UIEdgeInsets
#endif

extension View {
    
    class func swizzleMethod(for aClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(aClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)
        
        let didAddMethod = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
}
