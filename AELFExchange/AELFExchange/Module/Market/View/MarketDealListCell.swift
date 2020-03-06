//
//  MarketDealListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/1/21.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class MarketDealListCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: Label!
    @IBOutlet weak var directionLabel: Label!
    @IBOutlet weak var priceLabel: Label!
    @IBOutlet weak var quantityLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.dateLabel.font = kThemeFontDINBold(13.0)
        self.directionLabel.font = kThemeFontDINBold(13.0)
        self.priceLabel.font = kThemeFontDINBold(13.0)
        self.quantityLabel.font = kThemeFontDINBold(13.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(with data: OrdersLatestdealData) -> Void {
        self.dateLabel.text = (data.utcDeal ?? "").timestamp2date(withFormat: "HH:mm:ss")
        self.directionLabel.text = (data.action == "BUY" ? LOCSTR(withKey: "买入"):LOCSTR(withKey: "卖出"))
        self.directionLabel.textColor = PriceColor(withDirection: data.theDirection)
        self.priceLabel.text = data.price
        self.quantityLabel.text = data.quantity
    }
    
}
