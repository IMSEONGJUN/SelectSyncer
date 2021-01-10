//
//  UIHelper.swift
//  SelectSyncer
//
//  Created by SEONGJUN on 2021/01/09.
//

import UIKit

struct UIHelper {
    
    static var resultCollectionViewHeight: CGFloat = 0
    static let separatorHeight:CGFloat = 44
    static let menuBarHeight:CGFloat = 44
    static let totalUpperSideHeight: CGFloat = resultCollectionViewHeight + separatorHeight
    
    static func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let collectionViewWidth = view.frame.width
        let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let itemsInLine: CGFloat = 3
        let itemSpacing: CGFloat = 1
        let lineSpacing: CGFloat = 1
        let availableWidth = collectionViewWidth - ((itemSpacing * (itemsInLine - 1)) + (inset.left + inset.right))
        let itemWidth = availableWidth / itemsInLine
        resultCollectionViewHeight = itemWidth * 2 + 1
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = lineSpacing
        flowLayout.sectionInset = inset
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        flowLayout.scrollDirection = .vertical
        return flowLayout
    }
}


extension UIView {
    
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }
    
    var layout : UIView {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }
    
    @discardableResult
    func top(equalTo anchor: NSLayoutYAxisAnchor? = nil, constant c: CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.topAnchor
        topAnchor.constraint(equalTo: anchor, constant: c).isActive = true
        return self
    }
    
    @discardableResult
    func leading(equalTo anchor: NSLayoutXAxisAnchor? = nil, constant c: CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.leadingAnchor
        leadingAnchor.constraint(equalTo: anchor, constant: c).isActive = true
        return self
    }
    
    @discardableResult
    func trailing(equalTo anchor: NSLayoutXAxisAnchor? = nil, constant c: CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.trailingAnchor
        trailingAnchor.constraint(equalTo: anchor, constant: c).isActive = true
        return self
    }
    
    @discardableResult
    func bottom(equalTo anchor: NSLayoutYAxisAnchor? = nil, constant c: CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.bottomAnchor
        bottomAnchor.constraint(equalTo: anchor, constant: c).isActive = true
        return self
    }
    
    @discardableResult
    func centerX(equalTo anchor: NSLayoutXAxisAnchor? = nil, constant c: CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.centerXAnchor
        centerXAnchor.constraint(equalTo: anchor, constant: c).isActive = true
        return self
    }
    
    @discardableResult
    func centerY(equalTo anchor: NSLayoutYAxisAnchor? = nil, constant c: CGFloat = 0) -> Self {
        let anchor = anchor ?? superview!.centerYAnchor
        centerYAnchor.constraint(equalTo: anchor, constant: c).isActive = true
        return self
    }
    
    @discardableResult
    func width(equalTo anchor: NSLayoutAnchor<NSLayoutDimension>? = nil, equalToconstant c: CGFloat = 0) -> Self {
        if let anchor = anchor {
            widthAnchor.constraint(equalTo: anchor, constant: c).isActive = true
        } else {
            widthAnchor.constraint(equalToConstant: c).isActive = true
        }
        return self
    }
    
    @discardableResult
    func height(equalTo anchor: NSLayoutAnchor<NSLayoutDimension>? = nil, equalToconstant c: CGFloat = 0) -> Self {
        if let anchor = anchor {
            heightAnchor.constraint(equalTo: anchor, constant: c).isActive = true
        } else {
            heightAnchor.constraint(equalToConstant: c).isActive = true
        }
        return self
    }
    
    @discardableResult
    func fillSuperView() -> Self {
        topAnchor.constraint(equalTo: superview!.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superview!.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview!.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview!.bottomAnchor).isActive = true
        return self
    }
    
    @discardableResult
    func fillSuperViewSafeAreaGuide() -> Self {
        topAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.topAnchor).isActive = true
        leadingAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.trailingAnchor).isActive = true
        bottomAnchor.constraint(equalTo: superview!.safeAreaLayoutGuide.bottomAnchor).isActive = true
        return self
    }
    
    func setupShadow(opacity: Float = 0, radius: CGFloat = 0, offset: CGSize = .zero, color: UIColor = .black) {
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
    }
}

