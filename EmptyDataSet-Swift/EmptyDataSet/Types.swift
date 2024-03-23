//
//  Types.swift
//  EmptyDataSet-Swift
//
//  Created by Max Lesichniy on 06.03.2021.
//

import Foundation
#if os(macOS)
import AppKit
public typealias PlatformImage = NSImage
public typealias PlatformColor = NSColor
public typealias PlatformView = NSView
public typealias PlatformStackView = NSStackView
public typealias PlatformImageView = NSImageView
public typealias PlatformLabel = NSTextField
public typealias PlatformButton = NSButton
public typealias PlatformEdgeInsets = NSEdgeInsets

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
public typealias PlatformImage = UIImage
public typealias PlatformColor = UIColor
public typealias PlatformView = UIView
public typealias PlatformStackView = UIStackView
public typealias PlatformImageView = UIImageView
public typealias PlatformLabel = UILabel
public typealias PlatformButton = UIButton
public typealias PlatformEdgeInsets = UIEdgeInsets
#endif

extension PlatformView {
    
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
