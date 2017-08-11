//
//  ContactDetailTableViewCell.swift
//  DB-Sample-ios
//
//  Created by Suman HS on 11/08/17.
//  Copyright © 2017 Suman HS. All rights reserved.
//

import Foundation
import UIKit

class ContactDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactNumberLabel: UILabel!
    @IBOutlet weak var mailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
