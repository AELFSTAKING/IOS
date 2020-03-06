//
//  OrderBookDetailCell.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit

class OrderBookDetailCell: UITableViewCell {
    
    @IBOutlet weak var leftTitleLabel: Label!
    @IBOutlet weak var leftValueLabel: Label!
    @IBOutlet weak var rightTitleLabel: Label!
    @IBOutlet weak var rightValueLabel: Label!
    @IBOutlet weak var txidValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
