//
//  UIKitExtension.swift
//  AELFExchange
//
//  Created by tng on 2019/7/4.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

private var ___runtimeKeyLocalizableText: Void?
private var ___runtimeKeyLocalizableButtonTitle: Void?
private var ___runtimeKeyLocalizablePlaceholder: Void?

extension UIView {
    
    @IBInspectable
    var LocalizableText: String? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyLocalizableText) as? String
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyLocalizableText, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let key = newValue {
                if let comp = self as? UILabel {
                    comp.text = LOCSTR(withKey: key)
                } else if let comp = self as? UITextField {
                    comp.text = LOCSTR(withKey: key)
                } else if let comp = self as? UITextView {
                    comp.text = LOCSTR(withKey: key)
                }
            }
        }
    }
    
    @IBInspectable
    var LocalizableButtonTitle: String? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyLocalizableButtonTitle) as? String
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyLocalizableButtonTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let key = newValue {
                guard let b = self as? UIButton else { return }
                b.setTitle(LOCSTR(withKey: key), for: .normal)
            }
        }
    }
    
    @IBInspectable
    var LocalizablePlaceholder: String? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyLocalizablePlaceholder) as? String
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyLocalizablePlaceholder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if let key = newValue {
                guard let comp = self as? UITextField else { return }
                comp.placeholder = LOCSTR(withKey: key)
            }
        }
    }
    
}
