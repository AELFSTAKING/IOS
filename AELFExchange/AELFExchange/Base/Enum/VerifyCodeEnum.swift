//
//  VerifyCodeEnum.swift
//  AELFExchange
//
//  Created by tng on 2019/1/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation

public enum VerifyCodeEnum: String {
    case REGISTER = "REGISTER" /// 注册使用(未登录状态).
    case LOGIN = "LOGIN" /// 登录(未登录状态).
    case RESET_LOGIN_PWD = "RESET_LOGIN_PWD" /// 重置登录密码(登录、未登录都有).
    case BIND_GOOGLE = "BIND_GOOGLE" /// 绑定google验证(登录状态).
    case BIND_MOBILE = "BIND_MOBILE" /// 绑定手机验证(登录状态).
    case REBIND_MOBILE = "REBIND_MOBILE" /// 重新绑定手机号，更新手机号(登录状态).
    case BIND_EMAIL = "BIND_EMAIL" /// 绑定邮箱(登录状态).
    case REBIND_EMAIL = "REBIND_EMAIL" /// 重新绑定邮箱验证(登录状态).
    case SET_SECURITY_PWD = "SET_SECURITY_PWD" /// 设置安全密码(登录状态).
    case RESET_SECURITY_PWD = "RESET_SECURITY_PWD" /// 重置安全密码(登录状态).
    case ADD_WITHDRAW_ADDR = "ADD_WITHDRAW_ADDR" /// 添加用户提币地址(登录状态).
    case WITHDRAW_COIN = "WITHDRAW_COIN" /// 提币(登录状态).
}

public enum DynamicAuthType: Int {
    case Phone = 1
    case Email = 2
    case Google = 3
}
