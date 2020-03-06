//
//  NetDetectorCell.swift
//  AELFExchange
//
//  Created by tng on 2019/5/30.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class NetDetectorCell: UITableViewCell {

    @IBOutlet weak var iconTrailing: NSLayoutConstraint! // Def 5.0
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var statusIcon: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor(hexStr: "131529")
        self.indicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(withData data: NetDetectorItem) {
        self.titleLabel.text = data.title
        self.descLabel.text = data.desc
        self.statusIcon.isHidden = false
        self.indicator.stopAnimating()
        self.iconTrailing.constant = 5.0
        if data.status == .failed {
            self.statusIcon.isSelected = true
        } else if data.status == .succeed {
            self.statusIcon.isSelected = false
        } else if data.status == .loading {
            self.statusIcon.isHidden = true
            self.indicator.startAnimating()
        } else {
            self.statusIcon.isHidden = true
            self.iconTrailing.constant = -20.0
        }
    }
    
}
