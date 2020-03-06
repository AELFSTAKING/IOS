//
//  HomeFinancialListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/4/9.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class HomeFinancialListCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var repayTypeLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.durationLabel.textColor = kThemeColorTextUnabled
        self.repayTypeLabel.textColor = self.durationLabel.textColor
        self.rateLabel.font = kThemeFontDINBold(25.0)
        self.durationLabel.addBorder(withWitdh: 0.8, color: self.durationLabel.textColor)
        self.repayTypeLabel.addBorder(withWitdh: 0.8, color: self.repayTypeLabel.textColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func sync(_ data: FinancialListData) {
        self.nameLabel.text = data.productName
        self.durationLabel.text = " \(data.cycleTime ?? "--") "
        self.repayTypeLabel.text = " \(data.interestMode ?? "--") "
        self.rateLabel.text = data.profitScale
    }
    
}
