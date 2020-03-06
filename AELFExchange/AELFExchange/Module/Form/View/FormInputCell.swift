//
//  FormInputCell.swift
//  AELFExchange
//
//  Created by tng on 2019/7/18.
//  Copyright © 2019 cex.io. All rights reserved.
//

import UIKit

class FormInputCell: UITableViewCell {
    
    @IBOutlet weak var textfieldTrailing: NSLayoutConstraint! // Def 20.0
    @IBOutlet weak var titleLabel: Label!
    @IBOutlet weak var textfield: TextField!
    @IBOutlet weak var rightButtonItem: UIButton!
    
    var rightButtonItemPressedCallback: ((FormInputViewItem?) -> ())?
    private var currentData: FormInputViewItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rightButtonItem.setTitle(nil, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func sync(withData data: FormInputViewItem) {
        self.currentData = data
        self.titleLabel.text = data.title
        self.textfield.isUserInteractionEnabled = data.enabled
        self.textfield.setPlaceholder(with: data.placeHolder ?? "", font: UIFont.systemFont(size: 13.0))
        self.textfield.isSecureTextEntry = data.isSecurity
        if let defVal = data.defaultValue {
            self.textfield.text = defVal
        }
        
        if let icon = data.rightButtonIcon {
            self.textfieldTrailing.constant = 20.0+self.rightButtonItem.frame.width+10.0
            self.rightButtonItem.isHidden = false
            self.rightButtonItem.setImage(icon, for: .normal)
        } else {
            self.textfieldTrailing.constant = 20.0
            self.rightButtonItem.isHidden = true
            self.rightButtonItem.setImage(nil, for: .normal)
        }
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        if let callback = self.rightButtonItemPressedCallback {
            callback(self.currentData)
        }
    }
    
}
