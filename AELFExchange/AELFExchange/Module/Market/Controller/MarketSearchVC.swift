//
//  MarketSearchVC.swift
//  AELFExchange
//
//  Created by tng on 2019/5/17.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import Foundation
import UIKit

class MarketSearchVC: BaseViewController {
    
    var didSelectedSymbolCallback: ((SymbolsItem) -> ())?
    var data = [String]()
    private var isHistory = true
    
    lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.separatorStyle = .none
        t.tableFooterView = UIView()
        t.backgroundColor = kThemeColorNavigationBarBlue
        t.separatorInset = .zero
        t.delegate = self
        t.dataSource = self
        t.register(UINib(nibName: "MarketSearchCell", bundle: Bundle(identifier: "MarketSearchCell")), forCellReuseIdentifier: "cell")
        return t
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.uiSetup()
        self.signalSetup()
    }
    
    // MARK: - Custom Accessors
    
    // MARK: - IBActions
    
    // MARK: - Public
    
    // MARK: - Private
    private func uiSetup() -> Void {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func signalSetup() -> Void {
        
    }
    
    @objc private func clearHistoryPressed() {
        DB.shared().async { (rm) in
            rm.delete(rm.objects(SearchHistoryEntity.self))
            self.loadSearchHistory(delay: 0.0)
        }
    }
    
    func refreshData() {
        DispatchQueue.main.async {
            self.isHistory = false
            self.tableView.reloadData()
            if self.data.count == 0 {
                self.showNoSuchContentHUD()
            } else {
                self.hideNoSuchContentHUD()
            }
        }
    }
    
    func loadSearchHistory(delay: TimeInterval = 0.5) {
        self.hideNoSuchContentHUD()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+delay) {
            self.data.removeAll()
            for item in DB.shared().rm.objects(SearchHistoryEntity.self).reversed() {
                if let symbol = item.keywords {
                    self.data.append(symbol)
                }
            }
            self.isHistory = true
            self.tableView.reloadData()
            self.hideNoSuchContentHUD()
        }
    }
    
    private func collectPressed(withButton button: UIButton, symbol: String) {
        guard !symbol.isEmpty else { return }
        button.isSelected.toggle()
        let colleceted = DB.shared().isSymbolCollected(for: symbol)
        let params = [ "symbol":symbol ]
        Network.post(withUrl: URLs.shared().genUrl(with: colleceted ? .delCollection : .addCollection), params: params, to: BaseAPIBusinessModel.self) { (succeed, response) in
            if !succeed || !response.succeed {
                InfoToast(withLocalizedTitle: response.msg)
            }
            DB.shared().symbolCollect(forCollect: !colleceted, symbol: symbol)
            let succeedToCollect = (succeed == true && response.succeed == true)
            if !succeedToCollect {
                button.isSelected.toggle()
            }
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

extension MarketSearchVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.isHistory ? 50.0 : 0.0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.backgroundColor = kThemeColorBackground
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 14.0)
        title.textColor = .white
        title.text = LOCSTR(withKey: "最近搜索")
        header.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(13.0)
        }
        
        let button = UIButton(type: .custom)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .right
        button.setImage(UIImage(named: "icon-mk-clean"), for: .normal)
        button.addTarget(self, action: #selector(clearHistoryPressed), for: .touchUpInside)
        header.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-15.0)
            make.width.equalTo(50.0)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .gray
        if  let cell = cell as? MarketSearchCell,
            indexPath.row < self.data.count {
            cell.sync(withSymbol: self.data[indexPath.row])
            cell.pressedCollectCallback = { [weak self] (symbol, button) in
                self?.collectPressed(withButton: button, symbol: symbol)
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.data.count else {
            return
        }
        let symbol = self.data[indexPath.row]
        if let callback = self.didSelectedSymbolCallback {
            let item = SymbolsItem()
            item.symbol = symbol
            callback(item)
        }
        DB.shared().async { (rm) in
            let entity = SearchHistoryEntity()
            entity.keywords = symbol
            rm.add(entity, update: true)
        }
    }
    
}
