//
//  TradeOrderCurrentCell.swift
//  AELFExchange
//
//  Created by tng on 2019/1/23.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class TradeOrderCurrentCell: UITableViewCell {
    
    @IBOutlet weak var progressLabel: Label!
    @IBOutlet weak var priceLabel: Label!
    @IBOutlet weak var quantityLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.progressLabel.updateProgress(to: 0)
        self.priceLabel.font = kThemeFontDINBold(13.0)
        self.quantityLabel.font = self.priceLabel.font
        self.quantityLabel.textColor = kThemeColorTextUnabled
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(with data: OrdersDelegateOrderItem, forBuy: Bool, quantityPercent: Float) -> Void {
        if forBuy {
            self.progressLabel.RedProgress = "0"
            self.progressLabel.GreenProgress = "1"
            self.priceLabel.textColor = kThemeColorGreen
        } else {
            self.progressLabel.RedProgress = "1"
            self.progressLabel.GreenProgress = "0"
            self.priceLabel.textColor = kThemeColorRed
        }
        
        guard !data.isEmptyCell else {
            self.priceLabel.text = "--"
            self.quantityLabel.text = "--"
            self.progressLabel.updateProgress(to: 0.0)
            return
        }
        self.priceLabel.text = data.limitPrice
        self.quantityLabel.text = data.quantity
        self.progressLabel.updateProgress(to: quantityPercent)
    }
    
}
