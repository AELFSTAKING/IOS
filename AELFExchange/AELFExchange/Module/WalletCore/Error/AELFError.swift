//
//  AELFError.swift
//  AELFExchange
//
//  Created by tng on 2019/7/31.
//  Copyright © 2019 cex.io. All rights reserved.
//

import Foundation

enum AELFWalletError: Error {
    
    /// 参数错误.
    case invalidParams
    
    /// 空内容.
    case emptyContent
    
    /// 账户不存在.
    case noSuchAccount
    
    /// 钱包不存在.
    case noSuchWallet
    
    /// 私钥读取失败.
    case noSuchPrivateKey
    
    /// 去中心化钱包身份不存在.
    case noSuchWalletIdentity
    
    /// 内容已存在.
    case alreadyExist
    
    /// 账户名称不正确.
    case invalidAccountName
    
    /// 密码错误.
    case invalidPassword
    
    /// 操作失败.
    case operationFailed
    
    /// 操作已取消.
    case canceled
    
    /// 服务不可用.
    case unavailable
    
    /// 未知错误.
    case unknown
    
}
