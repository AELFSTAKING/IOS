//
//  HomeFinancialListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/4/9.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class HomeFinancialCell: UITableViewCell {
    
    var financialItems = [FinancialListData]()
    var itemPressedCallback: ((FinancialListData) -> ())?
    
    @IBOutlet weak var titleLabel: UIButton!
    @IBOutlet weak var sep1: UIView!
    @IBOutlet weak var sep2: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        sep1.backgroundColor = kThemeColorSeparatorBlack
        sep2.backgroundColor = kThemeColorSeparatorBlack
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorColor = kThemeColorSeparatorBlack
        tableView.backgroundColor = .clear
        tableView.register(UINib(nibName: "HomeFinancialListCell", bundle: Bundle(identifier: "HomeFinancialListCell")), forCellReuseIdentifier: "cell")
        
        LanguageManager.shared().languageDidChangedSignal.observeValues { [weak self] (_) in
            self?.titleLabel.setTitle(LOCSTR(withKey: "理财产品"), for: .normal)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

extension HomeFinancialCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.financialItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.selectionStyle = .none
        if  indexPath.row < self.financialItems.count,
            let cell = cell as? HomeFinancialListCell {
            let data = self.financialItems[indexPath.row]
            cell.sync(data)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < self.financialItems.count, let callback = self.itemPressedCallback else {
            InfoToast(withLocalizedTitle: "信息获取失败")
            return
        }
        callback(self.financialItems[indexPath.row])
    }
    
}
