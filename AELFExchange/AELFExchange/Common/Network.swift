//
//  Network.swift
//  AELF
//
//  Created by tng on 2018/9/9.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation
import Alamofire
import PINCache
import CryptoSwift

public enum NetworkContentType {
    case json
    case formUrlEncoded
    case text
}

class Network {
    
    fileprivate static let ___donotUseThisVariableOfNetwork = Network()
    
    @discardableResult
    static func shared() -> Network {
        return Network.___donotUseThisVariableOfNetwork
    }
    
    fileprivate static var ___cacheManager: PINCache = {
        let cache = PINCache.init(name: "com.AELF", rootPath: Config.shared().pathOfHttpCache)
        return cache
    }()
    
    fileprivate static func ___cacheKeypath(with url: String, params: [String:Any]?, headers: [String:String]?) -> String {
        var origContent = url

        if let p = params  { origContent += String.init(format: "%@", p) }
        if let h = headers { origContent += String.init(format: "%@", h) }
        return origContent.md5()
    }
    
    /// Access Token.
    var token: String {
        get {
            if let theInstance = UserDefaults.standard.value(forKey: "token") as? String { return theInstance }
            return Consts.kDefaultToken
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "token")
            UserDefaults.standard.synchronize()
        }
    }
    
    public static func setup() -> Void {
        SessionManager.default.delegate.sessionDidReceiveChallenge = { (session, challenge) in
            return (URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
    
    /// Generate the HTTP Header.
    ///
    /// - Returns: 1:header.
    static func ___genHeader(withCompletion completion: @escaping ([String:String]) -> ()) -> Void {
        var headers = [String:String]()
        let traceId = "\(timestampms())000"
        headers["X-B3-Spanid"] = traceId
        headers["X-B3-Traceid"] = traceId
        headers["DEVICEID"] = Util.deviceID()
        headers["DEVICESOURCE"] = Consts.kAppSource
        headers["Lang"] = LanguageManager.shared().apiCurrentLanguage()
//        if Profile.shared().logined, let token = Profile.shared().loginData?.token {
//            headers["AELFTOKEN"] = token
//        }
        completion(headers)
    }
    
    /// GET Request.
    ///
    /// - Parameters:
    ///   - url: string.
    ///   - params: map.
    ///   - header: Optional: HTTP Headers.
    ///   - params: useProfileCookies: if yes, assemble cookies: USERNAME,user_level,level,EMAILVERIFIED,DUID from 'EntityUserProfile'.
    ///   - completion: 1:succeed; 2:response text; 3:Used RandomIP for proxy(the 'availableRefreshCount' did increased by 1)..
    static func get( withUrl url: String,
                    encodeUrl: Bool = true,
                    params: [String:Any]? = nil,
                    header: [String:String]? = nil,
                    useProfileCookies: Bool? = false,
                    cacheCallback cache: ((String) -> ())? = nil,
                    completionCallback completion: @escaping (Bool, String) -> ()) -> Void {
        
        if Config.shared().usingCache { // ❌❌❌ Deprecated for now. ❌❌❌
            if let cacheObject = ___cacheManager.object(forKey: ___cacheKeypath(with: url, params: params, headers: nil)) as? String,
                let cacheCallback = cache {
                cacheCallback(cacheObject)
            }
        }
            
        Network.___genHeader { (headers) in
            // Header.
            var newHeaders = headers
            if let customHeaders = header {
                for (key, value) in customHeaders {
                    newHeaders[key] = value
                }
            }
            loginfo(content: "<< GET Request: \(url) \nuser params:\(params ?? ["":""]) \nparams:\(params ?? ["":""]) \nheaders:\(newHeaders)")
            
            let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
            Alamofire.request(encodeUrl ? encodedUrl : url,
                              method: .get,
                              parameters: params,
                              encoding: URLEncoding.default,
                              headers: newHeaders)
                .responseData(completionHandler: { (data) in
                    
                    DispatchQueue.global().async {
                        switch data.result {
                        case .success(let data):
                            if let content = String.init(data: data, encoding: String.Encoding.utf8) {
                                ___cacheManager.setObject(content as NSString, forKey: ___cacheKeypath(with: url, params: params, headers: nil))
                                DispatchQueue.main.async {
                                    completion(true, content)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(true, "empty response")
                                }
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                completion(false, error.localizedDescription)
                            }
                        }
                    }
                    
                })
            
        }
    }
    
    /// GET Request.
    ///
    /// - Parameters:
    ///   - url: string.
    ///   - params: map.
    ///   - header: Optional: HTTP Headers.
    ///   - params: useProfileCookies: if yes, assemble cookies: USERNAME,user_level,level,EMAILVERIFIED,DUID from 'EntityUserProfile'.
    ///   - completion: 1:succeed; 2:response text; 3:Used RandomIP for proxy(the 'availableRefreshCount' did increased by 1)..
    static func get<T>( withUrl url: String,
                        encodeUrl: Bool = true,
                        params: [String:Any]? = nil,
                        header: [String:String]? = nil,
                        to: T.Type,
                        useCache: Bool = false,
                        cacheCallback cache: ((Bool, T) -> ())? = nil,
                        completionCallback completion: @escaping (Bool, T) -> ()) -> Void where T: BaseAPIBusinessModel {
        
        if Config.shared().usingCache {
            if  let cacheObject = ___cacheManager.object(forKey: ___cacheKeypath(with: url, params: params, headers: nil)) as? String,
                let cacheCallback = cache,
                let model = T.deserialize(from: cacheObject) {
                cacheCallback(true, model)
            }
        }
        
        Network.___genHeader { (headers) in
            // Header.
            var newHeaders = headers
            if let customHeaders = header {
                for (key, value) in customHeaders {
                    newHeaders[key] = value
                }
            }
            
            if URLs.shared().ignoreLogUrls.contains(where: { (suffix) -> Bool in
                return url.contains(suffix.rawValue)
            }) == false {
                loginfo(content: "<< GET Request: \(url) \nuser params:\(params ?? ["":""]) \nparams:\(params ?? ["":""]) \nheaders:\(newHeaders)")
            }
            
            let encodedUrl = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url
            Alamofire.request(encodeUrl ? encodedUrl : url,
                              method: .get,
                              parameters: params,
                              encoding: URLEncoding.default,
                              headers: newHeaders)
                .responseData(completionHandler: { (data) in
                    
                    DispatchQueue.global().async {
                        switch data.result {
                        case .success(let data):
                            let contentString = String.init(data: data, encoding: String.Encoding.utf8)
                            if URLs.shared().ignoreLogUrls.contains(where: { (suffix) -> Bool in
                                return url.contains(suffix.rawValue)
                            }) == false {
                                loginfo(content: "<< POST Response of: \(url) \ndata:\(String(describing: contentString))")
                            }
                            
                            if useCache, let content = contentString {
                                ___cacheManager.setObject(content as NSString, forKey: ___cacheKeypath(with: url, params: params, headers: nil))
                            }
                            
                            if let content = contentString, let responseModel = to.deserialize(from: content) {
                                DispatchQueue.main.async {
                                    Network.credentialValidation(with: responseModel)
                                    completion(true, responseModel)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(true, T(msg: "empty response"))
                                }
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                completion(false, T(msg: error.localizedDescription))
                            }
                        }
                    }
                    
                })
            
        }
    }
    
    /// POST Request
    ///
    /// - Parameters:
    ///   - url: .
    ///   - params: .
    ///   - header: [String:String].
    ///   - contentType: NetworkContentType.
    ///   - to: T.
    ///   - completion: 1:succeed; 2:response text.
    static func post<T>( withUrl url: String,
                        params: [String:Any]? = nil,
                        withoutDataField: Bool = false,
                        header: [String:String]? = nil,
                        contentType: NetworkContentType = .json,
                        to: T.Type,
                        useCache: Bool = false,
                        cacheCallback cache: ((Bool, T) -> ())? = nil,
                        completionCallback completion: @escaping (Bool, T) -> ()) -> Void where T: BaseAPIBusinessModel {
        
        if useCache {
            if  let cacheObject = ___cacheManager.object(forKey: ___cacheKeypath(with: url, params: params, headers: nil)) as? String,
                let cacheCallback = cache,
                let model = T.deserialize(from: cacheObject) {
                cacheCallback(true, model)
            }
        }
            
        // Without cache now.
        Network.___genHeader { (headers) in
            
            var multParams = [String:Any]()
            let signature = Network.shared().signature(withBody: params ?? [String:Any]())
            multParams["signature"] = signature.content
            multParams["lang"] = LanguageManager.shared().apiCurrentLanguage()
            if let customParams = params {
                let withoutParamDataField = (customParams["withoutParamDataField"] as? Bool) ?? withoutDataField
                if withoutParamDataField == true {
                    multParams.merge(customParams, uniquingKeysWith: { (_, _) -> Any in return })
                } else {
                    multParams["data"] = customParams
                }
            }
            
            if URLs.shared().ignoreLogUrls.contains(where: { (suffix) -> Bool in
                return url.contains(suffix.rawValue)
            }) == false {
                loginfo(content: "<< POST Request: \(url) \nparams:\(multParams) \nheaders:\(headers) \nextra-headers:\(header ?? ["":""])")
            }
            
            if contentType == .json || contentType == .text {
                
                // Header.
                var newHeaders = headers
                switch contentType {
                case .json, .formUrlEncoded:
                    newHeaders["Content-Type"] = "application/json"
                    break
                case .text:
                    newHeaders["Content-Type"] = "application/text"
                    break
                }
                if let customHeaders = header {
                    for (key, value) in customHeaders {
                        newHeaders[key] = value
                    }
                }
                
                Alamofire.request(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url,
                                  method: .post,
                                  parameters: multParams,
                                  encoding: JSONEncoding.default,
                                  headers: newHeaders)
                    .responseData(completionHandler: { (data) in
                        
                        DispatchQueue.global().async {
                            switch data.result {
                            case .success(let data):
                                let contentString = String.init(data: data, encoding: String.Encoding.utf8)
                                if URLs.shared().ignoreLogUrls.contains(where: { (suffix) -> Bool in
                                    return url.contains(suffix.rawValue)
                                }) == false {
                                    loginfo(content: "<< POST Response of: \(url) \ndata:\(String(describing: contentString))")
                                }
                                
                                if useCache, let content = contentString {
                                    ___cacheManager.setObject(content as NSString, forKey: ___cacheKeypath(with: url, params: params, headers: nil))
                                }
                                
                                if let content = contentString, let responseModel = to.deserialize(from: content) {
                                    DispatchQueue.main.async {
                                        Network.credentialValidation(with: responseModel)
                                        completion(true, responseModel)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        completion(true, T(msg: "empty response"))
                                    }
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(false, T(msg: error.localizedDescription))
                                }
                            }
                        }
                        
                    })
                
            }
            else if contentType == .formUrlEncoded {
                
                var request = URLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url)!,
                                         cachePolicy: .useProtocolCachePolicy,
                                         timeoutInterval: TimeInterval(Config.timeoutOfRequest))
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                
                // Header.
                var newHeaders = headers
                if let customHeaders = header {
                    for (key, value) in customHeaders {
                        newHeaders[key] = value
                    }
                }
                for (key, value) in newHeaders {
                    request.setValue(value, forHTTPHeaderField: key)
                }
                
                // Body.
                var bodystrs = [String]()
                for (key, value) in multParams {
                    bodystrs.append("\(key)=\(value)")
                }
                let bodystr = bodystrs.joined(separator: "&")
                request.httpBody = bodystr.data(using: String.Encoding.utf8)
                
                Alamofire.request(request).responseData(completionHandler: { (data) in
                    
                    switch data.result {
                    case .success(let data):
                        if let content = String.init(data: data, encoding: String.Encoding.utf8) {
                            
                            if useCache {
                                ___cacheManager.setObject(content as NSString, forKey: ___cacheKeypath(with: url, params: params, headers: nil))
                            }
                            
                            DispatchQueue.global().async {
                                let plainResponse = Network.shared().bodyDecrypt(withResponse: content, url: url, to: to)
                                DispatchQueue.main.async {
                                    Network.credentialValidation(with: plainResponse)
                                    completion(true, plainResponse)
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(true, T(msg: "empty response"))
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(false, T(msg: error.localizedDescription))
                        }
                    }
                    
                })
                
            }
            
        }
        
    }
    
    /// General POST Request with JSON String Response.
    static func jsonPost( withUrl url: String,
                         params: [String:Any]? = nil,
                         header: [String:String]? = nil,
                         withoutParamDataField: Bool,
                         completionCallback completion: @escaping (Bool, String) -> ()) {
        Network.___genHeader { (headers) in
            
            var multParams = [String:Any]()
            let signature = Network.shared().signature(withBody: params ?? [String:Any]())
            multParams["signature"] = signature.content
            multParams["lang"] = LanguageManager.shared().apiCurrentLanguage()
            if let customParams = params {
                if withoutParamDataField {
                    multParams.merge(customParams, uniquingKeysWith: { (_, _) -> Any in return })
                } else {
                    multParams["data"] = customParams
                }
            }
            
            if URLs.shared().ignoreLogUrls.contains(where: { (suffix) -> Bool in
                return url.contains(suffix.rawValue)
            }) == false {
                loginfo(content: "<< POST Request: \(url) \nparams:\(multParams) \nheaders:\(headers) \nextra-headers:\(header ?? ["":""])")
            }
            
            // Header.
            var newHeaders = headers
            newHeaders["Content-Type"] = "application/json"
            if let customHeaders = header {
                for (key, value) in customHeaders {
                    newHeaders[key] = value
                }
            }
            
            Alamofire.request(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url,
                              method: .post,
                              parameters: multParams,
                              encoding: JSONEncoding.default,
                              headers: newHeaders)
                .responseData(completionHandler: { (data) in
                    
                    DispatchQueue.global().async {
                        switch data.result {
                        case .success(let data):
                            let contentString = String.init(data: data, encoding: String.Encoding.utf8)
                            if URLs.shared().ignoreLogUrls.contains(where: { (suffix) -> Bool in
                                return url.contains(suffix.rawValue)
                            }) == false {
                                loginfo(content: "<< POST Response of: \(url) \ndata:\(String(describing: contentString))")
                            }
                            
                            if let content = contentString {
                                DispatchQueue.main.async {
                                    completion(true, content)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(true, "empty response")
                                }
                            }
                        case .failure(let error):
                            DispatchQueue.main.async {
                                completion(false, error.localizedDescription)
                            }
                        }
                    }
                    
                })
            
        }
    }
    
    /// Upload file Request.
    ///
    /// - Parameters:
    ///   - url: .
    ///   - params: .
    ///   - header: [String:String].
    ///   - datas: [Data].
    ///   - contentType: NetworkContentType.
    ///   - to: T.
    ///   - completion: 1:succeed; 2:response text.
    static func upload<T>(withUrl url: String,
                         params: [String:Any]? = nil,
                         header: [String:String]? = nil,
                         datas: [Data],
                         names: [String],
                         types: [String]? = nil,
                         mimeTypes: [String]? = nil,
                         contentType: NetworkContentType = .json,
                         to: T.Type,
                         completionCallback completion: @escaping (Bool, T) -> ()) -> Void where T: BaseAPIBusinessModel {
            
        Network.___genHeader { (headers) in
            
            var request = URLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url)!,
                                     cachePolicy: .useProtocolCachePolicy,
                                     timeoutInterval: TimeInterval(Config.timeoutOfRequestFileUpload))
            request.httpMethod = "POST"
            
            // Assemble parameters.
            var multParams = [String:Any]()
            if let customParams = params {
                multParams.merge(customParams, uniquingKeysWith: { (_, _) -> Any in return })
            }
            
            let signature = Network.shared().signature(withBody: params ?? [String:Any]())
            multParams["signature"] = signature.content
            multParams["lang"] = LanguageManager.shared().apiCurrentLanguage()
            loginfo(content: "<< Upload with: \(url) \nparams:\(multParams) \nheaders:\(headers)")
            
            // Header.
            var newHeaders = headers
            if let customHeaders = header {
                for (key, value) in customHeaders {
                    newHeaders[key] = value
                }
            }
            for (key, value) in newHeaders {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            Alamofire.upload(multipartFormData: { (data) in
                
                // Parameters.
                for (key, value) in multParams {
                    if let paramValue = value as? String, let paramData = paramValue.data(using: String.Encoding.utf8) {
                        data.append(paramData, withName: key)
                        loginfo(content: "<< Appending params with key:\(key) value:\(value) datalen:\(paramData.count)")
                    }
                }
                
                // File.
                for index in 0 ..< datas.count {
                    let type = types?[index] ?? "jpg"
                    let mimeType = mimeTypes?[index] ?? "image/jpeg"
                    data.append(datas[index], withName: names[index], fileName: "\(names[index]).\(type)", mimeType: mimeType)
                    loginfo(content: "<< Appending data:\(datas[index].count)")
                }
                
            }, with: request, encodingCompletion: { (encodingResult) in
                
                DispatchQueue.global().async {
                    switch encodingResult {
                    case .success(let upload, _, _):
                        upload.responseData(completionHandler: { (data) in
                            
                            switch data.result {
                            case .success(let data):
                                if let content = String.init(data: data, encoding: String.Encoding.utf8) {
                                    loginfo(content: "<< POST Response of: \(url) \ndata:\(String(describing: content))")
                                    if let responseModel = to.deserialize(from: content) {
                                        DispatchQueue.main.async {
                                            Network.credentialValidation(with: responseModel)
                                            completion(true, responseModel)
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            completion(true, T(msg: "empty response"))
                                        }
                                    }
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    completion(false, T(msg: error.localizedDescription))
                                }
                            }
                            
                        })
                        break
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(false, T(msg: error.localizedDescription))
                        }
                    }
                }
                
            })
            
        }
        
    }
}
