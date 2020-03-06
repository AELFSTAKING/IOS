//
//  DepthConfigResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

class DepthConfigResponse: BaseAPIBusinessModel {
    
    var data: [String]?
    
}

class DepthConfigData {
    
    var apiObjs = [String]()
    
    var menuForDisplayObjs = [String]()
    
    convenience init(with apiObjs: [String], menuForDisplayObjs: [String]) {
        self.init()
        self.apiObjs = apiObjs.reversed()
        self.menuForDisplayObjs = menuForDisplayObjs.reversed()
    }
    
}
