//
//  URLs.swift
//  AELF
//
//  Created by tng on 2018/9/9.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation

enum AELFUrlSuffix: String {
    
    // MARK: - KYC.
    case accValidEmail = "/user/message/check/email" /// 验证邮箱是否已经被注册「没有被注册返回000000成功，被注册了返回其他错误码」.
    case accValidPhone = "/user/message/check/mobile" /// 验证手机是否已经被注册「没有被注册返回000000成功，被注册了返回其他错误码」.
    case sendCodePhone = "/user/message/send/verifySms" /// 发送手机验证码(登录后).
    case sendCodeEmail = "/user/message/send/verifyEmail" /// 发送邮箱验证码(登录后).
    case sendCodeEmailWithoutLogin = "/message/send/verifyEmail" /// 发送邮件(提供邮箱)(需要先使用极验校验通过之后返回的captchaIdentifier).
    case sendCodePhoneWithoutLogin = "/message/send/verifySms" /// 发送手机验证码(提供手机号)(需要先使用极验校验通过之后返回的captchaIdentifier).
    case login = "/user/login" /// 登录.
    case logout = "/user/logout" /// 注销.
    case register = "/user/register" /// 注册.
    case resetPassword = "/user/password/reset/loginPwd" /// 重置密码(已登录).
    case resetPasswordWithoutLogin = "/user/password/reset/loginPwdWithoutLogin" /// 重置密码(未登录情况下).
    case setAntiPhishing = "/user/set/antiPhishing" /// 设置钓鱼码.
    case setSecurityPassword = "/user/password/set/securityPwd" /// 设置安全密码.
    case resetSecurityPassword = "/user/password/reset/securityPwd" /// 重置安全密码.
    case gt3api1 = "/captcha/start/captcha" /// 极验api1.
    case gt3api2 = "/captcha/validate/captcha" /// 极验api2.
    case authBindStatus = "/user/query/userBindStatus" /// 用户绑定信息查询接口.
    case bindEmail = "/user/email/bind/email" /// 绑定邮箱.
    case changeEmail = "/user/email/rebind/email" /// 修改邮箱.
    case bindPhone = "/user/mobile/bind/mobile" /// 绑定手机.
    case changePhone = "/user/mobile/rebind/mobile" /// 修改手机.
    case userInfo = "/user/query/userInfo" /// 查询用户的详细信息.
    case loginCheck = "/user/checkLogin" /// 检查用户名、密码是否正确，是否需要开启极验和校验验证码.
    case identitySubmit = "/user/authenticate/submit/identity" /// 实名认证、用户提交身份证.
    case passportSubmit = "/user/authenticate/submit/passport" /// 实名认证，用户提交护照.
    case identityAuthInfo = "/user/query/userAuthInfo" /// 查询用户实名认证信息.
    case identityAuthFailedReason = "/user/query/authAuditReason" /// 查询最新一次实名认证失败信息.
    
    // MARK: - Assets.
    case assetsList = "/user/asset/query/asset" /// 查询用户资产列表,用户资产调用.
    case assetsOfSymbol = "/user/asset/query/symbolAsset" /// 根据交易对查询用户的资产信息，这个用户在交易页面可以获取到两个币种的余额信息进行展示，是轮训使用.
    case assetsOfCurrency = "/user/asset/query/currencyAsset" /// 根据币种查询用户余额信息.
    case topupAddr = "/user/wallet/query/rechargeAddr" /// 根据币种获取充币地址.
    case allCurrency = "/currency/query/currencyList" /// 获取所有支持的币种信息.
    case topupRecords = "/user/record/query/recharge" /// 用户充值历史记录查询.
    case withdrawRecords = "/user/record/query/withdraw" /// 提币历史记录查询.
    case withdraw = "/user/withdraw/submit/withdraw" /// 提交提币请求.
    case withdrawInfo = "/user/withdraw/query/withdrawInfo" /// 提币信息，手续费等...
    case addressValidation = "/user/address/validate/address" /// 地址是否是合法、内部地址校验.
    case addAddress = "/user/withdraw/add/withdrawAddress" /// 用户增加提币地址.
    case removeAddress = "/user/withdraw/delete/withdrawAddress" /// 用户删除提币地址.
    case myAddress = "/user/withdraw/query/withdrawAddress" /// 用户提币地址查询，在提币的时候调用.
    case transferRecords = "/user/record/query/transfer" /// 查询划转记录.
    
    case latestVersion = "/dex-cms/cms/app/version/getLatestAppVersion" /// 获取最新APP版本号.
    case allAssets = "/quotation/totalAsset" /// 查询所有资产信息.
    case rewards = "/reward" /// 奖励信息（资金首页展示）
    case rewardsTopup = "/deposit_reward_list" /// 充值奖励.
    case rewardsMining = "/balance_reward_list" /// 挖矿奖励.
    case rewardsSendList = "/send_reward_list" /// 奖励发放记录.
    case transactionRecords = "/tx_history" /// 交易记录.
    case currencyInfo = "/currency/introduction" /// 币种资料信息.
    case createWithdraw = "/withdraw" /// 创建提现单.
    case createWithdrawCallback = "/withdraw/callback" /// 提现回调（没用到）
    
    // MARK: - Market.
    case allSymbols = "/symbol/query/symbolList" /// 所有交易对.
    case collectedSymbols = "/user/symbol/list/symbol" /// 用户列出自选交易对.
    case chainInfo = "/currency/query/currencyChainInfo" /// 获取所有币链关系.
    case symbolTrending = "/quotation/query/recommendSymbolQuotation" /// 热门交易对(首页显示)，也是推荐的交易对.
    case addCollection = "/user/symbol/add/symbol" /// 用户新增自选交易对.
    case delCollection = "/user/symbol/delete/symbol" /// 用户删除自选交易对.
    case klineHistory = "/kline/get/quotationHistory" /// 获取行情历史数据.
    case delegateOrders = "/order/query/orderBook" /// 获取订单薄信息(委托订单).
    case latestOrderDeal = "/order/query/dealList" /// 获取成交记录(最新成交).
    case decimalLen = "/kline/get/symbolDetail" /// 获取交易对展示时相关数据，主要是币种显示的精度，显示小数点后几位.
    case depthData = "/quotation/query/depthData" /// 查询深度图.
    case financialList = "/list/financingProductList" /// 首页理财产品列表.
    case markeyGroup = "/quotation/query/symbolQuotationGroupBy" /// 获取所有交易区行情数据，根据计价币种进行归类.
    case marketGroupedList = "/quotation/query/symbolQuotationGroupByInTradeArea" /// 获取所有交易区行情数据，并根据计价币种进行归类.
    
    case allMarketSymbols = "/quotation/symbolQuotation" /// 所有交易对信息(最新价格、24h最高价、24h最低价...),首页下方展示以及其他模块.
    case currencyList = "/currency_list" /// 币种列表.
    case depthConfig = "/order/query/depthStep" /// 获取交易对的深度选项.
    case usdtPrice = "/quotation/usdtPrice" /// 币种usdt价格查询.
    
    // MARK: - Trade.
    case bestPricee = "/order/query/marketBestPrice" /// 查询市场买卖最优价格.
    case ordersCurrent = "/user/order/query/orderList" /// 查询业务委托订单(当前委托，历史委托).
    case dealOrders = "/user/order/query/dealOrderList" /// 历史成交订单.
    case tradeSubmitSymbolInfo = "/user/order/query/preCreateInfo" /// 查询交易创建相关信息，主要是一些数据展示，前端数据校验参数.
    
    case userOrdersCurrent = "/order_current" /// 当前委托.
    case userOrdersHistory = "/order_histories" /// 历史委托.
    case tradeSymbolInfo = "/user/order/query/tradeSymbolInfo" /// 主要是一些数据展示，前端数据校验参数.
    case createOrder = "/create_order" /// 创建订单.
    case createOrderCallback = "/order/status/payCallback" /// 挂单回调.
    case cancelOrder = "/cancel_order" /// 撤单.
    case cancelOrderCallback = "/order/status/cancelCallback" /// 撤单回调.
    case orderDealDetail = "/order_detail" /// 订单（委托单）明细.
    
    // MARK: - Common.
    case countyList = "/user/query/countryList" /// 查询国家列表.
    case homeInfo = "/article/query/allArticleList" /// 获取首页banner、滚动公告.
    case noticeDetail = "/article/query/fullArticle" /// 新闻详情、滚动通知详情.
    case noticeList = "/article/query/announcement" /// 获取公告中心列表.
    case supportsList = "/article/query/helpCenter" /// 获取帮助中心.
    case fileUpload = "/user/file/upload/file" /// 上传文件.
    case getSeccurity = "/user/query/getSecurity" /// 获取用户私钥和用户号.
    case channelInfo = "/user/query/channelToken" /// 获取渠道临时令牌.
    case channelInfoBatch = "/user/query/batchChannelToken" /// 批量获取渠道临时令牌.
    case mqttConfig = "/mqtt/query/configInfo" /// 获取网页端需要订阅mqtt的配置信息.
    case addressType = "/user/withdraw/check/withdrawAddress" /// 查询提币地址是否是内部地址.
    
    // MARK: - IEO.
    case ieoConfig = "/panic/buying/config/round" /// 抢购配置信息接口.
    case ieoOrderBuy = "/panic/buying/order/buy" /// 下买单.
    case ieoOrderSell = "/panic/buying/order/sell" /// 下卖单.
    
    // MARK: - Wallet.
    case registerAddress = "/register_address" /// 注册地址，用户创建或导入eth地址时，调用.
    case topupAddress = "/deposit_address" /// 获取币种对应的充值地址（平台配置）
    case bindAddressList = "/bind_address_list" /// 已绑定的跨链充值地址列表.
    case bindAddress = "/bind_address" /// 绑定跨链充值地址.
    case removeBoundAddress = "/unbind_address" /// 解绑地址跨链充值地址.
    
    // MARK: - Gateway.
    case gatewayBalance = "/balance" /// 查询钱包余额.
    case gatewaySendBuyTx = "/send_stacking_order_tx" /// 挂单交易发送.
    case gatewaySendCancelTx = "/send_stacking_order_cancel_tx" /// 撤单交易发送.
    case gatewaySendTransferTx = "/send_stacking_transfer_tx" /// 转账交易发送.
    case gatewayGasFeeInfo = "/estimate_transfer_fee" /// 预估转账gas费.
    case gatewayTransTxCreate = "/create_transfer_tx" /// 转账交易-创建.
    case gatewayTransTxSend = "/send_transfer_tx" /// 转账交易-发送.
    case gatewayTxDetailInfo = "/transaction" /// 交易详情查询.
    
    // MARK: - MQTT Topic.
    case mqtopicMarketGrouped = "stakingdex_quotation_group" /// 分组⾏行行情.
    case mqtopicMarketGroupedFormated = "stakingdex_area_quotation" /// 分组⾏行行情，数据格式与'marketGroupedList'一致.
    case mqtopicUpSymbols = "stakingdex_increase_symbols" /// 涨幅交易对.
    case mqtopicHotSymbols = "stakingdex_hot_symbols" /// 热门交易对.
    case mqtopicMarketTodaySymbols = "stakingdex_symbol_quotation_" /// 今日交易易对行情(Should Append: {symbol}).
    case mqtopicMarketDelegateOrders = "stakingdex_order_book_" /// 订单簿数据(Should Append: {symbol}_{step}).
    case mqtopicMarketDepth = "stakingdex_transaction_depth_" /// 最新深度图数据(Should Append: {symbol}).
    case mqtopicMarketKLine = "stakingdex_transaction_kline_" /// K线数据(Should Append: {symbol}_{range}).
    case mqtopicMarketLatestDealOrders = "stakingdex_transaction_deal_" /// 最新成交列列表(Should Append: {symbol}).
    
}

class URLs {
    
    fileprivate static let ___donotUseThisVariableOfURLs = URLs()
    
    static func shared() -> URLs {
        return ___donotUseThisVariableOfURLs
    }
    
    func apiDomain(withoutApis: Bool = false) -> String {
        var domain = domainTest
        switch Config.shared().environment {
        case .prod: domain = domainProd
        case .stage: domain = domainStage
        default:break
        }
        if withoutApis {
            return domain.replacingOccurrences(of: "/apis", with: "")
        }
        return domain
    }
    
    func genUrl(with suffix: AELFUrlSuffix, withoutDexSuffix: Bool = false) -> String {
        var url = "\(self.apiDomain())\(suffix.rawValue)"
        if withoutDexSuffix {
            url = url.replacingOccurrences(of: "/staking-dex", with: "")
        }
        return url
    }
    
    func genGatewayUrl(with suffix: AELFUrlSuffix) -> String {
        var domain = gatewayTest
        switch Config.shared().environment {
        case .prod: domain = gatewayProd
        case .stage: domain = gatewayStage
        default:break
        }
        return "\(domain)\(suffix.rawValue)"
    }
    
    func genEthBlockExplorerUrl(with txid: String) -> String {
        var domain = ethBlockchainUrlTest
        switch Config.shared().environment {
        case .prod: domain = ethBlockchainUrlProd
        case .stage: domain = ethBlockchainUrlStage
        default:break
        }
        return "\(domain)/tx/\(txid)"
    }
    
    func kofoMqttHost() -> String {
        switch Config.shared().environment {
        case .stage: return kofoMqttHostStage
        case .prod: return kofoMqttHostProd
        default: return kofoMqttHostTest
        }
    }
    
    func kofoMqttPort() -> UInt16 {
        switch Config.shared().environment {
        case .stage: return kofoMqttPortStage
        case .prod: return kofoMqttPortProd
        default: return kofoMqttPortTest
        }
    }
    
    func kofoSDKHost() -> String {
        switch Config.shared().environment {
        case .stage: return kofoSDKRestHostStage
        case .prod: return kofoSDKRestHostProd
        default: return kofoSDKRestHostTest
        }
    }
    
    // prod.
    let domainProd = ""//fixme:the rest server domain.
    let gatewayProd = ""//fixme:the gateway rest server domain.
    let kofoMqttHostProd = ""//fixme:mqtt host.
    let kofoMqttPortProd: UInt16 = 1883//fixme:mqtt port.
    let kofoSDKRestHostProd = ""//fixme:KOFO SDK rest server host.
    let ethBlockchainUrlProd = "https://etherscan.io/"
    
    // stage.
    let domainStage = ""
    let gatewayStage = ""
    let kofoMqttHostStage = ""
    let kofoMqttPortStage: UInt16 = 1883
    let kofoSDKRestHostStage = ""
    let ethBlockchainUrlStage = "https://etherscan.io/"
    
    // test.
    let domainTest = ""
    let gatewayTest = ""
    let kofoMqttHostTest = ""
    let kofoMqttPortTest: UInt16 = 1883
    let kofoSDKRestHostTest = ""
    let ethBlockchainUrlTest = "https://rinkeby.etherscan.io/"
    
    // MARK: - Config.
    public let ignoreLogUrls: [AELFUrlSuffix] = [
        .klineHistory
    ]
    public let ignoreSSLURLHosts = [""]
    
}
