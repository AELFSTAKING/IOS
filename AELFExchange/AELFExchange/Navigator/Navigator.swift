//
//  Navigator.swift
//  AELF
//
//  Created by tng on 2018/9/10.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

public let MainTabbar = UIApplication.shared.keyWindow?.rootViewController! as! UITabBarController
public let MainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
public let LoginAndRegisterStoryBoard = UIStoryboard(name: "LoginAndRegister", bundle: nil)
public let IEONavigation = MainStoryBoard.instantiateViewController(withIdentifier: "activityNavigation") as! UINavigationController

private let sharedFlutterControllerProfile = FlutterController()

class Navigator {
    
    fileprivate static let ___donotUseThisVariableOfNavigator = Navigator()
    
    @discardableResult
    static func shared() -> Navigator {
        return Navigator.___donotUseThisVariableOfNavigator
    }
    
    /// Main Page of The General User.
    var mainUserNavigation = MainStoryBoard.instantiateViewController(withIdentifier: "mainnavigation") as! BaseNavigationController
    
}

extension UIViewController {
    
    /// Turn to the target page with the given parameter.
    ///
    /// - id: Identifier of UIStoryboard.
    /// - storyboard: UIStoryboard.
    /// - show: Bool.
    /// - container: UIViewController.
    @discardableResult
    func Controller(withStoryboardId id: String, from storyboard: UIStoryboard = MainStoryBoard, andShow show: Bool = true, on container: UIViewController? = nil) -> UIViewController {
        
        let controller = storyboard.instantiateViewController(withIdentifier: id)
        if !show {
            return controller
        }
        
        if let container = container {
            container.push(to: controller, animated: true)
        } else {
            self.push(to: controller, animated: true)
        }
        return controller
        
    }
    
    /// Area Selector.
    func AreaSelectorController() -> AreaSelectorVC {
        return UIStoryboard(name: "AreaSelector", bundle: nil).instantiateViewController(withIdentifier: "areaSelector") as! AreaSelectorVC
    }
    
    /// Verify Code Controller.
    func VerifyCodeController(for type: VerifyCodeInputEnum) -> VerifyCodeInputVC {
        let controller = UIStoryboard(name: "VerifyCodeInput", bundle: nil).instantiateViewController(withIdentifier: "verifyCodeInput") as! VerifyCodeInputVC
        controller.type = type
        return controller
    }
    
    /// A WebView Controller.
    func WebPage(withUrl url: String? = nil, fileName: String? = nil, html: String? = nil, as title: String? = nil) -> WebController {
        let controller = WebController()
        controller.title = title
        controller.url = url
        controller.fileName = fileName
        controller.html = html
        return controller
    }
    
    /// Help Center.
    func HelpCenter() -> UIViewController {
        return UIStoryboard(name: "HelpCenter", bundle: nil).instantiateInitialViewController()!
    }
    
    /// Unavailable Page.
    func UnavailableController(showBackButton: Bool = true, customMsg: String? = nil) -> UIViewController {
        let controller = BaseViewController()
        let imageView = UIImageView(image: UIImage(named: "icon-unavailable-bg"))
        imageView.contentMode = .scaleAspectFit
        imageView.transform = CGAffineTransform.init(scaleX: 1.25, y: 1.25)
        controller.view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(controller.view).inset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        }
        
        let title = Label()
        title.White = "1"
        title.Large = "1"
        title.textAlignment = .center
        title.text = customMsg ?? "币币交易即将开启"
        controller.view.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.centerY.equalTo(controller.view).offset(115.0)
            make.left.equalTo(controller.view)
            make.right.equalTo(controller.view)
        }

        if showBackButton {
            let button = UIButton(type: .system)
            button.titleLabel?.font = kThemeFontLarge
            button.setTitle("返回首页", for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.addTarget(self, action: #selector(self.pop), for: .touchUpInside)
            controller.view.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.top.equalTo(title.snp.bottom).offset(30.0)
                make.centerX.equalTo(controller.view)
                make.width.equalTo(100.0)
            }
        }
        return controller
    }
    
    /// Notice Center.
    func NoticeCenterController() -> UIViewController {
        return UIStoryboard(name: "Notice", bundle: nil).instantiateInitialViewController()!
    }
    func NoticeDetail(withTitle title: String?, content: String?) -> NoticeDetailVC {
        let controller = UIStoryboard(name: "Notice", bundle: nil).instantiateViewController(withIdentifier: "noticeDetail") as! NoticeDetailVC
        controller.theTitle = title
        controller.content = content
        return controller
    }
    
    /// Withdraw.
    func ShowWithdraw(withCurrency currency: String, mode: WithdrawMode, txCreatedCallback: (() -> ())? = nil) -> Void {
        let withdraw = UIStoryboard(name: "Assets", bundle: nil).instantiateViewController(withIdentifier: "withdraw") as! WithdrawVC
        withdraw.viewModel.mode = mode
        withdraw.viewModel.currency =  currency
        withdraw.transactionCreatedCallback = {
            if let callback = txCreatedCallback {
                callback()
            }
        }
        self.push(to: withdraw, animated: true)
    }
    
    /// KLine Page.
    func KLineController(with data: SymbolsItem) -> UIViewController {
        let controller = UIStoryboard(name: "Market", bundle: nil).instantiateViewController(withIdentifier: "marketKLine") as! MarketKLineVC
        controller.viewModel.data = data
        return controller
    }
    
    /// Trade Page.
    func ShowTradePage(withSymbol symbol: String, mode: TradeViewModeEnum) {
        let controller = UIStoryboard(name: "Trade", bundle: nil).instantiateViewController(withIdentifier: "trade") as! TradeVC
        controller.viewModel.isNotTopLevel = true
        controller.viewModel.mode = mode.rawValue
        controller.viewModel.symbol = symbol
        self.push(to: controller, animated: true)
    }
    
}

// MARK: - Flutter Module.
extension UIViewController {
    
    func FlutterModuleProfile() -> FlutterController {
        sharedFlutterControllerProfile.setInitialRoute("/profile")
        return sharedFlutterControllerProfile
    }
    
}
