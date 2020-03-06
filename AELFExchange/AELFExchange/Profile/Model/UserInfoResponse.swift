//
//  UserInfoResponse.swift
//  AELFExchange
//
//  Created by tng on 2019/1/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import HandyJSON

/**
 用户号  private String userNo; private String firstName; private String lastName;
 邮箱  private String email;
 认证类型：身份证(0),护照(1)  private Integer certificateType;
 认证状态：认证状态：0 成功，1失败，2处理中，3默认状态 private Integer certificateAuthStatus;
 手机区号 private String mobileArea;
 手机号 private String mobile;
 是否设置了安全密码 private boolean isSecurityPwdSet;
 邀请码 private String invitationCode;
 google验证绑定,0表示未绑定，1表示绑定 private String googleStatus;
 反钓鱼码  private String antiPhishing;
*/

enum CertificateAuthStatusEnum: Int, HandyJSONEnum {
    case UnAuth = 3
    case InProgress = 2
    case Succeed = 0
    case Failed = 1
}

class UserInfoData: HandyJSON {
    
    var userNo: String?
    
    var email: String?
    
    var certificateType: Int?
    
    var certificateAuthStatus: CertificateAuthStatusEnum?
    var certificateAuthStatusText: String {
        switch certificateAuthStatus ?? .UnAuth {
        case .InProgress: return LOCSTR(withKey: "认证中")
        case .Failed: return LOCSTR(withKey: "认证失败")
        case .Succeed: return LOCSTR(withKey: "已认证")
        default: return LOCSTR(withKey: "未实名认证")
        }
    }
    
    var mobileArea: String?
    
    var mobile: String?
    
    var securityPwdSet: Bool?
    
    var invitationCode: String?
    
    var googleStatus: String?
    
    var antiPhishing: String?
    
    var country: String?
    
    var certificateTypeName: String?
    
    var certificateNo: String?
    
    var userName: String?
    
    required init() {}
    
}

class UserInfoResponse: BaseAPIBusinessModel {
    
    var data: UserInfoData?
    
}
