//
//  MineVC.swift
//  AELFExchange
//
//  Created by tng on 2019/4/16.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import CHIPageControl

class MineVC: BaseTableViewController {
    
    @IBOutlet weak var versionLabel: UILabel!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        self.isTopLevel = true
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "我的")
        self.view.backgroundColor = .white
        self.tableView.tableFooterView = UIView()
        self.versionLabel.text = "v \(Bundle.main.versionNumber ?? "--")"
    }
    
    private func signalSetup() -> Void {
        
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            self.push(to: UIStoryboard(name: "Setting", bundle: nil).instantiateInitialViewController()!, animated: true)
        case 4:
            self.startLoadingHUD(withMsg: Consts.kMsgLoading)
            AppUpdateManager.shared().checkout { [weak self] (hasUpdate) in
                self?.stopLoadingHUD()
                if !hasUpdate {
                    InfoToast(withLocalizedTitle: "已是最新版本")
                }
            }
        default:break
        }
    }
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}
