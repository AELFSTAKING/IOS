//
//  NetDetectorVC.swift
//  AELFExchange
//
//  Created by tng on 2019/5/30.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import Reachability
import PPSPing

enum NetDetectorStatusType {
    case loading
    case succeed
    case failed
}

struct NetDetectorItem {
    var title: String?
    var desc: String?
    var status: NetDetectorStatusType?
}

class NetDetectorVC: BaseViewController {
    
    private var data = [[NetDetectorItem]]()
    private var reachability: Reachability!
    private let ppspingPubWebsite = PPSPingServices.service(withAddress: "www.baidu.com", maximumPingTimes: 20)
    private let ppspingUptop = PPSPingServices.service(withAddress: "www.up.top", maximumPingTimes: 20)
    
    private var rttPub = ""
    private var sentCountPub = 0
    private var sendFailedCountPub = 0
    private var rttUptop = ""
    private var sentCountUptop = 0
    private var sendFailedCountUptop = 0
    private var currentMqttStatus = false
    private var detectCount = 0
    
    lazy var detectButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        b.addCorner(withRadius: 3.0)
        return b
    }()
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .grouped)
        t.separatorColor = kThemeColorForeground
        t.tableFooterView = UIView()
        t.backgroundColor = .clear
        t.separatorInset = .zero
        t.delegate = self
        t.dataSource = self
        t.register(UINib(nibName: "NetDetectorCell", bundle: Bundle(identifier: "NetDetectorCell")), forCellReuseIdentifier: "cell")
        return t
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        self.doDetect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.reachability.stopNotifier()
        self.ppspingPubWebsite?.cancel()
        self.ppspingUptop?.cancel()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    @objc private func detectPressed() {
        guard self.detectCount == -1 else { return }
        currentMqttStatus.toggle()
        self.doDetect()
    }
    
    @objc private func contactPressed() {
        self.push(to: WebPage(withUrl: Consts.kOnlineServiceUrl, as: LOCSTR(withKey: "在线客服")), animated: true)
    }
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.title = LOCSTR(withKey: "网络诊断")
        self.view.backgroundColor = UIColor(hexStr: "0F1121")
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    }
    
    private func signalSetup() -> Void {
        self.detectButton.addTarget(self, action: #selector(self.detectPressed), for: .touchUpInside)
    }
    
    private func doDetect() {
        rttPub = ""
        sentCountPub = 0
        sendFailedCountPub = 0
        rttUptop = ""
        sentCountUptop = 0
        sendFailedCountUptop = 0
        detectCount = 0
        
        let sysVersion = "iOS \(UIDevice.current.systemVersion)"
        let appVersion = "V \(Bundle.main.versionNumber ?? "--")"
        let time = timestamps().timestamp2date()
        let uid = "--"
        let udid = osid(forService: Consts.kBundleID)
        let groupA = [
            NetDetectorItem(title: LOCSTR(withKey: "设备名称"), desc: DeviceModelName(), status: nil),
            NetDetectorItem(title: LOCSTR(withKey: "系统版本"), desc: sysVersion, status: nil),
            NetDetectorItem(title: LOCSTR(withKey: "APP版本"), desc: appVersion, status: nil),
            NetDetectorItem(title: LOCSTR(withKey: "本机时间"), desc: time, status: nil),
            NetDetectorItem(title: "UID", desc: uid, status: nil),
            NetDetectorItem(title: LOCSTR(withKey: "设备ID"), desc: udid, status: nil)
        ]
        let groupB = [
            NetDetectorItem(title: LOCSTR(withKey: "网络类型"), desc: nil, status: .loading),
            NetDetectorItem(title: LOCSTR(withKey: "外网IP"), desc: nil, status: .loading),
            NetDetectorItem(title: LOCSTR(withKey: "域名解析IP"), desc: nil, status: .loading),
            NetDetectorItem(title: LOCSTR(withKey: "服务器连通状态"), desc: nil, status: .loading),
            NetDetectorItem(title: LOCSTR(withKey: "互联网连接状态"), desc: nil, status: .loading),
            NetDetectorItem(title: LOCSTR(withKey: "数据通道状态"), desc: nil, status: .loading)
        ]
        self.data.removeAll()
        self.data.append(groupA)
        self.data.append(groupB)
        self.tableView.reloadData()
        
        DispatchQueue.global().async {
            // NetConnection.
            self.reachability = Reachability()!
            self.reachability.whenReachable = { reachability in
                for case let item in self.data[1] where item.title == LOCSTR(withKey: "网络类型") {
                    self.reachability.stopNotifier()
                    self.data[1][0].status = .succeed
                    if reachability.connection == .wifi {
                        self.data[1][0].desc = "WIFI"
                        self.increaseDetectCountIfNeeded()
                    } else if reachability.connection == .cellular {
                        self.data[1][0].desc = LOCSTR(withKey: "蜂窝移动网络")
                        self.increaseDetectCountIfNeeded()
                    } else {
                        self.data[1][0].desc = LOCSTR(withKey: "无网络连接")
                        self.data[1][0].status = .failed
                        self.setFailedDetectCountIfNeeded()
                    }
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            }
            do {
                try self.reachability.startNotifier()
            } catch {
                logerror(content: "Unable to start notifier of Reachability.")
            }
            
            // IP.
            let wanIPAddress = DeviceWANIPAddress()
            for case let i in self.data[1] where i.title == LOCSTR(withKey: "网络类型") {
                self.data[1][1].desc = wanIPAddress
                self.data[1][1].status = (wanIPAddress == "--" ? .failed : .succeed)
                if wanIPAddress == "--" {
                    self.setFailedDetectCountIfNeeded()
                } else {
                    self.increaseDetectCountIfNeeded()
                }
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
            
            // Host DNS.
            for case let i in self.data[1] where i.title == LOCSTR(withKey: "域名解析IP") {
                let dns = OConfig.getIPAddress(byHostName: "www.up.top")
                self.data[1][2].desc = dns.isEmpty ? "--" : dns
                self.data[1][2].status = (dns.isEmpty ? .failed : .succeed)
                if dns.isEmpty {
                    self.setFailedDetectCountIfNeeded()
                } else {
                    self.increaseDetectCountIfNeeded()
                }
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
            
            // Ping up.top.
            self.ppspingUptop?.start(callbackHandler: { [weak self] (pingItem, _) in
                guard (self?.sentCountUptop ?? 0) < 20 else {
                    self?.ppspingUptop?.cancel()
                    return
                }
                if pingItem?.status == PPSPingStatus(rawValue: 6) && (self?.sentCountUptop ?? 0) < 10 {
                    // Ping Failed.
                    self?.ppspingUptop?.cancel()
                    self?.sentCountUptop = 9
                    self?.sendFailedCountUptop = 10
                }
                self?.sentCountUptop += 1
                if  pingItem?.status != PPSPingStatus(rawValue: 0) &&
                    pingItem?.status != PPSPingStatus(rawValue: 2) &&
                    pingItem?.status != PPSPingStatus(rawValue: 6) {
                    self?.sendFailedCountUptop += 1
                }
                self?.rttUptop = NSDecimalNumber(value: (pingItem?.rtt ?? 0.0))
                    .adding(NSDecimalNumber(string: self?.rttUptop), withBehavior: kDecimalConfig)
                    .string(withDecimalLen: 1)
                self?.updatePingUptopIfNeeded()
            })
            
            // Ping Shared Website.
            self.ppspingPubWebsite?.start(callbackHandler: { [weak self] (pingItem, _) in
                guard (self?.sentCountPub ?? 0) < 20 else {
                    self?.ppspingPubWebsite?.cancel()
                    return
                }
                if pingItem?.status == PPSPingStatus(rawValue: 6) && (self?.sentCountPub ?? 0) < 10 {
                    // Ping Failed.
                    self?.ppspingPubWebsite?.cancel()
                    self?.sentCountPub = 9
                    self?.sendFailedCountPub = 10
                }
                self?.sentCountPub += 1
                if  pingItem?.status != PPSPingStatus(rawValue: 0) &&
                    pingItem?.status != PPSPingStatus(rawValue: 2) &&
                    pingItem?.status != PPSPingStatus(rawValue: 6) {
                    self?.sendFailedCountPub += 1
                }
                self?.rttPub = NSDecimalNumber(value: (pingItem?.rtt ?? 0.0))
                    .adding(NSDecimalNumber(string: self?.rttPub), withBehavior: kDecimalConfig)
                    .string(withDecimalLen: 1)
                self?.updatePingPublicWebsiteIfNeeded()
            })
            
            // MQTT Status.
            MQTTManager.shared().statusCallback = { [weak self] (connected) in
                if self?.isAppeared == true {
                    guard let s = self, self?.currentMqttStatus != connected else { return }
                    self?.currentMqttStatus = connected
                    for case let i in s.data[1] where i.title == LOCSTR(withKey: "数据通道状态") {
                        self?.increaseDetectCountIfNeeded()
                        s.data[1][5].desc = LOCSTR(withKey: connected ? "已连接" : "未连接")
                        s.data[1][5].status = (connected ? .succeed : .failed)
                        if !connected {
                            self?.setFailedDetectCountIfNeeded()
                        }
                        DispatchQueue.main.async { s.tableView.reloadData() }
                    }
                }
            }
        }
    }
    
    private func updatePingUptopIfNeeded() {
        if self.sentCountUptop == 10 {
            for case let i in self.data[1] where i.title == LOCSTR(withKey: "服务器连通状态") {
                let rttValue = NSDecimalNumber(string: self.rttUptop).dividing(by: NSDecimalNumber(value: 10.0), withBehavior: kDecimalConfig)
                let rtt = "\(rttValue.string(withDecimalLen: 2))ms"
                let plr = Float(self.sendFailedCountUptop)/Float(self.sentCountUptop) * 100.0
                let plrStr = NSDecimalNumber(value: plr).string(withDecimalLen: 1)
                self.data[1][3].desc = "\(plrStr)%\(LOCSTR(withKey: "丢包率"))(\(rtt))"
                self.data[1][3].status = (plr >= 50.0 ? .failed : .succeed)
                if plr >= 50.0 {
                    self.setFailedDetectCountIfNeeded()
                }
            }
            self.increaseDetectCountIfNeeded()
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    private func updatePingPublicWebsiteIfNeeded() {
        if self.sentCountPub == 10 {
            for case let i in self.data[1] where i.title == LOCSTR(withKey: "互联网连接状态") {
                let rttValue = NSDecimalNumber(string: self.rttPub).dividing(by: NSDecimalNumber(value: 10.0), withBehavior: kDecimalConfig)
                let rtt = "\(rttValue.string(withDecimalLen: 2))ms"
                let plr = Float(self.sendFailedCountPub)/Float(self.sentCountPub) * 100.0
                let plrStr = NSDecimalNumber(value: plr).string(withDecimalLen: 1)
                self.data[1][4].desc = "\(plrStr)%\(LOCSTR(withKey: "丢包率"))(\(rtt))"
                self.data[1][4].status = (plr >= 50.0 ? .failed : .succeed)
                if plr >= 50.0 {
                    self.setFailedDetectCountIfNeeded()
                }
            }
            self.increaseDetectCountIfNeeded()
            DispatchQueue.main.async { self.tableView.reloadData() }
        }
    }
    
    private func increaseDetectCountIfNeeded() {
        guard self.detectCount != -1 else { return }
        self.detectCount += 1
        self.updateDetectButtonTitle()
    }
    
    private func setFailedDetectCountIfNeeded() {
        guard self.detectCount != -1 else { return }
        self.detectCount = -1
        self.updateDetectButtonTitle()
    }
    
    private func updateDetectButtonTitle() {
        if self.detectCount == 6 || self.detectCount == -1 {
            DispatchQueue.main.async { self.tableView.reloadData() }
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

extension NetDetectorVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < self.data.count else { return 0 }
        return self.data[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 1 ? 160.0 : 0.0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard section == 1 else { return nil}
        let footer = UIView()
        footer.backgroundColor = .clear
        
        if self.detectCount == 6 {
            detectButton.setTitle(LOCSTR(withKey: "检测完成"), for: .normal)
            detectButton.backgroundColor = UIColor(hexStr: "0091FF")
        } else if self.detectCount >= 0 && self.detectCount < 6 {
            detectButton.setTitle("\(LOCSTR(withKey: "检测中"))..", for: .normal)
            detectButton.backgroundColor = UIColor(hexStr: "262D46")
        } else if self.detectCount == -1 {
            detectButton.setTitle(LOCSTR(withKey: "重新检测"), for: .normal)
            detectButton.backgroundColor = UIColor(hexStr: "0091FF")
        }
        footer.addSubview(detectButton)
        detectButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.height.equalTo(40.0)
            make.left.equalToSuperview().offset(35.0)
            make.right.equalToSuperview().offset(-35.0)
        }
        
        if self.detectCount == -1 {
            let label = UILabel()
            label.isUserInteractionEnabled = true
            label.numberOfLines = 10
            footer.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.bottom.equalTo(detectButton.snp.top).offset(-20.0)
                make.left.equalToSuperview().offset(5.0)
                make.right.equalToSuperview().offset(-5.0)
            }
        
            let tap = UITapGestureRecognizer(target: self, action: #selector(contactPressed))
            label.addGestureRecognizer(tap)
            
            let str = LOCSTR(withKey: "您的网络较差，请断开后重新连接，如有疑问请将检测结果截图并联系客服")
            let range = (str as NSString).range(of: LOCSTR(withKey: "联系客服"))
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            let attr = NSMutableAttributedString(string: str)
            attr.addAttributes([NSAttributedString.Key.paragraphStyle:style], range: NSRange(location: 0, length: str.count))
            attr.addAttributes([NSAttributedString.Key.font:UIFont.systemFont(ofSize: 10.0)], range: NSRange(location: 0, length: str.count))
            attr.addAttributes([NSAttributedString.Key.foregroundColor:UIColor(hexStr: "7D7F91")], range: NSRange(location: 0, length: str.count))
            attr.addAttributes([NSAttributedString.Key.foregroundColor:UIColor(hexStr: "0091FF")], range: range)
            label.attributedText = attr
        }
    
        return footer
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .gray
        if  indexPath.section < self.data.count,
            indexPath.row < self.data[indexPath.section].count,
            let cell = cell as? NetDetectorCell {
            let data = self.data[indexPath.section][indexPath.row]
            cell.sync(withData: data)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if  indexPath.section < self.data.count,
            indexPath.row < self.data[indexPath.section].count{
            let data = self.data[indexPath.section][indexPath.row]
            if let value = data.desc {
                UIPasteboard.general.string = value
                InfoToast(withLocalizedTitle: "\(data.title ?? "")复制成功")
            }
        }
    }
    
}
