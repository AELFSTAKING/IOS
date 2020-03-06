//
//  WebController.swift
//  AELFExchange
//
//  Created by tng on 2019/1/14.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import IQKeyboardManagerSwift
import WebKit
import JavaScriptCore
import ReactiveSwift
import WebViewJavascriptBridge

class WebController: BaseViewController {
    
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "c2cNeedsLogin")
        config.websiteDataStore = WKWebsiteDataStore.default()
        
        let w = WKWebView(frame: .zero, configuration: config)
        w.allowsBackForwardNavigationGestures = true
        w.translatesAutoresizingMaskIntoConstraints = false
        w.scrollView.showsVerticalScrollIndicator = false
        w.allowsBackForwardNavigationGestures = false
        w.scrollView.bounces = false
        w.navigationDelegate = self
        w.uiDelegate = self
        w.isOpaque = false
        w.backgroundColor = .white
        return w
    }()
    private lazy var progressView: UIProgressView = {
        let p = UIProgressView(progressViewStyle: .default)
        p.translatesAutoresizingMaskIntoConstraints = false
        p.tintColor = kThemeColorTintPurple
        p.trackTintColor = .clear
        p.isHidden = true
        return p
    }()
    private var bridge: WebViewJavascriptBridge!
    
    var url: String?
    var fileName: String?
    var html: String?
    
    var customBackgroundColor: UIColor?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.load()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        if customBackgroundColor != nil {
            self.webView.backgroundColor = self.customBackgroundColor
        }
        
        self.view.addSubview(self.webView)
        self.webView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.webView.addSubview(self.progressView)
        self.progressView.snp.makeConstraints { (make) in
            make.top.equalTo(self.webView.snp.top)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(2.0)
        }
        
        self.bridge = WebViewJavascriptBridge(forWebView: self.webView)
        if IsDebug { WebViewJavascriptBridge.enableLogging() }
        self.bridge.setWebViewDelegate(self)
        self.jsCallbackSetup()
    }
    
    private func signalSetup() -> Void {
        self.webView.reactive.producer(forKeyPath: "estimatedProgress").startWithValues { [weak self] (value) in
            guard let progress = value as? Float else { return }
            self?.progressView.progress = progress
            self?.progressView.isHidden = progress >= 1.0
        }
    }
    
    private func load() -> Void {
        if let url = self.url {
            if let theUrl = URL(string: (url.contains("http://") || url.contains("https://")) ? url : "http://\(url)") {
                loginfo(content: "<< Loading url: \(theUrl)")
                self.webView.load(URLRequest(url: theUrl))
            }
        }
        else if let name = self.fileName {
            if  let theUrl = Bundle.main.url(forResource: "\(name).html", withExtension: nil) {
                loginfo(content: "<< Loading url: \(theUrl)")
                self.webView.load(URLRequest(url: theUrl))
            }
        }
        else if let html = self.html {
            loginfo(content: "<< Loading html: \(html)")
            self.webView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    private func jsCallbackSetup() -> Void {
        self.webView.evaluateJavaScript("document.title", completionHandler: { [weak self] (data, _) in
            if let theTitle = data as? String {
                self?.title = theTitle
            }
        })
    }
    
    private func pushLogoutAction() -> Void {
        let js = "c2cLogout();"
        logdebug(content: "JS call named '\(js)'")
        self.webView.evaluateJavaScript(js) { (resp, err) in
            logdebug(content: "JS resp of 'c2cLogout': \(String.init(describing: resp)) err: \(String.init(describing: err))")
        }
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension WebController: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.jsCallbackSetup()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.jsCallbackSetup()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        logdebug(content: "Handle alert on Webview: \(message)")
        if IsDebug { SystemAlert(withStyle: .alert, on: self, title: nil, detail: message, actions: ["OK"]) { (_) in} }
        completionHandler()
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        logdebug(content: "Handle alert on Webview: \(message)")
        if IsDebug { SystemAlert(withStyle: .alert, on: self, title: nil, detail: message, actions: ["OK"]) { (_) in} }
        completionHandler(true)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        logdebug(content: "Handle alert on Webview: \(prompt)")
        if IsDebug { SystemAlert(withStyle: .alert, on: self, title: nil, detail: prompt, actions: ["OK"]) { (_) in} }
        completionHandler(prompt)
    }
    
}
