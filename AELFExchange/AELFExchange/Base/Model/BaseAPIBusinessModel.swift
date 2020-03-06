//
//  BaseAPIBusinessModel.swift
//  AELF
//
//  Created by tng on 2018/10/18.
//  Copyright © 2018 AELF. All rights reserved.
//

import Foundation
import HandyJSON

class BaseAPIBusinessPagination: HandyJSON {
    
    /// 总共多少页.
    var pageSize: Int?
    
    /// 当前页码.
    var currPage: Int?
    
    /// 总共行数.
    var totalRows: Int?
    
    /// 单页行数，即分页大小.
    var pageRows: Int?
    
    required init() {}
    
}

class BaseAPIBusinessModel: HandyJSON {
    
    /// 响应码.
    var code: String?
    var respCode: String?
    
    /// 消息.
    var msg: String?
    
    /// .
    var traceId: String?
    
    var succeed: Bool {
        get {
            return (self.respCode ?? "0" == "000000") || (self.code ?? "0" == "000000")
        }
    }
    
    required init() {}
    
    convenience required init(msg: String?) {
        self.init()
        self.msg = msg
    }
    
}
