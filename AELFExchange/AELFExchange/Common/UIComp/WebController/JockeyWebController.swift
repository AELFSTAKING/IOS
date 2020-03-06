//
//  JockeyWebController.swift
//  AELFExchange
//
//  Created by tng on 2019/3/12.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class JockeyWebController: BaseViewController {
    
    var showMenuButton = false
    var showNavigationBar = true
    var parseTitleOnWeb = false
    var listenScanQRCodeEvent = false
    var pageLoaded = false
    
    var webView: UIWebView!
    var menuView = WebViewMenuView()
    var parentController: UIViewController?
    private var parseTitleTimer: Timer?
    private var failedRequest: URLRequest?
    private var httpsAuthed = false
    
    private var currentChannelNo: String?
    var url: String?
    
    // MARK: - Lifecycle
    convenience init(withUrl url: String) {
        self.init()
        self.url = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(!self.showNavigationBar, animated: false)
        
        if self.parseTitleOnWeb {
            if parseTitleTimer == nil {
                parseTitleTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(parseTitle), userInfo: nil, repeats: true)
            }
            parseTitleTimer?.fireDate = Date()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Jockey.send("nativeBackWeb", withPayload: ["k":"v"], to: self.webView)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.parseTitleOnWeb {
            parseTitleTimer?.fireDate = Date.distantFuture
        }
    }
    
    deinit {
        if let timer = parseTitleTimer {
            timer.invalidate()
        }
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        webView = UIWebView()
        webView.isOpaque = false
        webView.scalesPageToFit = false
        webView.backgroundColor = kThemeColorBackground
        webView.delegate = self
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        if self.showMenuButton {
            self.view.addSubview(menuView)
            menuView.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-50.0)
                make.size.equalTo(CGSize(width: 40.0, height: 90.0))
            }
        }
        
        // 扫码.
        Jockey.on("barcodeScan") { [weak self] (payload) in
            loginfo(content: "Handle call（barcodeScan）：\(String(describing: payload))")
            if  let payload = payload as? [String : Any?],
                let type = payload["type"] as? String {
                if "QR" == type && self?.listenScanQRCodeEvent == true {
                    let controller = Web_QRCodeScanner()
                    controller.backToClass = "ProfileVC"
                    if let infoTitle = payload["title"] as? String {
                        controller.infoTitle = infoTitle
                    }
                    self?.push(to: controller, animated: true)
                    controller.completion = { (content) in
                        Jockey.send("barcodeResult", withPayload: ["src":content], to: self?.webView)
                    }
                }
            }
        }
        
        Jockey.on("getCurrentLanguage") { [weak self] (payload) in
            loginfo(content: "Handle call（getCurrentLanguage）：\(String(describing: payload))")
            Jockey.send("setCurrentLanguage", withPayload: ["language":LanguageManager.shared().apiCurrentLanguage()], to: self?.webView)
        }
        
        // MARK: Page Transform.
        
        self.loadUrl()
    }
    
    private func signalSetup() -> Void {
        Profile.shared().logoutSignal.observeValues { [weak self] (_) in
            Jockey.send("logout", withPayload: ["k":"v"], to: self?.webView)
        }
        
        self.menuView.eventCallback = { [weak self] (event) in
            switch event {
            case .exit:
                self?.pop()
            case .fullscreenOn:
                self?.enterFullScreen(fullscreen: true)
            case .fullscreenOff:
                self?.enterFullScreen(fullscreen: false)
            }
        }
    }
    
    func loadUrl() {
        if let url = self.url, let theUrl = URL(string: url) {
            webView.loadRequest(URLRequest(url: theUrl))
        }
    }
    
    func enterFullScreen(fullscreen: Bool) {
        MainTabbar.tabBar.isHidden = fullscreen
    }
    
    func shouldGotoLoginPageWhileUnlogin() {
        
    }
    
    func webViewStatusChanged() {
        
    }
    
    @objc private func parseTitle() {
        self.title =  self.webView.stringByEvaluatingJavaScript(from: "document.title")
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension JockeyWebController: UIWebViewDelegate, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.webViewStatusChanged()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.webViewStatusChanged()
        self.pageLoaded = true
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        self.webViewStatusChanged()
        if !httpsAuthed {
            self.failedRequest = request
            NSURLConnection(request: request, delegate: self)
            return false
        }
        return Jockey.webView(webView, with: request.url)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.webViewStatusChanged()
    }
    
    func connection(_ connection: NSURLConnection, willSendRequestFor challenge: URLAuthenticationChallenge) {
        self.webViewStatusChanged()
        if  challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let trust = challenge.protectionSpace.serverTrust {
            if  Config.shared().environment == .test ||
                Config.shared().environment == .stage {
                challenge.sender?.use(URLCredential(trust: trust), for: challenge)
            } else {
                if URLs.shared().ignoreSSLURLHosts.contains(challenge.protectionSpace.host) {
                    challenge.sender?.use(URLCredential(trust: trust), for: challenge)
                }
            }
        }
        challenge.sender?.continueWithoutCredential(for: challenge)
    }
    
    func connection(_ connection: NSURLConnection, didReceive response: URLResponse) {
        self.webViewStatusChanged()
        self.httpsAuthed = true
        connection.cancel()
        if let req = self.failedRequest {
            self.webView.loadRequest(req)
        }
    }
    
}
