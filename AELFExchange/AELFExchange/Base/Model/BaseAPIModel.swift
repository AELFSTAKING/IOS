//
//  BaseAPIModel.swift
//  AELF
//
//  Created by tng on 2018/10/15.
//  Copyright © 2018 AELF. All rights reserved.
//

import Foundation
import HandyJSON

class BaseAPIModel: HandyJSON {
    
    /// 加密后的响应数据.
    var data: String?
    
    /// 时间戳.
    var timestamp: String?
    
    /// 随机干扰码.
    var nonce: String?
    
    /// 签名.
    var signature: String?
    
    /// 响应码.
    var code: String?
    
    /// 消息.
    var msg: String?
    
    required init() {}
    
}
