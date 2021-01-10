//
//  UIViewController+Ext.swift
//  SelectSyncer
//
//  Created by SEONGJUN on 2021/01/09.
//

import UIKit

extension UIViewController {
    var statusBarHeight: CGFloat {
        let window = UIApplication.shared.windows.filter{$0.isKeyWindow}.first
        let statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        return statusBarHeight
    }
}

extension UIApplication {
    static var statusBar: UIView {
        let status = UIView(frame: (UIApplication.shared.windows.filter{$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame)!)
        return status
    }
}
