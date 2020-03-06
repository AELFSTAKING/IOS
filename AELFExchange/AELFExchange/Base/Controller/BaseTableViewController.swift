//
//  BaseTableViewController.swift
//  AELF
//
//  Created by tng on 2018/9/11.
//  Copyright © 2018年 AELF. All rights reserved.
//

import Foundation
import UIKit
import Bugly

class BaseTableViewController: UITableViewController {
    
    var page = Config.startIndexOfPage
    
    var isFirstTimeToShow = true
    
    var isTopLevel = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.themeSetup()
        self.tableView.backgroundColor = .clear
        
        if #available(iOS 11.0, *) {
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let className = String(cString: object_getClassName(self))
        BuglyLog.level(.info, logs: "Will appear page: \(className))")
        MobClick.beginLogPageView(className)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        MobClick.endLogPageView(String(cString: object_getClassName(self)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isFirstTimeToShow = false
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
    
    
    /*
    // MARK: - Navigation
     
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
