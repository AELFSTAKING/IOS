//
//  AELFWalletModel.swift
//  AELFExchange
//
//  Created by tng on 2019/7/31.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON
import CryptoSwift

class AELFWalletModel: HandyJSON {
    
    /// 名称.
    @objc dynamic var name: String?
    
    /// 币种.
    @objc dynamic var currency: String?
    
    /// 链名.
    @objc dynamic var chain: String?
    
    /// 私钥.
    @objc dynamic fileprivate var privateKeyValue: String?
    @objc dynamic var privateKey: String? {
        set {
            do {
                let aes = try AES(key: Consts.kAESKey, iv: Consts.kAESIV)
                if let pwd = newValue {
                    let ret = try aes.encrypt(Array(pwd.utf8))
                    if let encrypted = ret.toBase64() {
                        self.privateKeyValue = encrypted
                    }
                }
            } catch {
                self.privateKeyValue = newValue
            }
        }
        get {
            do {
                if let pwdValue = self.privateKeyValue,
                    let data = Data(base64Encoded: pwdValue)?.bytes {
                    let aes = try AES(key: Consts.kAESKey, iv: Consts.kAESIV)
                    let ret = try aes.decrypt(data)
                    if let decrypted = String(data: Data(ret), encoding: .ascii) {
                        return decrypted
                    }
                    return self.privateKeyValue
                }
            } catch {
                logerror(content: error.localizedDescription)
            }
            return self.privateKeyValue
        }
    }
    
    /// 公钥.
    @objc dynamic var publicKey: String?
    
    /// 地址.
    @objc dynamic var address: String?
    
    /// 路径.
    @objc dynamic var path: String?
    
    /// 助记词（通过本应用创建才存在助记词）.
    @objc dynamic var mnemonic: String?
    
    required init() {}
    
}
