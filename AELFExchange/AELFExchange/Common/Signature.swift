//
//  Signature.swift
//  AELF
//
//  Created by tng on 2018/10/11.
//  Copyright © 2018 AELF. All rights reserved.
//

import Foundation
import CryptoSwift
import HandyJSON
import PKHUD

public let kNetRandomCharLength = 16

struct SignatureResult {
    var content: String
    var encryptedBody: String
    var timestamp: String
    var nonce: String
}

extension Network {
    
    private func randomText() -> String {
        return String.random(withLenght: kNetRandomCharLength)
    }
    
    /// Encrypt Body.
    ///
    /// - Parameter params: [String:Any]?
    /// - Returns: String
    func bodyEncrypt(withParams params: [String:Any]?) -> String {
        let paramsJson = params?.obj2json() ?? ""
        let basedGeneralText = "\(self.randomText())\(paramsJson)\(Consts.kDefaultAPPID)"
        
        do {
            let aes = try AES(key: Consts.kDefaultAESKey, iv: Consts.kDefaultAESIV)
            let encrypted = try aes.encrypt(Array(basedGeneralText.utf8))
            if let ret = encrypted.toBase64() {
                return ret
            }
        } catch {}
        return ""
    }
    
    /// Decrypt Body.
    ///
    /// - Parameters:
    ///   - response: String
    ///   - url: String?
    /// - Returns: String
    func bodyDecrypt<T>(withResponse response: String, url: String?, to: T.Type) -> T where T: BaseAPIBusinessModel {
        let responseModel = BaseAPIModel.deserialize(from: response)
        
        guard let model = responseModel, let dataStr = model.data else {
            let errorModel = to.init()
            errorModel.msg = responseModel?.msg ?? response
            errorModel.respCode = responseModel?.code
            self.handleError(withCode: responseModel?.code)
            logerror(content: "error response of: \(String(describing: url)) \nfor:\(String(describing: to)) \nmsg:\(String(describing: errorModel.msg)) \ncode:\(String(describing: responseModel?.code))")
            return errorModel
        }
        
        guard let data = Data(base64Encoded: dataStr) else {
            let errorModel = to.init()
            errorModel.msg = responseModel?.msg
            return errorModel
        }
        
        do {
            // Decrypt the field 'data'.
            let aes = try AES(key: Consts.kDefaultAESKey, iv: Consts.kDefaultAESIV)
            let plainByte = try aes.decrypt(data.bytes)
            
            guard let responseStr = String(data: Data(plainByte), encoding: String.Encoding.utf8) else {
                    let errorModel = to.init()
                    errorModel.msg = "Response is invalid:\(dataStr)"
                    return errorModel
            }
            guard responseStr.count > kNetRandomCharLength else {
                let errorModel = to.init()
                errorModel.msg = "Response length error."
                return errorModel
            }
            
            // Parse the length of Content Json.
            guard let appidBegin = responseStr.range(of: Consts.kDefaultAPPID, options: .backwards, range: nil, locale: nil)?.lowerBound else {
                let errorModel = to.init()
                errorModel.msg = "Response did not contained the APPID."
                return errorModel
            }
            let paramPacketJsonStr = String(responseStr[responseStr.index(responseStr.startIndex, offsetBy: kNetRandomCharLength) ..< appidBegin])
            
            // Signature Text Validation.
            if !self.signatureValid(  withSource: responseModel?.signature,
                                    encryptedBody: responseModel?.data,
                                    timestamp: responseModel?.timestamp,
                                    nonce: responseModel?.nonce,
                                    appid: Consts.kDefaultAPPID) {
                let errorModel = to.init()
                errorModel.msg = "Invalid Signature:\(responseStr)"
                return errorModel
            }
            
            if let url = url {
                loginfo(content: "response of: \(url) \ndata:\(paramPacketJsonStr)")
            }
            
            if let dataModel = to.deserialize(from: paramPacketJsonStr) {
                return dataModel
            }
            
            let errorModel = to.init()
            errorModel.msg = "Error type:\(to)"
            return errorModel
        } catch {
            let errorModel = to.init()
            errorModel.msg = "Failed to decrypt with error:\(error.localizedDescription) original response:\(response)"
            return errorModel
        }
    }
    
    /// Signature of Body.
    ///
    /// - Parameter body: [String:Any]?
    /// - Returns: SignatureResult
    func signature(withBody body: [String:Any]?) -> SignatureResult {
        let nonce = self.randomText()
        let encryptedBody = self.bodyEncrypt(withParams: body)
        let timestamp = timestamps()
        return self.signature(withEncryptedBody: encryptedBody, timestamp: timestamp, nonce: nonce)
    }
    
    func signature(withEncryptedBody body: String, timestamp: String, nonce: String) -> SignatureResult {
        let sorted = [body, timestamp, self.token, nonce].sorted().joined()
        return SignatureResult(content: sorted.sha1(), encryptedBody: body, timestamp: timestamp, nonce: nonce)
    }
    
    /// Validation of the Signature.
    ///
    /// - Parameters:
    ///   - source: String?
    ///   - encryptedBody: String?
    ///   - timestamp: String?
    ///   - nonce: String?
    ///   - appid: String?
    /// - Returns: Bool
    fileprivate func signatureValid(withSource source: String?, encryptedBody: String?, timestamp: String?, nonce: String?, appid: String?) -> Bool {
        guard let source = source, let encryptedBody = encryptedBody, let timestamp = timestamp, let nonce = nonce else {
            return false
        }
        return source == self.signature(withEncryptedBody: encryptedBody, timestamp: timestamp, nonce: nonce).content
    }
    
}

extension Network {
    
    func handleError(withCode code: String?) -> Void {
        guard let code = code else {
            return
        }
        switch code {
        case "BU0201", "BK0001", "BK0002":
            SystemAlert(withStyle: .alert, on: RootViewController(), title: "登录", detail: "请重新登录使用", actions: ["确定"]) { (_) in
                //Profile.shared().logout(withAPICalls: false)
            }
        case "BK0003":
            self.refreshToken()
            break
        default:break
        }
    }
    
    private func refreshToken() -> Void {
//        let params = [
//            "access_token":Profile.shared().access_token ?? "",
//            "refresh_token":Profile.shared().refresh_token ?? ""
//        ]
//
//        HUD.show(.progress)
//        Network.post(withUrl: URLs.shared().genUrl(with: .refreshToken), params: params, contentType: .formUrlEncoded, to: RefreshTokenModel.self) { (succeed, response) in
//            HUD.hide()
//            guard succeed == true,
//                  response.succeed == true,
//                  let accessToken = response.data?.access_token,
//                  let refreshToken = response.data?.refresh_token else {
//                SystemAlert(withStyle: .alert, title: "刷新Token失败，请重新登录", detail: response.msg, actions: ["确定"], callback: { (_) in})
//                return
//            }
//            Profile.shared().access_token = accessToken
//            Profile.shared().refresh_token = refreshToken
//            SystemAlert(withStyle: .alert, title: "已成功刷新Token，请重试！", actions: ["好的"], callback: { (_) in})
//        }
    }
    
}
