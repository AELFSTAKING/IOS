//
//  Theme.swift
//  AELF
//
//  Created by tng on 2018/9/10.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation
import SnapKit

public let kDefaultAvatar = UIImage(named: "?")

public let kThemeColorNavigationBar = UIColor(hexStr: kThemeColorBackgroundHex)
public let kThemeColorNavigationBarBlue = UIColor(hexStr: "131529")

public let kThemeColorTintPurple = UIColor(hexStr: "641DAF")
public let kThemeColorBackgroundHex = "FFFFFF"
public let kThemeColorBackground = UIColor(hexStr: kThemeColorBackgroundHex)
public let kThemeColorBackgroundGray = UIColor(hexStr: "F5F6FA")
public let kThemeColorBackgroundToast = UIColor(hexStr: "262D46")
public let kThemeColorBackgroundCellItem = UIColor(hexStr: "131527")

public let kThemeColorForeground = UIColor(hexStr: "191B31")
public let kThemeColorOrange = UIColor(hexStr: "F79620")

public let kThemeColorGreen = UIColor(hexStr: "03B682")
public let kThemeColorGreenProgress = UIColor(hexStr: "03B682")

public let kThemeColorRed = UIColor(hexStr: "F5615C")
public let kThemeColorRedProgress = UIColor(hexStr: "F5615D")

public let kThemeColorButtonUnable = UIColor(hexStr: "F5F6FA")
public let kThemeColorButtonUnableGary = UIColor(hexStr: "9B9EBB")
public let kThemeColorButtonUnableBlack = UIColor(hexStr: "434556")
public let kThemeColorSelected = UIColor(hexStr: "661FB9")

public let kThemeColorTextNormal = UIColor(hexStr: "291F59")
public let kThemeColorTextUnabled = UIColor(hexStr: "9B9EBB")

public let kThemeColorSeparatorBlack = ColorRGBA(r: 15.0, g: 17.0, b: 33.0, a: 1.0)
public let kThemeColorSeparator = UIColor(hexStr: "F5F6FA")
public let kThemeColorBorderGray = UIColor(hexStr: "F5F6FA")

public let kThemeColorNavigationBackButton = UIColor(white: 1.0, alpha: 0.6)

public let kSecuritylColorLevel1 = ColorRGB(r: 249.0, g: 216.0, b: 155.0)
public let kSecuritylColorLevel2 = ColorRGB(r: 245.0, g: 189.0, b: 93.0)
public let kSecuritylColorLevel3 = ColorRGB(r: 255.0, g:  77.0, b:  22.0)

public let kThemeColorDepthChartGreen = UIColor(hexStr: "55BC95").withAlphaComponent(0.5)
public let kThemeColorDepthChartGreenGradientEnd = UIColor(hexStr: "55BC95").withAlphaComponent(0.05)
public let kThemeColorDepthChartRed = UIColor(hexStr: "DF6767").withAlphaComponent(0.5)
public let kThemeColorDepthChartRedGradientEnd = UIColor(hexStr: "DF6767").withAlphaComponent(0.05)

public let kThemeFontLarge = UIFont.systemFont(ofSize: 18.0)
public let kThemeFontNormal = UIFont.systemFont(ofSize: 15.0)
public let kThemeFontSmall = UIFont.systemFont(ofSize: 12.0)
public func kThemeFontDINBold(_ size: CGFloat) -> UIFont { return UIFont(name: "DIN Alternate", size: size)! }
public let kThemeFontDINLarge = kThemeFontDINBold(18.0)
public let kThemeFontDINNormal = kThemeFontDINBold(15.0)
public let kThemeFontDINSmall = kThemeFontDINBold(12.0)

public let kNavigationBarHeight = IsInfinityScreen ? 88.0:64.0
public let kTabBarHeight = IsInfinityScreen ? 84.0:49.0
public let kContentOffsetInfinityScreen = IsInfinityScreen ? 24.0:0
public let kContentSpacing = 15.0

public var TheCurrentScreenOrientation = UIInterfaceOrientationMask.portrait

public let kThemeStyleImage = "<head><style>img{width:\(kScreenSize.width-40.0) !important;height:auto}</style></head>"

enum LoadingHUDPosition: Int {
    case viewCenter = 0
    case viewCenterTop = 1
    case viewCenterBottom = 2
    case navigationCenter = 3
    case navigationRight = 4
}

private var ___runtimeKeyViewPreviousBgColor: Void?
private var ___runtimeKeyImageContentType: Void?
private var ___runtimeKeyCornerRadiu: Void?
private var ___runtimeKeyBorderColor: Void?
private var ___runtimeKeyBorderWidth: Void?
private var ___runtimeKeyTitleColor: Void?

extension UIViewController {
    
    func themeSetup() -> Void {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(color: kThemeColorNavigationBar), for: .default)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : kThemeColorTextNormal
        ]
        
        self.navigationController?.navigationBar.barStyle = .default
        
        self.view.backgroundColor = kThemeColorBackground
        
        self.useCustomBackIcon()
    }
    
    func useCustomBackIcon() -> Void {
        if let controller = self as? BaseViewController, controller.isTopLevel == true {
            return
        }
        if let controller = self as? BaseTableViewController, controller.isTopLevel == true {
            return
        }
        
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon-backarrow"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(self.customBackAction), for: .touchUpInside)
        let backItem = UIBarButtonItem(customView: button)
        backItem.imageInsets = UIEdgeInsets(top: 0, left: -6.5, bottom: 0, right: 6.5)
        self.navigationItem.leftBarButtonItems = [backItem]
    }
    
    @objc func customBackAction() -> Void {
        self.pop()
    }
    
    func hideCustomBackButton() -> Void {
        if  let items = self.navigationItem.leftBarButtonItems,
            let customView = items.first?.customView,
            customView.tag == 8866 {
            customView.isHidden = true
        }
    }
    
}

extension UIView {
    
    @IBInspectable
    var thePreviousBgColor: UIColor? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyViewPreviousBgColor) as? UIColor
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyViewPreviousBgColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @IBInspectable
    var cornerRadius: String? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyCornerRadiu) as? String
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyCornerRadiu, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let value = newValue, let fvalue = Float(value), fvalue > 0 {
                self.addCorner(withRadius: fvalue)
            }
        }
    }
    
    @IBInspectable
    var borderColor: String? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyBorderColor) as? String
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyBorderColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let value = newValue, value.count > 0 {
                self.layer.borderColor = UIColor.fromHex(hexString: value).cgColor
            }
        }
    }
    
    @IBInspectable
    var borderWidth: String? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyBorderWidth) as? String
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyBorderWidth, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let value = newValue, let fvalue = Float(value), fvalue > 0 {
                self.layer.borderWidth = CGFloat(fvalue)
            }
        }
    }
    
}

extension UIButton {
    
    @IBInspectable
    var imageContentType: String? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyImageContentType) as? String
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyImageContentType, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let value = newValue {
                if value == "0" {
                    self.imageView?.contentMode = .scaleToFill
                } else if value == "1" {
                    self.imageView?.contentMode = .scaleAspectFit
                }
            }
        }
    }
    
    @IBInspectable
    var titleColor: String? {
        get {
            return objc_getAssociatedObject(self, &___runtimeKeyTitleColor) as? String
        }
        set {
            objc_setAssociatedObject(self, &___runtimeKeyTitleColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let value = newValue, value.count > 0 {
                self.setTitleColor(UIColor.fromHex(hexString: value), for: .normal)
            }
        }
    }
    
}

extension UIColor {
    
    static func fromHex(hexString: String) -> UIColor{
        
        var cString: String = hexString.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        
        if cString.count < 6 {
            return UIColor.black
        }
        if cString.hasPrefix("0X") {
            cString = String(cString[cString.index(cString.startIndex, offsetBy: 2) ..< cString.endIndex])
        }
        if cString.hasPrefix("#") {
            cString = String(cString[cString.index(cString.startIndex, offsetBy: 1) ..< cString.endIndex])
        }
        if cString.count != 6 {
            return UIColor.black
        }
        
        var range: NSRange = NSMakeRange(0, 2)
        let rString = (cString as NSString).substring(with: range)
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: UInt32 = 0x0
        var g: UInt32 = 0x0
        var b: UInt32 = 0x0
        Scanner.init(string: rString).scanHexInt32(&r)
        Scanner.init(string: gString).scanHexInt32(&g)
        Scanner.init(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(1.0))
        
    }
    
}

@IBDesignable
public class StackView: UIStackView {
    
    @IBInspectable private var color: UIColor?
    override public var backgroundColor: UIColor? {
        get { return color }
        set {
            color = newValue
            self.setNeedsLayout()
        }
    }
    
    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.insertSublayer(layer, at: 0)
        return layer
    }()
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayer.path = UIBezierPath(rect: self.bounds).cgPath
        backgroundLayer.fillColor = self.backgroundColor?.cgColor
    }
    
}

// MARK: Business.
public func PriceColor(withDirection direction: PriceDirectionEnum) -> UIColor {
    switch direction {
    case .up:
        return kThemeColorGreen
    case .down:
        return kThemeColorRed
    default:
        return kThemeColorTextNormal
    }
}

public func DirectionSymbol(withDirection direction: PriceDirectionEnum) -> String {
    switch direction {
    case .up:
        return "+"
    case .down:
        return "-"
    default:
        return ""
    }
}

public func OrderActionColor(withAction action: OrderActionEnum) -> UIColor {
    switch action {
    case .buy:
        return kThemeColorGreen
    case .sell:
        return kThemeColorRed
    }
}
