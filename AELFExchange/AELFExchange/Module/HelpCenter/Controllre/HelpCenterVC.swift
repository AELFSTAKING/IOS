//
//  HelpCenterVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class HelpCenterVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.register(UINib(nibName: "GeneralListCell", bundle: Bundle(identifier: "GeneralListCell")), forCellReuseIdentifier: "cell")
        }
    }
    
    private var data = [(title: String, desc: String)]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.data = [
            (LOCSTR(withKey: "操作指南"), ""),
            (LOCSTR(withKey: "关于我们"), ""),
            (LOCSTR(withKey: "联系我们"), ""),
            (LOCSTR(withKey: "在线客服"), "")
        ]
        
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
        self.title = LOCSTR(withKey: "帮助中心")
    }
    
    private func signalSetup() -> Void {
        
    }
    
    // MARK: - Signal
    
    // MARK: - Protocol conformance
    
    // MARK: - UITextFieldDelegate
    
    // MARK: - UITableViewDataSource
    
    // MARK: - UITableViewDelegate
    
    // MARK: - NSCopying
    
    // MARK: - NSObject
    
}

extension HelpCenterVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if  let cell = cell as? GeneralListCell,
            indexPath.section < self.data.count {
            cell.sync(self.data[indexPath.section])
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            self.push(to: SupportsVC(), animated: true)
            break
        case 1:
            let controller = UIStoryboard(name: "Setting", bundle: nil).instantiateViewController(withIdentifier: "about") as! AboutVC
            self.push(to: controller, animated: true)
            break
        case 2:
            self.push(to: WechatsVC(), animated: true)
            break
        case 3:
            self.push(to: WebPage(withUrl: Consts.kOnlineServiceUrl, as: LOCSTR(withKey: "在线客服")), animated: true)
            break
        default:break
        }
    }
    
}
