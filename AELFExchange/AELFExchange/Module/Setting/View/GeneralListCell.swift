//
//  GeneralListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/6/25.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class GeneralListCell: UITableViewCell {
    
    @IBOutlet weak var theContentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var arrowIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.textColor = kThemeColorTextNormal
        self.descLabel.textColor = kThemeColorTextUnabled
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(_ data: (title: String, desc: String)) {
        self.titleLabel.text = data.title
        self.descLabel.text = data.desc
    }
    
}
