//
//  View.swift
//  AELFExchange
//
//  Created by tng on 2019/1/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class View: UIView {
    
    @IBInspectable
    var General: String? {
        didSet {
            if General == "1" {
                self.backgroundColor = kThemeColorForeground
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var Foreground: String? {
        didSet {
            if Foreground == "1" {
                self.backgroundColor = kThemeColorSelected
                self.setNeedsLayout()
            }
        }
    }
    
}
