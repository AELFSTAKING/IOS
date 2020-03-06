//
//  GT3CaptchaManager.swift
//  AELFExchange
//
//  Created by tng on 2019/1/13.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import GT3Captcha

class GT3Manager: NSObject {
    
    fileprivate static let ___donotUseThisVariableOfGT3CaptchaManager = GT3Manager()
    
    @discardableResult
    static func shared() -> GT3Manager {
        return GT3Manager.___donotUseThisVariableOfGT3CaptchaManager
    }
    
    private var manager: GT3CaptchaManager?
    
    /// return: .
    private var failedCallback: ((String) -> ())?
    
    /// return: Error msg.
    private var succeedCallback: ((String) -> ())?
    
    private override init() {
        super.init()
        manager = GT3CaptchaManager.init(
            api1: URLs.shared().genUrl(with: .gt3api1),
            api2: URLs.shared().genUrl(with: .gt3api2),
            timeout: TimeInterval(Config.timeoutOfRequest)
        )
        manager?.delegate = self
        manager?.registerCaptcha({})
    }
    
    /// ...
    ///
    /// - Parameter callback: true: challengeid / false: err msg.
    func doAuth(withCompletion callback: @escaping ((Bool, String) -> ())) -> Void {
        self.manager?.use(LanguageManager.shared().currentLanguage() == .ZH_HANS ? .LANGTYPE_ZH_CN:.LANGTYPE_EN_US)
        self.manager?.startGTCaptchaWith(animated: true)
        self.failedCallback = { (msg) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2, execute: {
                DispatchQueue.main.async {
                    callback(false, msg)
                }
            })
        }
        self.succeedCallback = { (challenge) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2, execute: {
                DispatchQueue.main.async {
                    callback(true, challenge)
                }
            })
        }
    }
    
}

extension GT3Manager: GT3CaptchaManagerDelegate {
    
    func gtCaptchaUserDidCloseGTView(_ manager: GT3CaptchaManager!) {
        if let callback = self.failedCallback {
            callback("Canceled")
        }
    }
    
    func gtCaptcha(_ manager: GT3CaptchaManager!, errorHandler error: GT3Error!) {
        manager.closeGTViewIfIsOpen()
        if error.error_code == "" {
            InfoToast(withLocalizedTitle: "失败次数过多")
        } else {
            InfoToast(withLocalizedTitle: "验证失败")
        }
        if let callback = self.failedCallback {
            callback(error.gtDescription)
        }
    }
    
    func gtCaptcha(_ manager: GT3CaptchaManager!, willSendRequestAPI1 originalRequest: URLRequest!, withReplacedHandler replacedHandler: ((URLRequest?) -> Void)!) {
        Network.___genHeader { (headers) in
            var newReq = originalRequest
            newReq?.allHTTPHeaderFields = headers
            if let newReq = newReq {
                replacedHandler(newReq)
            }
        }
    }
    
    func gtCaptcha(_ manager: GT3CaptchaManager!, didReceiveDataFromAPI1 dictionary: [AnyHashable : Any]!, withError error: GT3Error!) -> [AnyHashable : Any]! {
        guard let _ = dictionary else {
            InfoToast(withLocalizedTitle: "验证无效")
            if let callback = self.failedCallback {
                callback(error.gtDescription)
            }
            return dictionary
        }
        return dictionary
    }
    
    func gtCaptcha(_ manager: GT3CaptchaManager!, didReceiveSecondaryCaptchaData data: Data!, response: URLResponse!, error: GT3Error!, decisionHandler: ((GT3SecondaryCaptchaPolicy) -> Void)!) {
        // ...
    }
    
    func shouldUseDefaultSecondaryValidate(_ manager: GT3CaptchaManager!) -> Bool {
        return false
    }
    
    func gtCaptcha(_ manager: GT3CaptchaManager!, didReceiveCaptchaCode code: String!, result: [AnyHashable : Any]!, message: String!) {
        guard let geetestChallenge = result["geetest_challenge"] as? String,
            let geetestValidate = result["geetest_validate"] as? String,
            let geetestSeccode = result["geetest_seccode"] as? String else {
                if let callback = self.failedCallback {
                    InfoToast(withLocalizedTitle: "验证出错了")
                    callback("error params")
                }
                return
        }
        
        let params = [
            "geetestChallenge":geetestChallenge,
            "geetestValidate":geetestValidate,
            "geetestSeccode":geetestSeccode
        ]
        Network.post(withUrl: URLs.shared().genUrl(with: .gt3api2), params: params, to: GT3API2Response.self) { (succeed, response) in
            manager.closeGTViewIfIsOpen()
            guard succeed == true, response.succeed == true else {
                if let callback = self.failedCallback {
                    InfoToast(withLocalizedTitle: response.msg)
                    callback(response.msg ?? "")
                }
                return
            }
            if let callback = self.succeedCallback, let challenge = response.data?.captchaIdentifier {
                callback(challenge)
            }
        }
    }
    
}
