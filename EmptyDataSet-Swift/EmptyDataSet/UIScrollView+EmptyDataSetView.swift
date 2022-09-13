//
//  EmptyDataSet.swift
//  EmptyDataSet-Swift
//
//  Created by YZF on 28/6/17.
//  Copyright © 2017年 Xiaoye. All rights reserved.
//

#if canImport(UIKit)
import UIKit

private var kEmptyDataSetView = "emptyDataSetView"

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
    
    public func removeEmptyDataSetView() {
        invalidate()
        emptyDataSetDelegate = nil
        emptyDataSetSource = nil
        emptyDataSetView = nil
    }
    
    private func prepareEmptyDataSetView() {
        let view = EmptyDataSetView(frame: bounds)
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.isHidden = true
        
        // Send the view all the way to the back, in case a header and/or footer is present, as well as for sectionHeaders or any other content
        if (self is UITableView) || (self is UICollectionView) || (subviews.count > 1) {
            insertSubview(view, at: 0)
        } else {
            addSubview(view)
        }
        
        emptyDataSetView = view
        
        UIScrollView.swizzleReloadData
        UIScrollView.swizzleLayoutSubviews
//        UIScrollView.swizzleDidMoveToWindow
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
        let oldItemsCount = self.itemsCount
        eds_swizzledCollectionViewPerformBatchUpdates { [weak self] in
            updates?()
            guard let `self` = self else { return }
            if self.itemsCount != oldItemsCount {
                if self.itemsCount == 0 || oldItemsCount == 0 {
                    self.invalidate()
                }
            }
        } completion: { [weak self] (finished) in
            self?.reloadEmptyDataSet()
            completion?(finished)
        }
    }
    
    @objc private func eds_swizzledLayoutSubviews() {
        eds_swizzledLayoutSubviews()
        
        guard let emptyDataSetView = emptyDataSetView else { return }
        sendSubviewToBack(emptyDataSetView)
        emptyDataSetView.frame = bounds
    }
    
//    @objc private func eds_swizzledDidMoveToWindow() {
//        eds_swizzledDidMoveToWindow()
//        reloadEmptyDataSet()
//    }
    
    private static let swizzleLayoutSubviews: () = {
        swizzleMethod(for: UIScrollView.self,
                      originalSelector: #selector(UIScrollView.layoutSubviews),
                      swizzledSelector: #selector(UIScrollView.eds_swizzledLayoutSubviews))
    }()
    
//    private static let swizzleDidMoveToWindow: () = {
//        swizzleMethod(for: UIScrollView.self,
//                      originalSelector: #selector(UIScrollView.didMoveToWindow),
//                      swizzledSelector: #selector(UIScrollView.eds_swizzledDidMoveToWindow))
//    }()
    
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
#endif
