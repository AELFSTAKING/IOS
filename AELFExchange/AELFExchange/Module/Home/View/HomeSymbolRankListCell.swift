//
//  HomeSymbolRankListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/4/9.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class HomeSymbolRankListCell: UITableViewCell {
    
    var marketItems = [SymbolsItem]()
    private var currentMode = HomeSymbolRankListCellType.price
    
    var menuPressedCallback: ((HomeSymbolRankListCellType) -> ())?
    var itemPressedCallback: ((SymbolsItem) -> ())?

    @IBOutlet weak var sep1: UIView!
    @IBOutlet weak var sep2: UIView!
    @IBOutlet weak var priceButton: UIButton!
    @IBOutlet weak var quantityButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        sep1.backgroundColor = kThemeColorSeparator
        sep2.backgroundColor = kThemeColorSeparator
        priceButton.setTitleColor(kThemeColorTextNormal, for: .normal)
        quantityButton.setTitleColor(kThemeColorTextUnabled, for: .normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorColor = kThemeColorSeparator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 15.0, bottom: 0, right: 15.0)
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "HomeSymbolListCell", bundle: Bundle(identifier: "HomeSymbolListCell")), forCellReuseIdentifier: "cell")
        
        LanguageManager.shared().languageDidChangedSignal.observeValues { [weak self] (_) in
            self?.priceButton.setTitle(LOCSTR(withKey: "涨幅榜"), for: .normal)
            self?.quantityButton.setTitle(LOCSTR(withKey: "成交榜"), for: .normal)
            self?.label1.text = LOCSTR(withKey: self?.currentMode == .price ? "交易对/24H量":"交易对/涨跌幅")
            self?.label2.text = LOCSTR(withKey: "最新价")
            self?.label3.text = LOCSTR(withKey: self?.currentMode == .price ? "涨跌幅":"成交量")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func priceButtonPressed(_ sender: Any) {
        self.currentMode = .price
        self.priceButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.priceButton.setTitleColor(kThemeColorTextNormal, for: .normal)
        self.quantityButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        self.quantityButton.setTitleColor(kThemeColorTextUnabled, for: .normal)
        self.label1.text = LOCSTR(withKey: "交易对/24H量")
        self.label3.text = LOCSTR(withKey: "涨跌幅")
        if let callback = self.menuPressedCallback { callback(.price) }
    }
    
    @IBAction func quantityButtonPressed(_ sender: Any) {
        self.currentMode = .quantity
        self.quantityButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.quantityButton.setTitleColor(kThemeColorTextNormal, for: .normal)
        self.priceButton.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        self.priceButton.setTitleColor(kThemeColorTextUnabled, for: .normal)
        self.label1.text = LOCSTR(withKey: "交易对/涨跌幅")
        self.label3.text = LOCSTR(withKey: "成交量")
        if let callback = self.menuPressedCallback { callback(.quantity) }
    }
    
}

extension HomeSymbolRankListCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.marketItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if  indexPath.row < self.marketItems.count,
            let cell = cell as? HomeSymbolListCell {
            let data = self.marketItems[indexPath.row]
            cell.sync(with: data, mode: self.currentMode)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.marketItems.count, let callback = self.itemPressedCallback else {
            InfoToast(withLocalizedTitle: "信息获取失败")
            return
        }
        let item = SymbolsItem()
        item.isShow = self.marketItems[indexPath.row].isShow
        item.symbol = self.marketItems[indexPath.row].symbol
        item.highestPrice = self.marketItems[indexPath.row].highestPrice
        item.maxPrice = self.marketItems[indexPath.row].maxPrice
        item.highestUsdPrice = self.marketItems[indexPath.row].highestUsdPrice
        item.lowestPrice = self.marketItems[indexPath.row].lowestPrice
        item.minPrice = self.marketItems[indexPath.row].minPrice
        item.lowestUsdPrice = self.marketItems[indexPath.row].lowestUsdPrice
        item.price = self.marketItems[indexPath.row].price
        item.lastPrice = self.marketItems[indexPath.row].lastPrice
        item.usdPrice = self.marketItems[indexPath.row].usdPrice
        item.lastUsdPrice = self.marketItems[indexPath.row].lastUsdPrice
        item.quantity = self.marketItems[indexPath.row].quantity
        item.wavePrice = self.marketItems[indexPath.row].wavePrice
        item.wavePercent = self.marketItems[indexPath.row].wavePercent
        item.direction = self.marketItems[indexPath.row].direction
        callback(item)
    }
    
}
