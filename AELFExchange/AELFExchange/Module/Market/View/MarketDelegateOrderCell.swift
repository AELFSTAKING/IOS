//
//  MarketDelegateOrderCell.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class MarketDelegateOrderCell: UITableViewCell {
    
    @IBOutlet weak var buyProgressLabel: Label!
    @IBOutlet weak var buyAmountLabel: Label!
    @IBOutlet weak var buyPriceLabel: Label! {
        didSet {
            buyPriceLabel.textColor = kThemeColorGreen
        }
    }
    @IBOutlet weak var sellProgreessLabeel: Label!
    @IBOutlet weak var sellAmountLabel: Label!
    @IBOutlet weak var sellPriceLabel: Label! {
        didSet {
            sellPriceLabel.textColor = kThemeColorRed
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.buyProgressLabel.updateProgress(to: 0)
        self.sellProgreessLabeel.updateProgress(to: 0)
        self.buyAmountLabel.font = kThemeFontDINBold(13.0)
        self.buyPriceLabel.font = kThemeFontDINBold(13.0)
        self.sellAmountLabel.font = kThemeFontDINBold(13.0)
        self.sellPriceLabel.font = kThemeFontDINBold(13.0)
        self.buyAmountLabel.textColor = kThemeColorTextUnabled
        self.sellAmountLabel.textColor = kThemeColorTextUnabled
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(with data: OrdersDelegateOrderItem, forBuy: Bool, quantityPercent: Float) -> Void {
        if forBuy {
            self.buyAmountLabel.text = data.isEmptyCell ? "--":data.quantity
            self.buyPriceLabel.text = data.isEmptyCell ? "--":data.limitPrice
            self.buyProgressLabel.updateProgress(to: data.isEmptyCell ? 0:quantityPercent)
        } else {
            self.sellAmountLabel.text = data.isEmptyCell ? "--":data.quantity
            self.sellPriceLabel.text = data.isEmptyCell ? "--":data.limitPrice
            self.sellProgreessLabeel.updateProgress(to: data.isEmptyCell ? 0:quantityPercent)
        }
    }
    
}
