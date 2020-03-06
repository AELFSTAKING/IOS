//
//  AELFTokenManager.swift
//  AELFExchange
//
//  Created by tng on 2019/3/4.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import CryptoSwift

class AELFTokenManager {
    
    fileprivate static let ___donotUseThisVariableOfCEXPassportManager = AELFTokenManager()
    
    @discardableResult
    static func shared() -> AELFTokenManager {
        return AELFTokenManager.___donotUseThisVariableOfCEXPassportManager
    }
    
    required init() {
        //load channel info
    }
    
    func genPassport(_ completion: @escaping (String) -> ()) {
        self.getSecurityInfo { (pKey, userNo) in
            guard pKey.count > 0 else {
                completion("")
                return
            }
            
            let timems = timestamps()
            let plainContent = "\(userNo).\(timems)"
            if let plainData = plainContent.data(using: String.Encoding.utf8) {
                let encryptedContentData = SignUtil.rsaSHA256Sign(plainData, privateKey: pKey)
                let encryptedContent = encryptedContentData.base64EncodedString()
                let passport = "\(userNo).\(timems).\(encryptedContent)"
                loginfo(content: "<< Generated a CEXPassport String for: \(plainContent) ret: \(passport)")
                completion(passport)
            } else {
                logerror(content: "<< Failed to container the plain data of CEXPassport: \(plainContent)")
            }
        }
    }
    
    func getChannelToken(for channelNo: String?, callback: @escaping (String?) -> ()) {
        guard let channelNo = channelNo else {
            return
        }
        
        var hasCache = false
        if let cache = Config.shared().channelInfoes {
            for case let item in cache where channelNo == item.channelNo {
                if let token = item.channelToken {
                    callback(token)
                    hasCache = true
                }
            }
        }
        
        TopController().startLoadingHUD(withMsg: Consts.kMsgLoading)
        self.getChannelInfoes([]) { (data) in
            TopController().stopLoadingHUD()
            if let datas = data, hasCache == false {
                for case let item in datas where channelNo == item.channelNo {
                    if let token = item.channelToken {
                        callback(token)
                        break
                    }
                }
            }
        }
        logwarn(content: "There is no token for channel: \(channelNo)")
    }
    
}

extension AELFTokenManager {
    
    /// Get the PrivateKey of the Passport Security.
    /// Callback: Private Key, UserNo.
    func getSecurityInfo(_ callback: @escaping (String, String) -> ()) {
        if let containedKey = Config.shared().secPrivateKey, containedKey.count > 0, let conteinedUserNo = Config.shared().userNo, conteinedUserNo.count > 0 {
            callback(containedKey, conteinedUserNo)
            return
        }
        Network.post(withUrl: URLs.shared().genUrl(with: .getSeccurity), to: SecurityInfoResponse.self) { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data?.privateKey, let userNo = response.data?.userNo else {
                InfoToast(withLocalizedTitle: response.msg)
                callback("", "")
                return
            }
            Config.shared().secPrivateKey = data
            callback(data, userNo)
        }
    }
    
    /// Get the token of Third-Channel with the given ChannelNo List.
    func getChannelInfoes(_ channelNo: [String], callback: @escaping ([ThirdChannelInfoData]?) -> ()) {
        Network.post(withUrl: URLs.shared().genUrl(with: .channelInfoBatch), to: ThirdChannelInfoResponse.self) { (succeed, response) in
            guard succeed == true, response.succeed == true, let data = response.data else {
                InfoToast(withLocalizedTitle: response.msg)
                callback(nil)
                return
            }
            Config.shared().channelInfoes = data
            callback(data)
        }
    }
    
}
