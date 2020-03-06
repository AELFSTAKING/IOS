//
//  APPLatestVersionResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class APPLatestVersionData: HandyJSON {
    
    var update: Bool?
    
    var forcedUpdate: Bool?
    
    /// 最新版本.
    var newVersion: String?
    
    var downloadUrl: String?
    
    /// 更新描述.
    var summary: String?
    
    required init() {}
    
}

class APPLatestVersionResponse: BaseAPIBusinessModel {
    
    var data: APPLatestVersionData?
    
}
