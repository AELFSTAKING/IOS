//
//  AELFIdentity.swift
//  AELFExchange
//
//  Created by tng on 2019/8/1.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import PromiseKit
import CryptoSwift
import ReactiveSwift
import Result

class AELFIdentity {
    
    fileprivate static let ___donotUseThisVariableOfAELFIdentity = AELFIdentity()
    
    @discardableResult
    static func shared() -> AELFIdentity {
        return AELFIdentity.___donotUseThisVariableOfAELFIdentity
    }
    
    let (identityRemovedSignal, identityRemovedObserver) = Signal<Bool, NoError>.pipe()
    
    static var wallet_eth: AELFWalletModel? {
        return AELFWalletManager.shared().wallet_eth
    }
    
    // MARK: - Identity Storages.
    var identity: AELFIdentityModel? {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "wallet_identity") as? String {
                return AELFIdentityModel.deserialize(from: theInstance)
            }
            return nil
        }
        set {
            if let obj = newValue, let value = obj.toJSONString() {
                UserDefaults.standard.setValue(value, forKey: "wallet_identity")
            } else {
                UserDefaults.standard.removeObject(forKey: "wallet_identity")
            }
            UserDefaults.standard.synchronize()
        }
    }
    
}

// MARK: - Common Methods.
extension AELFIdentity {
    
    static func hasIdentity() -> Bool {
        return AELFIdentity.shared().identity != nil
    }
    
    func auth() -> Promise<(succeed: Bool, password: String)> {
        return Promise { seal in
            guard let id = self.identity else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.noSuchAccount) }
                return
            }
            
            let controller = UIAlertController(title: "请输入账户密码", message: nil, preferredStyle: .alert)
            controller.addTextField { (textField) in
                textField.placeholder = "至少8个字符（包括大小写和数字）"
                textField.isSecureTextEntry = true
                textField.clearButtonMode = .whileEditing
            }
            controller.addAction(UIAlertAction(title: LOCSTR(withKey: "确定"), style: .default, handler: { (_) in
                let text = controller.textFields![0].text
                DispatchQueue.main.async { seal.resolve((id.password == text, text!), nil) }
            }))
            controller.addAction(UIAlertAction(title: LOCSTR(withKey: "取消"), style: .cancel, handler: { (_) in }))
            TopController().present(controller, animated: true, completion: {})
        }
    }
    
    func importIdentity(withName name: String, password: String, privateKey: String) -> Promise<AELFIdentityModel?> {
        return Promise { seal in
            guard name.count > 0, password.count > 0, privateKey.count > 0 else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.invalidParams) }
                return
            }
            
            let isFirstTimeToImport = (self.identity == nil)
            
            let newIdentity = AELFIdentityModel()
            newIdentity.name = name
            newIdentity.password = password
            self.identity = nil
            self.identity = newIdentity
            
            firstly {
                AELFWalletManager.importEthereumWallet(withPrivateKey: privateKey.contains("0x") ? privateKey:"0x\(privateKey)")
                }.done { (walletModel) in
                    DispatchQueue.main.async { seal.resolve(newIdentity, nil) }
                }.catch { (error) in
                    if isFirstTimeToImport {
                        self.identity = nil
                    }
                    DispatchQueue.main.async { seal.reject(error) }
            }
        }
    }
    
    func createIdentity(withName name: String, password: String) -> Promise<AELFIdentityModel?> {
        return Promise { seal in
            guard name.count > 0, password.count > 0 else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.invalidParams) }
                return
            }
            
            let newIdentity = AELFIdentityModel()
            newIdentity.name = name
            newIdentity.password = password
            self.identity = nil
            self.identity = newIdentity
            
            firstly {
                AELFWalletManager.createEthereumWallet()
                }.done { (walletModel) in
                    DispatchQueue.main.async { seal.resolve(newIdentity, nil) }
                }.catch { (error) in
                    DispatchQueue.main.async { seal.reject(error) }
            }
        }
    }
    
    func modifyName(withLastName lastName: String, newName: String) -> Promise<AELFIdentityModel?> {
        return Promise { seal in
            guard lastName.count > 0, newName.count > 0 else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.invalidParams) }
                return
            }
            
            guard let identity = self.identity else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.noSuchAccount) }
                return
            }
            
            guard lastName == identity.name else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.invalidAccountName) }
                return
            }
            
            let newIdentity = AELFIdentityModel()
            newIdentity.name = newName
            newIdentity.password = identity.password
            newIdentity.updateddAt = timestampms()
            self.identity = nil
            self.identity = newIdentity
            DispatchQueue.main.async { seal.resolve(newIdentity, nil) }
        }
    }
    
    func modifyPassword(withLastPwd lastPwd: String, newPwd: String, accountName: String) -> Promise<AELFIdentityModel?> {
        return Promise { seal in
            guard lastPwd.count > 0, newPwd.count > 0 else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.invalidParams) }
                return
            }
            
            guard let identity = self.identity else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.noSuchAccount) }
                return
            }
            
            guard accountName == identity.name else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.invalidAccountName) }
                return
            }
            
            guard lastPwd == identity.password else {
                DispatchQueue.main.async { seal.reject(AELFWalletError.invalidPassword) }
                return
            }
            
            let newIdentity = AELFIdentityModel()
            newIdentity.name = identity.name
            newIdentity.password = newPwd
            newIdentity.updateddAt = timestampms()
            self.identity = nil
            self.identity = newIdentity
            DispatchQueue.main.async { seal.resolve(newIdentity, nil) }
        }
    }
    
    func removeIdentity() {
        self.identity = nil
        AELFWalletManager.shared().wallet_eth = nil
        self.identityRemovedObserver.send(value: true)
    }
    
}

// MARK: - Others.
extension AELFIdentity {
    
    static func errorToast(withError error: Error) {
        guard let error = error as? AELFWalletError else {
            InfoToast(withLocalizedTitle: "错误")
            return
        }
        switch error {
        case .invalidParams:
            InfoToast(withLocalizedTitle: "参数错误")
        case .emptyContent:
            InfoToast(withLocalizedTitle: "空内容")
        case .noSuchAccount:
            InfoToast(withLocalizedTitle: "账户不存在")
        case .noSuchWallet:
            InfoToast(withLocalizedTitle: "钱包不存在")
        case .noSuchPrivateKey:
            InfoToast(withLocalizedTitle: "私钥读取失败")
        case .noSuchWalletIdentity:
            InfoToast(withLocalizedTitle: "去中心化钱包身份不存在")
        case .alreadyExist:
            InfoToast(withLocalizedTitle: "内容已存在")
        case .invalidAccountName:
            InfoToast(withLocalizedTitle: "原账户名称不正确")
        case .invalidPassword:
            InfoToast(withLocalizedTitle: "原密码错误")
        case .operationFailed:
            InfoToast(withLocalizedTitle: "操作失败")
        case .canceled:
            InfoToast(withLocalizedTitle: "操作已取消")
        case .unavailable:
            InfoToast(withLocalizedTitle: "服务不可用")
        default:
            InfoToast(withLocalizedTitle: "错误")
        }
    }

}
