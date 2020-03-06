//
//  WechatsVC.swift
//  AELFExchange
//
//  Created by tng on 2019/1/19.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class WechatsVC: BaseViewController {
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.backgroundColor = .clear
        t.tableFooterView = UIView()
        t.separatorInset = .zero
        t.separatorColor = kThemeColorBackground
        t.delegate = self
        t.dataSource = self
        return t
    }()
    
    private var data = [WechatsResponseDataListItem]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
        
        self.startLoadingHUD(withMsg: Consts.kMsgLoading)
        Network.get(withUrl: Consts.kWeichatsUrl) { [weak self] (succeed, response) in
            self?.stopLoadingHUD()
            guard succeed == true, response.count > 0 else {
                InfoToast(withLocalizedTitle: "信息获取失败")
                return
            }
            let model = WechatsResponse.deserialize(from: response
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: ""))
            self?.data.removeAll()
            if let list = model?.data?.list {
                self?.data.append(contentsOf: list)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
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
        self.title = LOCSTR(withKey: "联系我们")
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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

extension WechatsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 185.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        cell?.backgroundColor = .clear
        
        if  indexPath.row < self.data.count,
            let theCell = cell {
            let data = self.data[indexPath.row]
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            theCell.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.edges.equalTo(theCell).inset(UIEdgeInsets(top: 10.0, left: 10.0, bottom: 35.0, right: 10.0))
            }
            
            if let urlText = data.imgUrl, let url = URL(string: urlText) {
                imageView.kf.setImage(with: ImageResource(downloadURL: url))
            } else {
                let img = QRCodeGenerator().createImage(value: data.weixin ?? "", size: CGSize(width: kScreenSize.width/2.0, height: kScreenSize.width/2.0))
                imageView.image = img
            }
            
            let label = UILabel()
            label.font = kThemeFontLarge
            label.textColor = .white
            label.text = data.weixin
            label.textAlignment = .center
            theCell.addSubview(label)
            label.snp.makeConstraints { (make) in
                make.top.equalTo(imageView.snp.bottom)
                make.centerX.equalTo(theCell)
                make.height.equalTo(35.0)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.data.count else {
            return
        }
        UIPasteboard.general.string = self.data[indexPath.row].weixin ?? ""
        InfoToast(withLocalizedTitle: "复制成功")
    }
    
}
