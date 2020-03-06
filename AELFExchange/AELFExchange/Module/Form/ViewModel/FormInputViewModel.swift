//
//  FormInputViewModel.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift

/// 页面类型.
enum FormInputMode {
    
    /// 创建ETH账户.
    case createETHWallet
    
    /// 导入ETH账户.
    case importETHWallet
    
    /// 修改账户名称.
    case modifyAccountName
    
    /// 重置账户密码.
    case resetAccountPassword
    
    /// 绑定跨链充值地址.
    case bindCrossChainTopupAddress
    
}

enum RightButtonItemType {
    
    /// 导入私钥扫码.
    case scanForImport
    
}

class FormInputViewItem {
    
    /// 标题.
    var title: String?
    
    /// 占位文本.
    var placeHolder: String?
    
    /// 默认值.
    var defaultValue: String?
    
    /// 校验失败时提示消息.
    var emptyToast: String?
    
    /// 参数组装后的key.
    var requestParamKey: String?
    
    /// 校验正则.
    var regex: String?
    
    /// 与`requestParamKey`进行 `equal` 的二次校验.
    var repeatForParamKey: String?
    
    /// 右侧按钮图标.
    var rightButtonIcon: UIImage?
    var rightButtonType: RightButtonItemType?
    
    /// 密码输入.
    var isSecurity = false
    
    /// 是否不允许为空.
    var required = true
    
    /// 是否可编辑.
    var enabled = true
    
    convenience init(
        title: String?,
        placeHolder: String?,
        defaultValue: String? = nil,
        emptyToast: String?,
        requestParamKey: String? = nil,
        regex: String? = nil,
        repeatForParamKey: String? = nil,
        rightButtonIcon: UIImage? = nil,
        rightButtonType: RightButtonItemType? = nil,
        isSecurity: Bool = false,
        required: Bool = true,
        enabled: Bool = true
    ) {
        self.init()
        self.title = title
        self.placeHolder = placeHolder
        self.defaultValue = defaultValue
        self.emptyToast = emptyToast
        self.requestParamKey = requestParamKey
        self.regex = regex
        self.rightButtonIcon = rightButtonIcon
        self.rightButtonType = rightButtonType
        self.repeatForParamKey = repeatForParamKey
        self.isSecurity = isSecurity
        self.required = required
        self.enabled = enabled
    }
    
}

@objc class FormInputViewModel: NSObject {
    
    let (loadedSignal, loadedObserver) = Signal<Bool, NoError>.pipe()
    let (completedSignal, completedObserver) = Signal<Bool, NoError>.pipe()
    
    var mode: FormInputMode? {
        didSet {
            if let _ = mode {
                self.load()
            }
        }
    }
    
    var forms = [FormInputViewItem]()
    var confirmButtonTitle = LOCSTR(withKey: "确定")
    var title = ""
    var footerInfo: NSAttributedString?
    
    /// Page Transform.
    var shouldPopAutomatically = false
    
    /// Outter References.
    weak var controller: UIViewController?
    weak var tableView: UITableView?
    
    // MARK: 特殊处理-跨链充值参数.
    //
    /// 跨链充值 - 原链名称.
    var chain = ""
    /// 跨链充值 - 当前币种名称.
    var currency = ""
    
    func load() {
        switch self.mode! {
        case .createETHWallet:
            self.title = LOCSTR(withKey: "创建充值帐户")
            self.confirmButtonTitle = LOCSTR(withKey: "立即创建")
            self.forms = [
                FormInputViewItem(
                    title: "账户名称",
                    placeHolder: "16个字符以内",
                    emptyToast: "请输入账户名称",
                    requestParamKey: "accountName",
                    regex: Consts.kRegexAccountName
                ),
                FormInputViewItem(
                    title: "设置密码",
                    placeHolder: "至少8个字符（包括大小写和数字）",
                    emptyToast: "请输入密码",
                    requestParamKey: "password",
                    regex: Consts.kRegexLoginPwd,
                    isSecurity: true
                ),
                FormInputViewItem(
                    title: "确认密码",
                    placeHolder: "请再次输入密码",
                    emptyToast: "请再次输入密码",
                    regex: Consts.kRegexLoginPwd,
                    repeatForParamKey: "password",
                    isSecurity: true
                )
            ]
            break
        case .importETHWallet:
            self.title = LOCSTR(withKey: "导入ETH账户")
            self.confirmButtonTitle = LOCSTR(withKey: "导入")
            self.forms = [
                FormInputViewItem(
                    title: "私钥",
                    placeHolder: "请输入或粘贴私钥",
                    emptyToast: "请输入或粘贴私钥",
                    requestParamKey: "privateKey"
                ),
                FormInputViewItem(
                    title: "帐户名称",
                    placeHolder: "16个字符以内",
                    emptyToast: "请设置帐户名称",
                    requestParamKey: "accountName",
                    regex: Consts.kRegexAccountName
                ),
                FormInputViewItem(
                    title: "设置密码",
                    placeHolder: "至少8个字符（包括大小写和数字）",
                    emptyToast: "请输入密码",
                    requestParamKey: "password",
                    regex: Consts.kRegexLoginPwd,
                    isSecurity: true
                ),
                FormInputViewItem(
                    title: "确认密码",
                    placeHolder: "请再次输入密码",
                    emptyToast: "请再次输入密码",
                    regex: Consts.kRegexLoginPwd,
                    repeatForParamKey: "password",
                    isSecurity: true
                )
            ]
            break
        case .modifyAccountName:
            self.title = LOCSTR(withKey: "修改账户名称")
            self.confirmButtonTitle = LOCSTR(withKey: "确认")
            self.forms = [
                FormInputViewItem(
                    title: "原账户名称",
                    placeHolder: "请输入原账户名称",
                    defaultValue: AELFIdentity.shared().identity?.name,
                    emptyToast: "请输入原账户名称",
                    requestParamKey: "oldName",
                    regex: Consts.kRegexAccountName,
                    enabled: false
                ),
                FormInputViewItem(
                    title: "新账户名称",
                    placeHolder: "16个字符以内",
                    emptyToast: "请输入新账户名称",
                    requestParamKey: "newName",
                    regex: Consts.kRegexAccountName
                )
            ]
            break
        case .resetAccountPassword:
            self.title = LOCSTR(withKey: "重置账户密码")
            self.confirmButtonTitle = LOCSTR(withKey: "设置")
            self.forms = [
                FormInputViewItem(
                    title: "账户名称",
                    placeHolder: "请输入账户名称",
                    defaultValue: AELFIdentity.shared().identity?.name,
                    emptyToast: "请输入账户名称",
                    requestParamKey: "accountName",
                    regex: Consts.kRegexAccountName,
                    enabled: false
                ),
                FormInputViewItem(
                    title: "原密码",
                    placeHolder: "请输入原密码",
                    emptyToast: "请输入原密码",
                    requestParamKey: "oldPassword",
                    isSecurity: true
                ),
                FormInputViewItem(
                    title: "新密码",
                    placeHolder: "至少8个字符（包括大小写和数字）",
                    emptyToast: "请输入密码",
                    requestParamKey: "password",
                    regex: Consts.kRegexLoginPwd,
                    isSecurity: true
                ),
                FormInputViewItem(
                    title: "确认密码",
                    placeHolder: "请再次输入密码",
                    emptyToast: "请再次输入密码",
                    regex: Consts.kRegexLoginPwd,
                    repeatForParamKey: "password",
                    isSecurity: true
                )
            ]
            break
        case .bindCrossChainTopupAddress:
            self.title = "\(self.currency)\(LOCSTR(withKey: "跨链充值"))"
            self.confirmButtonTitle = LOCSTR(withKey: "绑定")
            self.forms = [
                FormInputViewItem(
                    title: "\(self.chain)原链地址",
                    placeHolder: "请输入或粘贴\(self.chain)地址",
                    emptyToast: "请输入或粘贴\(self.chain)地址",
                    requestParamKey: "baseAddress"
                ),
                FormInputViewItem(
                    title: "备注名",
                    placeHolder: "请输入备注名",
                    emptyToast: "请输入备注名",
                    requestParamKey: "name"
                )
            ]
            break
        }
        self.loadedObserver.send(value: true)
    }
    
}

// MARK: - Common.
extension FormInputViewModel {
    
    func formValidation() -> Bool {
        for i in 0..<self.forms.count {
            if  let cell = self.tableView?.cellForRow(at: IndexPath(row: i, section: 0)) as? FormInputCell,
                let textfield = cell.textfield {
                
                // Empty.
                let formItem = self.forms[i]
                if (formItem.required && (textfield.text?.count ?? 0) == 0) {
                    InfoToast(withTitle: formItem.emptyToast)
                    return false
                }
                
                // Regex Match.
                if let regex = formItem.regex, regex.count > 0 {
                    if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: textfield.text ?? "") {
                        InfoToast(withTitle: "\(formItem.title ?? "") \(LOCSTR(withKey: "格式有误"))")
                        return false
                    }
                }
                
                // Repeat Input.
                if let repeatKey = formItem.repeatForParamKey, repeatKey.count > 0 {
                    let currentText = textfield.text ?? ""
                    for j in 0..<self.forms.count {
                        let targetValidateItem = self.forms[j]
                        guard targetValidateItem.requestParamKey == repeatKey else {
                            continue
                        }
                        
                        if  let targetValidateCell = self.tableView?.cellForRow(at: IndexPath(row: j, section: 0)) as? FormInputCell,
                            let targetValidateTextValue = targetValidateCell.textfield.text,
                            targetValidateTextValue != currentText {
                            InfoToast(withTitle: "两次输入不一致")
                            return false
                        }
                        break
                    }
                }
                
            }
        }
        return true
    }
    
    func assembleFormFields() -> [String : Any] {
        var params = [String : Any]()
        for i in 0..<self.forms.count {
            if  let cell = self.tableView?.cellForRow(at: IndexPath(row: i, section: 0)) as? FormInputCell,
                let textfield = cell.textfield {
                let formItem = self.forms[i]
                guard (formItem.requestParamKey?.count ?? 0) > 0 else {
                    continue
                }
                params[formItem.requestParamKey!] = textfield.text ?? ""
            }
        }
        return params
    }
    
    func submit() {
        switch self.mode {
        case .createETHWallet?:
            self.createWalletAccount()
        case .importETHWallet?:
            self.importWalletAccount()
        case .modifyAccountName?:
            self.modifyWalletName()
        case .resetAccountPassword?:
            self.resetWalletPassword()
        case .bindCrossChainTopupAddress?:
            self.bindCrossChainTopupAddress()
        default:break
        }
    }
    
}
