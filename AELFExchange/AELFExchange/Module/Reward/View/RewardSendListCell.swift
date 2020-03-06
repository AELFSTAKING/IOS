//
//  RewardSendListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/8/8.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit

class RewardSendListCell: UITableViewCell {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var value1: UILabel!
    @IBOutlet weak var value2: UILabel!
    @IBOutlet weak var value3: UILabel!
    @IBOutlet weak var value4: UILabel!
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var title2: UILabel!
    @IBOutlet weak var title3: UILabel!
    @IBOutlet weak var title4: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(withData data: RewardsSendListData) {
        if data.rewardType == 1 {
            self.typeLabel.textColor = kThemeColorTintPurple
        } else {
            self.typeLabel.textColor = kThemeColorOrange
        }
        
        self.typeLabel.text = data.rewardTypeDesc
        self.timeLabel.text = data.sendTime
        
        if let list = data.sendList {
            if let d = list.first {
                self.title1.text = d.tokenCurrency
                self.value1.text = "\(d.rewardAmount ?? "--") \(d.rewardCurrency ?? "")"
            }
            if list.count > 1 {
                self.title2.text = list[1].tokenCurrency
                self.value2.text = "\(list[1].rewardAmount ?? "--") \(list[1].rewardCurrency ?? "")"
            }
            if list.count > 2 {
                self.title3.text = list[2].tokenCurrency
                self.value3.text = "\(list[2].rewardAmount ?? "--") \(list[2].rewardCurrency ?? "")"
            }
            if list.count > 3 {
                self.title4.text = list[3].tokenCurrency
                self.value4.text = "\(list[3].rewardAmount ?? "--") \(list[3].rewardCurrency ?? "")"
            }
            
            self.title4.isHidden = (list.count <= 3)
            self.value4.isHidden = (list.count <= 3)
        }
    }
    
}
