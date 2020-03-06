//
//  DealListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/1/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class DealListCell: UITableViewCell {

    @IBOutlet weak var timeLabel: Label!
    @IBOutlet weak var priceLabel: Label!
    @IBOutlet weak var quantityLabel: Label!
    @IBOutlet weak var txidLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.timeLabel.font = kThemeFontDINBold(13.0)
        self.priceLabel.font = kThemeFontDINBold(13.0)
        self.quantityLabel.font = kThemeFontDINBold(13.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(with data: OrderDealDetailDealItem) -> Void {
        self.timeLabel.text = data.date?.timestamp2date(withFormat: "HH:mm yyyy/MM/dd")
        self.priceLabel.text = data.price
        self.quantityLabel.text = data.quantity
        self.txidLabel.text = data.txId
    }
    
}
