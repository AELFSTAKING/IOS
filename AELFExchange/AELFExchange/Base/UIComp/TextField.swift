//
//  TextField.swift
//  AELFExchange
//
//  Created by tng on 2019/1/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TextField: UITextField {
    
    let spacingDefault: CGFloat = 10.0
    var leading: CGFloat = 10.0
    var trailing: CGFloat = 10.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    @IBInspectable
    var allowedEdting: String? {
        didSet {
            if let _ = allowedEdting {
                self.delegate = self
            }
        }
    }
    
    lazy var countryButton: UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: 0, width: 85.0, height: self.frame.size.height)
        b.titleLabel?.font = kThemeFontNormal
        b.setTitleColor(kThemeColorTextNormal, for: .normal)
        b.setTitle(LOCSTR(withKey: "国家/地区"), for: .normal)
        
        let sep = UIView(frame: CGRect(x: b.frame.size.width-1.0, y: 6.0, width: 0.65, height: b.frame.size.height-12.0))
        sep.backgroundColor = kThemeColorBorderGray
        b.addSubview(sep)
        return b
    }()
    lazy var areaModeGestureButton: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = .clear
        return b
    }()
    @IBInspectable
    var Area: String? {
        didSet {
            if Area == "1" {
                self.setPlaceholder(with: "请选择地区")
                self.leading = self.countryButton.frame.size.width
                self.leftViewMode = .always
                self.leftView = self.countryButton
                
                self.addSubview(self.areaModeGestureButton)
                self.areaModeGestureButton.snp.makeConstraints { (make) in
                    make.edges.equalTo(self)
                }
                
                self.setNeedsLayout()
            }
        }
    }
    
    lazy var areaButton: UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: 0, width: 85.0, height: self.frame.size.height)
        b.titleLabel?.font = kThemeFontNormal
        b.setTitleColor(kThemeColorTextNormal, for: .normal)
        b.setTitle("+86", for: .normal)
        
        let sep = UIView(frame: CGRect(x: b.frame.size.width-1.0, y: 6.0, width: 0.65, height: b.frame.size.height-12.0))
        sep.backgroundColor = kThemeColorBorderGray
        b.addSubview(sep)
        return b
    }()
    @IBInspectable
    var Phone: String? {
        didSet {
            if Phone == "1" {
                self.setPlaceholder(with: "请输入手机号码")
                self.leading = self.areaButton.frame.size.width
                self.keyboardType = .numberPad
                self.leftViewMode = .always
                self.leftView = self.areaButton
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var Email: String? {
        didSet {
            if Email == "1" {
                self.setPlaceholder(with: "请输入邮箱")
                self.leading = spacingDefault
                self.keyboardType = .emailAddress
                self.leftViewMode = .never
                self.leftView = nil
                self.setNeedsLayout()
            }
        }
    }
    
    private lazy var securityButton: UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: 0, width: 35.0, height: 35.0)
        b.setTitleColor(kThemeColorSelected, for: .normal)
        b.setImage(UIImage(named: "icon-pwd-off"), for: .normal)
        b.setImage(UIImage(named: "icon-pwd-on"), for: .selected)
        b.addTarget(self, action: #selector(self.passwordAppearance), for: .touchUpInside)
        return b
    }()
    @IBInspectable
    var Password: String? {
        didSet {
            if Password == "1" {
                self.setPlaceholder(with: "请输入密码")
                self.trailing = self.securityButton.frame.size.width
                self.isSecureTextEntry = true
                self.rightViewMode = .always
                self.rightView = self.securityButton
                self.delegate = self
                self.setNeedsLayout()
            }
        }
    }
    @IBInspectable
    var PasswordConfirm: String? {
        didSet {
            if PasswordConfirm == "1" {
                self.setPlaceholder(with: "请再次输入密码")
                self.trailing = self.securityButton.frame.size.width
                self.isSecureTextEntry = true
                self.rightViewMode = .always
                self.rightView = self.securityButton
                self.delegate = self
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var InviteCode: String? {
        didSet {
            if InviteCode == "1" {
                self.setPlaceholder(with: "邀请码")
                self.setNeedsLayout()
            }
        }
    }
    
    lazy var sendCodeButton: UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: self.frame.size.width-92.0, width: 92.0, height: self.frame.size.height)
        b.setTitleColor(.white, for: .normal)
        b.setTitle(LOCSTR(withKey: "获取验证码"), for: .normal)
        b.titleLabel?.numberOfLines = 5
        b.titleLabel?.font = kThemeFontSmall
        b.backgroundColor = kThemeColorTextNormal
        return b
    }()
    @IBInspectable
    var VerifyCode: String? {
        didSet {
            if VerifyCode == "1" {
                self.setPlaceholder(with: "请输入验证码")
                self.trailing = self.sendCodeButton.frame.size.width
                self.keyboardType = .numberPad
                self.rightViewMode = .always
                self.rightView = self.sendCodeButton
                self.delegate = self
                self.setNeedsLayout()
            }
        }
    }
    func hideSendCodeButton(withPlaceHolder placeHolder: String? = nil) -> Void {
        self.sendCodeButton.isHidden = true
        self.trailing = 10.0
        if let placeHolder = placeHolder {
            self.setPlaceholder(with: placeHolder)
        }
        self.setNeedsLayout()
    }
    
    @IBInspectable
    var FishCode: String? {
        didSet {
            if FishCode == "1" {
                self.setPlaceholder(with: "请输入6位字符，允许大小写字母和数字")
                self.setNeedsLayout()
            }
        }
    }
    
    lazy var searchIcon: UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: 0, width: 35.0, height: self.frame.size.height)
        b.imageView?.contentMode = .scaleAspectFit
        b.backgroundColor = .clear
        b.setImage(UIImage(named: "icon-textfield-searchicon"), for: .normal)
        b.isUserInteractionEnabled = false
        return b
    }()
    @IBInspectable
    var SearchMode: String? {
        didSet {
            if SearchMode == "1" {
                self.setPlaceholder(with: "请输入关键字搜索")
                self.leading = self.searchIcon.frame.size.width-10.0
                self.leftViewMode = .always
                self.leftView = self.searchIcon
                self.setNeedsLayout()
            }
        }
    }
    
    lazy var priceButtonLeft: UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: 0, width: 40.0, height: self.frame.size.height)
        b.imageView?.contentMode = .scaleAspectFit
        b.backgroundColor = .clear
        b.setImage(UIImage(named: "icon-price-reduce"), for: .normal)
        
        let sep = UIView(frame: CGRect(x: b.frame.size.width-1.0, y: 0, width: 0.65, height: b.frame.size.height))
        sep.backgroundColor = kThemeColorBorderGray
        b.addSubview(sep)
        return b
    }()
    lazy var priceButtonRight: UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: 0, width: 40.0, height: self.frame.size.height)
        b.imageView?.contentMode = .scaleAspectFit
        b.backgroundColor = .clear
        b.setImage(UIImage(named: "icon-price-increase"), for: .normal)
        
        let sep = UIView(frame: CGRect(x: 0, y: 0, width: 0.65, height: b.frame.size.height))
        sep.backgroundColor = kThemeColorBorderGray
        b.addSubview(sep)
        return b
    }()
    @IBInspectable
    var PriceMode: String? {
        didSet {
            if PriceMode == "1" {
                self.leading = self.priceButtonLeft.frame.size.width-7.0
                self.trailing = self.priceButtonRight.frame.size.width+3.0
                self.leftViewMode = .always
                self.leftView = self.priceButtonLeft
                self.rightViewMode = .always
                self.rightView = self.priceButtonRight
                self.textAlignment = .center
                self.setNeedsLayout()
            }
        }
    }
    
    lazy var quantityModeLeft: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 50.0, height: self.frame.size.height)
        button.setTitleColor(kThemeColorTextNormal, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: LanguageManager.shared().currentLanguage() == .ZH_HANS ? 13.0:10.0)
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10.0, bottom: 0, right: 0)
        button.setTitle(LOCSTR(withKey: "数量"), for: .normal)
        return button
    }()
    lazy var quantityModeRight: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 50.0, height: self.frame.size.height)
        button.setTitleColor(kThemeColorTextNormal, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13.0)
        button.contentHorizontalAlignment = .right
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10.0)
        button.setTitle("--", for: .normal)
        return button
    }()
    @IBInspectable
    var QuantityMode: String? {
        didSet {
            if QuantityMode == "1" {
                self.leading = self.quantityModeLeft.frame.size.width-7.0
                self.trailing = self.quantityModeRight.frame.size.width+3.0
                self.leftViewMode = .always
                self.leftView = self.quantityModeLeft
                self.rightViewMode = .always
                self.rightView = self.quantityModeRight
                self.textAlignment = .center
                self.setNeedsLayout()
            }
        }
    }
    
    lazy var dateIconButton: UIButton = {
        let b = UIButton(type: .custom)
        b.frame = CGRect(x: 0, y: 0, width: 55.0, height: self.frame.size.height)
        b.setImage(UIImage(named: "icon-Identity-date"), for: .normal)
        return b
    }()
    lazy var dateModeGestureButton: UIButton = {
        let b = UIButton(type: .custom)
        b.backgroundColor = .clear
        return b
    }()
    @IBInspectable
    var DateMode: String? {
        didSet {
            if DateMode == "1" {
                self.setPlaceholder(with: "请选择日期")
                self.rightViewMode = .always
                self.rightView = self.dateIconButton
                
                self.addSubview(self.dateModeGestureButton)
                self.dateModeGestureButton.snp.makeConstraints { (make) in
                    make.edges.equalTo(self)
                }
                
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var FormMode: String? {
        didSet {
            if FormMode == "1" {
                self.backgroundColor = kThemeColorButtonUnable
                self.font = UIFont.systemFont(size: 13.0)
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var NoBorder: String? {
        didSet {
            if NoBorder == "1" {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 0.0
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var NoRadius: String? {
        didSet {
            if NoRadius == "1" {
                self.layer.cornerRadius = 0.0
                self.setNeedsLayout()
            }
        }
    }
    
    @IBInspectable
    var NoPadding: String? {
        didSet {
            if NoPadding == "1" {
                self.leading = 0.0
                self.trailing = 0.0
                self.setNeedsLayout()
            }
        }
    }
    
    func commonInit() -> Void {
        self.textColor = kThemeColorTextNormal
        self.font = kThemeFontNormal
        self.borderStyle = .none
        self.backgroundColor = .clear
        self.clearButtonMode = .never
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.addCorner(withRadius: 3.0)
        self.addBorder(withWitdh: 0.65, color: kThemeColorBorderGray)
        self.setNeedsLayout()
    }
    
    func setPlaceholder(with: String, font: UIFont = kThemeFontNormal) -> Void {
        let attr = NSMutableAttributedString(string: LOCSTR(withKey: with))
        let option = [
            NSAttributedString.Key.font:font,
            NSAttributedString.Key.foregroundColor:kThemeColorTextUnabled
        ]
        attr.addAttributes(option, range: NSRange(location: 0, length: attr.length))
        self.attributedPlaceholder = attr
    }
    
}

// MARK: - Rect.
extension TextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: leading+spacingDefault, y: bounds.origin.y, width: bounds.size.width-leading-trailing-spacingDefault, height: bounds.size.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: leading+spacingDefault, y: bounds.origin.y, width: bounds.size.width-leading-trailing-spacingDefault, height: bounds.size.height)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: leading+spacingDefault, y: bounds.origin.y, width: bounds.size.width-leading-trailing-spacingDefault, height: bounds.size.height)
    }
    
}

// MARK: - Password.
extension TextField: UITextFieldDelegate {
    
    @objc func passwordAppearance() -> Void {
        self.securityButton.isSelected.toggle()
        self.isSecureTextEntry.toggle()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if self.Password == "1" || self.PasswordConfirm == "1" {
            return !string.containsEmoj()
        } else if self.VerifyCode == "1" {
            return (textField.text ?? "" + string).count < 6 || string.count == 0
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let allow = self.allowedEdting, allow != "1" { return false }
        return true
    }
    
}

extension TextField {
    
    func updateAreaCode(to code: String) -> Void {
        self.areaButton.setTitle(code, for: .normal)
    }
    
}
