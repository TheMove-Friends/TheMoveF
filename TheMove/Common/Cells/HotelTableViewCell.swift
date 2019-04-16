//
//  HotelTableViewCell.swift
//  TheMove
//
//  Created by User 2 on 3/6/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit

class HotelTableViewCell: UITableViewCell {

    @IBOutlet weak var centerView: UIView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var hotelImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
