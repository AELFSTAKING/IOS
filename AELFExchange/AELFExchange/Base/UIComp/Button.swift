//
//  Button.swift
//  AELFExchange
//
//  Created by tng on 2019/1/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class Button: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    @IBInspectable
    var ForegroundText: String? {
        didSet {
            if ForegroundText == "1" {
                self.setTitleColor(kThemeColorSelected, for: .normal)
                self.titleLabel?.font = kThemeFontNormal
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var GeneralText: String? {
        didSet {
            if GeneralText == "1" {
                self.setTitleColor(kThemeColorTextNormal, for: .normal)
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var GrayText: String? {
        didSet {
            if GrayText == "1" {
                self.setTitleColor(kThemeColorTextUnabled, for: .normal)
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var WhiteText: String? {
        didSet {
            if WhiteText == "1" {
                self.setTitleColor(.white, for: .normal)
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var SubmitMode: String? {
        didSet {
            if SubmitMode == "1" {
                self.setTitleColor(.white, for: .normal)
                self.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
                self.setBackgroundImage(UIImage(named: "icon-asset-button-bg"), for: .normal)
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var SmallBg: String? {
        didSet {
            if SmallBg == "1" {
                self.setTitleColor(.white, for: .normal)
                self.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
                self.setBackgroundImage(UIImage(named: "icon-asset-button-bg-small"), for: .normal)
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var LargeFont: String? {
        didSet {
            if LargeFont == "1" {
                self.titleLabel?.font = kThemeFontLarge
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var SmallFont: String? {
        didSet {
            if SmallFont == "1" {
                self.titleLabel?.font = kThemeFontSmall
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var PriceMode: String? {
        didSet {
            if PriceMode == "1" {
                self.titleLabel?.font = kThemeFontSmall
                self.addCorner(withRadius: 16.0)
                self.addBorder(withWitdh: 1.0, color: kThemeColorGreen)
                self.priceChanged(to: .up)
                self.titleLabel?.font = kThemeFontLarge
                self.setNeedsLayout()
            }
        }
    }
    
    func commonInit() -> Void {
        self.setTitleColor(kThemeColorTextNormal, for: .normal)
        self.setNeedsLayout()
    }
    
    func priceChanged(to direction: PriceDirectionEnum) -> Void {
        switch direction {
        case .up:
            self.setTitleColor(kThemeColorGreen, for: .normal)
            self.layer.borderColor = kThemeColorGreen.cgColor
        case .down:
            self.setTitleColor(kThemeColorGreen, for: .normal)
            self.layer.borderColor = kThemeColorGreen.cgColor
        case .flat:
            self.setTitleColor(.white, for: .normal)
            self.layer.borderColor = UIColor.white.cgColor
        }
    }
    
}
