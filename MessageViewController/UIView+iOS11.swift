//
//  UIView+iOS11.swift
//  MessageViewController
//
//  Created by Ryan Nystrom on 12/22/17.
//

import UIKit

internal extension UIView {
    // swiftlint:disable:next identifier_name
    var util_safeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return safeAreaInsets
        } else {
            return .zero
        }
    }

}

internal extension UIScrollView {
    // swiftlint:disable:next identifier_name
    var util_adjustedContentInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return adjustedContentInset
        } else {
            return contentInset
        }
    }

}
