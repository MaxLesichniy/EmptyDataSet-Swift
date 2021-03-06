//
//  EmptyDataSet.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 28/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

import Foundation
import UIKit

private var kEmptyDataSetView = "emptyDataSetView"
private var kConfigureEmptyDataSetView = "configureEmptyDataSetView"

extension UIScrollView {
    
    //MARK: - Public Property
    
    public var emptyDataSetSource: EmptyDataSetSource? {
        get {
            return emptyDataSetView?.dataSource
        }
        set {
            if newValue == nil {
                invalidate()
            } else if emptyDataSetView == nil {
                prepareEmptyDataSetView()
            }
            
            emptyDataSetView?.dataSource = newValue
        }
    }
    
    public var emptyDataSetDelegate: EmptyDataSetDelegate? {
        get {
            return emptyDataSetView?.delegate
        }
        set {
            if newValue == nil {
                invalidate()
            } else if emptyDataSetView == nil {
                prepareEmptyDataSetView()
            }
            
            emptyDataSetView?.delegate = newValue
        }
    }
    
    public func emptyDataSetView(_ closure: @escaping (EmptyDataSetView) -> Void) {
        if emptyDataSetView == nil {
            prepareEmptyDataSetView()
        }
        emptyDataSetView?.configure = closure
    }
    
    public private(set) var emptyDataSetView: EmptyDataSetView? {
        get {
            if let view = objc_getAssociatedObject(self, &kEmptyDataSetView) as? EmptyDataSetView {
                return view
            }
            return nil
        }
        set {
            objc_setAssociatedObject(self, &kEmptyDataSetView, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    private func prepareEmptyDataSetView() {
        let view = EmptyDataSetView(frame: bounds)
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        // Send the view all the way to the back, in case a header and/or footer is present, as well as for sectionHeaders or any other content
        if (self is UITableView) || (self is UICollectionView) || (subviews.count > 1) {
            insertSubview(view, at: 0)
        } else {
            addSubview(view)
        }
        
//        NSLayoutConstraint.activate([view.topAnchor.constraint(equalTo: topAnchor),
//                                     view.leadingAnchor.constraint(equalTo: leadingAnchor),
//                                     view.trailingAnchor.constraint(equalTo: trailingAnchor),
//                                     view.bottomAnchor.constraint(equalTo: bottomAnchor)])
        
        emptyDataSetView = view
        
        UIScrollView.swizzleReloadData
        UIScrollView.swizzleLayoutSubviews
        UIScrollView.swizzleBatchUpdate
        if self is UITableView {
            UIScrollView.swizzleEndUpdates
        }
    }
    
    internal var itemsCount: Int {
        var items = 0
        
        // UITableView support
        if let tableView = self as? UITableView {
            var sections = 1
            
            if let dataSource = tableView.dataSource {
                if dataSource.responds(to: #selector(UITableViewDataSource.numberOfSections(in:))) {
                    sections = dataSource.numberOfSections!(in: tableView)
                }
                if dataSource.responds(to: #selector(UITableViewDataSource.tableView(_:numberOfRowsInSection:))) {
                    for i in 0 ..< sections {
                        items += dataSource.tableView(tableView, numberOfRowsInSection: i)
                    }
                }
            }
        } else if let collectionView = self as? UICollectionView {
            var sections = 1
            
            if let dataSource = collectionView.dataSource {
                if dataSource.responds(to: #selector(UICollectionViewDataSource.numberOfSections(in:))) {
                    sections = dataSource.numberOfSections!(in: collectionView)
                }
                if dataSource.responds(to: #selector(UICollectionViewDataSource.collectionView(_:numberOfItemsInSection:))) {
                    for i in 0 ..< sections {
                        items += dataSource.collectionView(collectionView, numberOfItemsInSection: i)
                    }
                }
            }
        }
        
        return items
    }
    
    private func invalidate() {
        emptyDataSetView?.invalidate()
    }
    
    public func reloadEmptyDataSet() {
        emptyDataSetView?.frame = bounds
        emptyDataSetView?.reloadEmptyDataSet(itemsCount: itemsCount)
    }
    
    //MARK: - Method Swizzling
    
    @objc private func eds_swizzledTabbleViewReloadData() {
        eds_swizzledTabbleViewReloadData()
        reloadEmptyDataSet()
    }
    
    @objc private func eds_swizzledTableViewEndUpdates() {
        eds_swizzledTableViewEndUpdates()
        reloadEmptyDataSet()
    }
    
    @objc private func eds_swizzledCollectionViewReloadData() {
        eds_swizzledCollectionViewReloadData()
        reloadEmptyDataSet()
    }
    
    @objc private func eds_swizzledTableViewPerformBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        eds_swizzledTableViewPerformBatchUpdates(updates) { [weak self] (finished) in
            self?.reloadEmptyDataSet()
            completion?(finished)
        }
    }
    
    @objc private func eds_swizzledCollectionViewPerformBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        eds_swizzledCollectionViewPerformBatchUpdates(updates) { [weak self] (finished) in
            self?.reloadEmptyDataSet()
            completion?(finished)
        }
    }
    
    @objc private func eds_swizzledlayoutSubviews() {
        eds_swizzledlayoutSubviews()
        
        emptyDataSetView?.frame = bounds
    }
    
    private class func swizzleMethod(for aClass: AnyClass, originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(aClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)
        
        let didAddMethod = class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
        } else {
            method_exchangeImplementations(originalMethod!, swizzledMethod!)
        }
    }
    
    private static let swizzleLayoutSubviews: () = {
        swizzleMethod(for: UIScrollView.self,
                      originalSelector: #selector(UIScrollView.layoutSubviews),
                      swizzledSelector: #selector(UIScrollView.eds_swizzledlayoutSubviews))
    }()
    
    private static let swizzleReloadData: () = {
        swizzleMethod(for: UITableView.self,
                      originalSelector: #selector(UITableView.reloadData),
                      swizzledSelector: #selector(UIScrollView.eds_swizzledTabbleViewReloadData))
        
        swizzleMethod(for: UICollectionView.self,
                      originalSelector: #selector(UICollectionView.reloadData),
                      swizzledSelector: #selector(UIScrollView.eds_swizzledCollectionViewReloadData))
    }()
    
    private static let swizzleBatchUpdate: () = {
        if #available(iOS 11.0, *) {
            swizzleMethod(for: UITableView.self, originalSelector: #selector(UITableView.performBatchUpdates(_:completion:)),
                          swizzledSelector: #selector(UIScrollView.eds_swizzledTableViewPerformBatchUpdates(_:completion:)))
        }
        
        swizzleMethod(for: UICollectionView.self,
                      originalSelector: #selector(UICollectionView.performBatchUpdates(_:completion:)),
                      swizzledSelector: #selector(UIScrollView.eds_swizzledCollectionViewPerformBatchUpdates(_:completion:)))
    }()
    
    private static let swizzleEndUpdates: () = {
        swizzleMethod(for: UITableView.self,
                      originalSelector: #selector(UITableView.endUpdates),
                      swizzledSelector: #selector(UIScrollView.eds_swizzledTableViewEndUpdates))
    }()
    
}
