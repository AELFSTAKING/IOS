//
//  NoticeListCell.swift
//  AELFExchange
//
//  Created by tng on 2019/1/15.
//  Copyright © 2019 aelf.io. All rights reserved.
//

import UIKit

class NoticeListCell: UITableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var sepView: UIView! {
        didSet {
            sepView.backgroundColor = kThemeColorSeparator
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(with data: NoticeListItem) -> Void {
        self.titleLabel.text = data.title
        self.dateLabel.text = (data.publishTime ?? "0").timestamp2date()
    }
    
}
