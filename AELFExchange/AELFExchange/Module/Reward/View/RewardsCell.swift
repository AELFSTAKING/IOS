//
//  RewardsCell.swift
//  AELFExchange
//
//  Created by tng on 2019/8/13.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit

class RewardsCell: UITableViewCell {

    @IBOutlet weak var theContentView: UIView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var title3: UILabel!
    @IBOutlet weak var title4: UILabel!
    @IBOutlet weak var value1: UILabel!
    @IBOutlet weak var value2: UILabel!
    @IBOutlet weak var value3: UILabel!
    @IBOutlet weak var value4: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.title3.text = LOCSTR(withKey: "已发奖励")
        self.title4.text = LOCSTR(withKey: "待领奖励")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(with data: Any) {
        if let data = data as? RewardsOfTopupData {
            self.title1.text = LOCSTR(withKey: "累计充币")
            self.title2.text = LOCSTR(withKey: "余额")
            
            let currency = data.currency ?? ""
            let rewardCurrency = data.rewardCurrency ?? ""
            self.currencyLabel.text = currency
            
            self.value1.text = "\(data.depositTotal ?? "") \(currency)"
            self.value2.text = "\(data.balance ?? "") \(currency)"
            self.value3.text = "\(data.sendedReward ?? "") \(rewardCurrency)"
            self.value4.text = "\(data.unsendReward ?? "") \(rewardCurrency)"
        } else if let data = data as? RewardsOfMiningData {
            self.title1.text = LOCSTR(withKey: "余额")
            self.title2.text = LOCSTR(withKey: "挖矿算力")
            
            let currency = data.currency ?? ""
            let rewardCurrency = data.rewardCurrency ?? ""
            self.currencyLabel.text = currency
            
            self.value1.text = "\(data.balance ?? "") \(currency)"
            self.value2.text = "\(data.power ?? "") \(LOCSTR(withKey: "算力"))"
            self.value3.text = "\(data.sendedReward ?? "") \(rewardCurrency)"
            self.value4.text = "\(data.unsendReward ?? "") \(rewardCurrency)"
        }
    }
    
}
