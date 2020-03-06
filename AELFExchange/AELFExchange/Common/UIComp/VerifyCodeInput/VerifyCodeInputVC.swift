//
//  VerifyCodeInputVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/11.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit
import ReactiveSwift

class VerifyCodeInputVC: BaseViewController {
    
    var inputFinished: ((String, VerifyCodeInputVC) -> ())?
    var areaCode: String!
    var account: String!
    var gtChallengeId: String?
    
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var codeTypeLabel: Label!
    @IBOutlet weak var codeInputView: VerifyCodeInputView! {
        didSet {
            codeInputView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var secondsCountdownLabel: Label! {
        didSet {
            secondsCountdownLabel.text = nil
        }
    }
    @IBOutlet weak var resendButton: UIButton! {
        didSet {
            resendButton.isHidden = true
        }
    }
    
    @objc dynamic private var countDown = Consts.kCountdownDefault
    private var timer: Timer!
    
    var type: VerifyCodeInputEnum?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.sendCode()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
            self.codeInputView.textfield.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @IBAction func resendPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.countDown = Consts.kCountdownDefault
        //self.timer.fireDate = Date() // 暂时隐藏
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        guard let type = self.type else {
            self.pop()
            return
        }
        
        switch type {
        case .loginEmail:
            self.title = LOCSTR(withKey: "登录")
            self.codeTypeLabel.text = LOCSTR(withKey: "邮箱验证码")
        case .loginPhone:
            self.title = LOCSTR(withKey: "登录")
            self.codeTypeLabel.text = LOCSTR(withKey: "短信验证码")
        case .registerEmail:
            self.title = LOCSTR(withKey: "注册")
            self.codeTypeLabel.text = LOCSTR(withKey: "邮箱验证码")
        case .registerPhone:
            self.title = LOCSTR(withKey: "注册")
            self.codeTypeLabel.text = LOCSTR(withKey: "短信验证码")
        }
    }
    
    private func signalSetup() -> Void {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerProcess), userInfo: nil, repeats: true)
        timer.fireDate = Date.distantFuture
        
        self.reactive.producer(forKeyPath: "countDown").startWithValues { (count) in
            //if let count = count as? Int {
                //self?.resendButton.isHidden = count > 0 // 暂时隐藏
            //}
        }
        
        self.codeInputView.inputFinished = { [weak self] (code) in
            if let callback = self?.inputFinished, let instance = self {
                callback(code, instance)
            }
        }
    }
    
    private func sendCode() -> Void {
        //timer.fireDate = Date() // 暂时隐藏
        switch self.type! {
        case .loginEmail:
            let params = [
                "authType":VerifyCodeEnum.LOGIN.rawValue,
                "email":self.account,
                "captchaIdentifier":self.gtChallengeId ?? ""
                ]  as [String : Any]
            Network.post(withUrl: URLs.shared().genUrl(with: .sendCodeEmailWithoutLogin), params: params, to: BaseAPIBusinessModel.self) { (succeed, response) in
                if succeed == false || response.succeed == false {
                    InfoToast(withLocalizedTitle: response.msg)
                }
            }
        case .loginPhone:
            let params = [
                "authType":VerifyCodeEnum.LOGIN.rawValue,
                "mobileArea":self.areaCode,
                "mobile":self.account,
                "captchaIdentifier":self.gtChallengeId ?? ""
                ]  as [String : Any]
            Network.post(withUrl: URLs.shared().genUrl(with: .sendCodePhoneWithoutLogin), params: params, to: BaseAPIBusinessModel.self) { (succeed, response) in
                if succeed == false || response.succeed == false {
                    InfoToast(withLocalizedTitle: response.msg)
                }
            }
        case .registerEmail:
            let params = [
                "authType":VerifyCodeEnum.REGISTER.rawValue,
                "email":self.account,
                "captchaIdentifier":self.gtChallengeId ?? ""
            ]  as [String : Any]
            Network.post(withUrl: URLs.shared().genUrl(with: .sendCodeEmailWithoutLogin), params: params, to: BaseAPIBusinessModel.self) { (succeed, response) in
                if succeed == false || response.succeed == false {
                    InfoToast(withLocalizedTitle: response.msg)
                }
            }
        case .registerPhone:
            let params = [
                "authType":VerifyCodeEnum.REGISTER.rawValue,
                "mobileArea":self.areaCode,
                "mobile":self.account,
                "captchaIdentifier":self.gtChallengeId ?? ""
                ]  as [String : Any]
            Network.post(withUrl: URLs.shared().genUrl(with: .sendCodePhoneWithoutLogin), params: params, to: BaseAPIBusinessModel.self) { (succeed, response) in
                if succeed == false || response.succeed == false {
                    InfoToast(withLocalizedTitle: response.msg)
                }
            }
        }
    }
    
    @objc private func timerProcess() -> Void {
        guard self.countDown > 1 else {
            self.secondsCountdownLabel.text = nil
            timer.fireDate = Date.distantFuture
            return
        }
        self.countDown -= 1
        self.secondsCountdownLabel.text = "\(self.countDown)s"
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject

}
