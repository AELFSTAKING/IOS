//
//  BaseViewController.swift
//  AELF
//
//  Created by tng on 2018/9/9.
//  Copyright © 2018年 AELF. All rights reserved.
//

import UIKit
import Bugly

class BaseViewController: UIViewController {
    
    var page = Config.startIndexOfPage
    
    var isFirstTimeToShow = true
    
    var isTopLevel = false
    
    var isAppeared = false
    var isAppearedChangedFromTrue = false
    
    lazy var noSuchContentHUD: UIButton = {
        let b = UIButton(type: .custom)
        b.imageView?.contentMode = .scaleAspectFit
        b.setImage(UIImage(named: "icon-nosuch-content"), for: .normal)
        b.isHidden = true
        return b
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.themeSetup()
        
        if #available(iOS 11.0, *) {
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        NotificationCenter.default.reactive.notifications(forName: UIApplication.willResignActiveNotification).take(during: self.reactive.lifetime).observeValues { [weak self] (_) in
            self?.isAppearedChangedFromTrue = (self?.isAppeared == true)
            self?.isAppeared = false
        }
        
        NotificationCenter.default.reactive.notifications(forName: UIApplication.didBecomeActiveNotification).take(during: self.reactive.lifetime).observeValues { [weak self] (_) in
            if self?.isAppearedChangedFromTrue == true {
                self?.isAppeared = true
            }
        }
        
        // UI.
        self.view.addSubview(self.noSuchContentHUD)
        self.noSuchContentHUD.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.isAppeared = true
        let className = String(cString: object_getClassName(self))
        BuglyLog.level(.info, logs: "Will appear page: \(className)")
        MobClick.beginLogPageView(className)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isAppeared = false
        MobClick.endLogPageView(String(cString: object_getClassName(self)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isFirstTimeToShow = false
        self.view.bringSubviewToFront(self.noSuchContentHUD)
        BuglyLog.level(.info, logs: "Did appear page: \(String(cString: object_getClassName(self)))")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    deinit {
        print("✅\(self) has been destroyed.")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func showNoSuchContentHUD() {
        self.noSuchContentHUD.isHidden = false
    }
    
    func hideNoSuchContentHUD() {
        self.noSuchContentHUD.isHidden = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
