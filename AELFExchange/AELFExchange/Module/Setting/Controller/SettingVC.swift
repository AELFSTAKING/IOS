//
//  SettingVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/17.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import PromiseKit

class SettingVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "GeneralListCell", bundle: Bundle(identifier: "GeneralListCell")), forCellReuseIdentifier: "cell")
        }
    }
    
    private var data = [(title: String, desc: String)]()
    private var cacheSize = ""
    private var exchangeRate = ""
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.assembleData()
        self.uiSetup()
        self.signalSetup()
        self.calculateCacheSize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.exchangeRate = "\(CurrencyManager.shared().legalCurrency)(\(CurrencyManager.shared().legalCurrencySymbol))"
        self.tableView.reloadData()
        self.calculateCacheSize()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    private func cachePressed() {
        self.startLoadingHUD(withMsg: Consts.kMsgInProcess)
        OConfig.clearAllUIWebViewData(forDomain: "up.top")
        ImageCache.default.clearDiskCache(completion: { [weak self] in
            self?.stopLoadingHUD()
            self?.calculateCacheSize()
        })
    }
    
    @objc private func exitPressed() {
        firstly {
            AELFIdentity.shared().auth()
            }.done { [weak self] (succeed, _) in
                guard succeed else {
                    InfoToast(withLocalizedTitle: "密码错误")
                    return
                }
                AELFIdentity.shared().removeIdentity()
                self?.tableView.reloadData()
            }.catch { (error) in
                AELFIdentity.errorToast(withError: error)
        }
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "设置")
    }
    
    private func signalSetup() -> Void {
        LanguageManager.shared().languageDidChangedSignal.observeValues { [weak self] (_) in
            self?.uiSetup()
        }
    }
    
    private func assembleData() {
        /*
        self.data = [
            (LOCSTR(withKey: "语言"), LanguageManager.shared().currentLanguageDescription()),
            (LOCSTR(withKey: "汇率").replacingOccurrences(of: " ", with: ""), self.exchangeRate),
            (LOCSTR(withKey: "检查新版本"), "V \(Bundle.main.versionNumber ?? "--")"),
            (LOCSTR(withKey: "清除缓存"), self.cacheSize),
            (LOCSTR(withKey: "网络诊断"), "")
        ]*/
        self.data = [
            (LOCSTR(withKey: "币种").replacingOccurrences(of: " ", with: ""), "USDT"),
            (LOCSTR(withKey: "语言"), "简体中文")
        ]
        self.tableView.reloadData()
    }
    
    private func calculateCacheSize() -> Void {
        ImageCache.default.calculateDiskCacheSize { [weak self] (size) in
            let MB = Float(size)/Float(1024*1024)
            let KB = MB/1024.0
            self?.cacheSize = String(format: "%.1f \(MB >= 1.0 ? "MB" : "KB")", MB >= 1.0 ? MB : KB)
            self?.assembleData()
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

extension SettingVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == self.data.count-1 {
            return 280.0
        }
        return 0.00001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == self.data.count-1 && AELFIdentity.hasIdentity() {
            let footer = UIView()
            let button = UIButton()
            button.backgroundColor = kThemeColorButtonUnable
            button.setTitleColor(kThemeColorTextNormal, for: .normal)
            button.titleLabel?.font = kThemeFontDINBold(16.0)
            button.setTitle(LOCSTR(withKey: "退出账号"), for: .normal)
            button.addCorner(withRadius: 5.0)
            button.addTarget(self, action: #selector(self.exitPressed), for: .touchUpInside)
            footer.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(15.0)
                make.right.equalToSuperview().offset(-15.0)
                make.centerY.equalToSuperview()
                make.height.equalTo(47.0)
            }
            return footer
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if  let cell = cell as? GeneralListCell,
            indexPath.section < self.data.count {
            cell.sync(self.data[indexPath.section])
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        /*
        switch indexPath.section {
        case 0:
            self.push(to: UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "languageSetting"), animated: true)
            break
        case 1:
            self.push(to: UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "legalCurrency"), animated: true)
            break
        case 2:
            self.startLoadingHUD(withMsg: Consts.kMsgLoading)
            AppUpdateManager.shared().checkout { [weak self] (hasUpdate) in
                self?.stopLoadingHUD()
                if !hasUpdate {
                    InfoToast(withLocalizedTitle: "已是最新版本")
                }
            }
            break
        case 3:
            self.cachePressed()
            break
        case 4:
            self.push(to: NetDetectorVC(), animated: true)
            break
        default:break
        }*/
    }
    
}
