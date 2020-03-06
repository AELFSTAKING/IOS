//
//  MQTTConfigResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/3/29.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

class MQTTConfigResponseData: HandyJSON {
    
    var subscriber: String?
    
    var mqttHost: String?
    
    var wssPort: String?
    
    var subscriberPwd: String?
    
    var topicPrefix: String?
    
    var tcpPort: String?
    
    var isShow: Bool?
    
    required init() {}
    
}

class MQTTConfigResponse: BaseAPIBusinessModel {
    
    var data: MQTTConfigResponseData?
    
}
