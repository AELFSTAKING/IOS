//
//  TransactionDetailHeaderView.swift
//  AELFExchange
//
//  Created by tng on 2019/7/29.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit

class TransactionDetailHeaderView: UIView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func sync(withData data: TransactionRecordsDataItem?) {
        guard let data = data else { return }
        if data.status == 1 {
            self.icon.image = UIImage(named: "icon-asset-addrbindsuc-lit")
        } else if data.status == 0 {
            self.icon.image = UIImage(named: "icon-asset-txstatus-failed")
        } else if data.status == -1 {
            self.icon.image = UIImage(named: "icon-asset-txstatus-process")
        }
        self.valueLabel.text = "\(data.symbol)\(data.value ?? "--")"
        self.statusLabel.text = "\((data.currency ?? "--").uppercased())\(data.txTypeDesc)\(data.statusDesc)"
    }

}
