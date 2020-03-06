//
//  AssetTradeRecordListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit

class AssetTradeRecordListCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: Label!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var statusLabel: Label!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.typeLabel.addBorder(withWitdh: 0.8, color: UIColor(hexStr: "41BDA7"))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(withData data: TransactionRecordsDataItem) {
        self.typeLabel.text = "  \(data.txTypeDesc)  "
        self.addressLabel.text = data.hash
        self.dateLabel.text = (data.timestamp ?? data.sendTimestamp)?.timestamp2date(withFormat: "yyyy.MM.dd HH:mm")
        self.quantityLabel.text = "\(data.symbol)\(data.value ?? "--") \((data.currency ?? "").uppercased())"
        self.statusLabel.text = data.statusDesc
        
        var typeColor = UIColor(hexStr: "41BDA7")
        switch data.txType {
        case "DEPOSIT" :typeColor = UIColor(hexStr: "41BDA7")
        case "WITHDRAW":typeColor = UIColor(hexStr: "F89824")
        case "TRANSFER":typeColor = UIColor(hexStr: "316FF6")
        case "RECEIPT" :typeColor = UIColor(hexStr: "641FB0")
        default:break
        }
        self.typeLabel.layer.borderColor = typeColor.cgColor
        self.typeLabel.textColor = typeColor
    }
    
}
