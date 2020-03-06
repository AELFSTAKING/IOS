//
//  AELFIdentityModel.swift
//  AELFExchange
//
//  Created by tng on 2019/8/1.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation
import HandyJSON
import CryptoSwift

class AELFIdentityModel: HandyJSON {
    
    /// 名称.
    @objc dynamic var name: String?
    
    /// 密码.
    @objc dynamic fileprivate var passwordValue: String?
    @objc dynamic var password: String? {
        set {
            do {
                let aes = try AES(key: Consts.kAESKey, iv: Consts.kAESIV)
                if let pwd = newValue {
                    let ret = try aes.encrypt(Array(pwd.utf8))
                    if let encrypted = ret.toBase64() {
                        self.passwordValue = encrypted
                    }
                }
            } catch {
                self.passwordValue = newValue
            }
        }
        get {
            do {
                if let pwdValue = self.passwordValue,
                    let data = Data(base64Encoded: pwdValue)?.bytes {
                    let aes = try AES(key: Consts.kAESKey, iv: Consts.kAESIV)
                    let ret = try aes.decrypt(data)
                    if let decrypted = String(data: Data(ret), encoding: .ascii) {
                        return decrypted
                    }
                    return self.passwordValue
                }
            } catch {
                logerror(content: error.localizedDescription)
            }
            return self.passwordValue
        }
    }
    
    /// 创建时间.
    @objc dynamic var createdAt = timestampms()
    
    /// 更新时间.
    @objc dynamic var updateddAt: String?
    
    required init() {}
    
}
