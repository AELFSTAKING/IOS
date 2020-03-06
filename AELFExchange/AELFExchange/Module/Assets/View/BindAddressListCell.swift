//
//  BindAddressListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/8/5.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit

class BindAddressListCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(withData data: BindAddressListDataItem) {
        self.nameLabel.text = data.name
        self.timeLabel.text = data.gmtCreate?.timestamp2date(withFormat: "yyyy.MM.dd")
        self.addressLabel.text = data.address
    }
    
}
